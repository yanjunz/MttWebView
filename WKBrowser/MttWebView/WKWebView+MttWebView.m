//
//  WKWebView+MttWebView.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "WKWebView+MttWebView.h"
#import <objc/runtime.h>
#import "MTKObserving.h"
#import "UIScrollViewDelegateProxy.h"
#import "MttScriptMessageHandler.h"

@implementation WKWebView (MttWebView)

- (void)setupWebView
{
    self.navigationDelegate = self;
    self.UIDelegate = self;
    [self observeProperty:@keypath(self.estimatedProgress) withBlock:^(__weak typeof(self) self, id old, id newVal) {
        if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:didReceiveProgress:)]) {
            [self.mttWebViewDelegate mttWebView:self didReceiveProgress:self.estimatedProgress];
        }
    }];
}

- (void)destroyWebView
{
    [self removeAllObservations];
}

- (id<MttWebViewDelegate>)mttWebViewDelegate
{
    return objc_getAssociatedObject(self, @selector(mttWebViewDelegate));
}

- (void)setMttWebViewDelegate:(id<MttWebViewDelegate>)mttWebViewDelegate
{
    objc_setAssociatedObject(self, @selector(mttWebViewDelegate), mttWebViewDelegate, OBJC_ASSOCIATION_ASSIGN);
    
    UIScrollViewDelegateProxy *proxy = [self scrollViewDelegateProxy];
    if (proxy.proxyObject != mttWebViewDelegate) {
        if (mttWebViewDelegate == nil) {
            proxy = nil;
        }
        else {
            proxy = [[UIScrollViewDelegateProxy alloc] initWithOriginObject:self.scrollView.delegate proxyObject:mttWebViewDelegate];
        }
        [self setScrollViewDelegateProxy:proxy];
        
        self.scrollView.delegate = proxy;
    }
}

- (BOOL)scalesPageToFit
{
    return NO;
}

- (void)setScalesPageToFit:(BOOL) setPages
{
    return; // not supported in WKWebView
}

- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler
{
    WKUserContentController *userContentController = self.configuration.userContentController;
    
    MttScriptMessageHandler *scriptMessageHandler = [self scriptMessageHandler];
    if (!scriptMessageHandler) {
        scriptMessageHandler = [MttScriptMessageHandler new];
        [self setScriptMessageHandler:scriptMessageHandler];
    }
    [scriptMessageHandler addScriptMessage:scriptMessage handler:handler];
    [userContentController addScriptMessageHandler:scriptMessageHandler name:scriptMessage];
    
    NSString *jsFormat = @"function %@() {var that = webkit.messageHandlers.%@; that.postMessage.apply(that, [JSON.stringify(Array.prototype.slice.call(arguments))]);}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[NSString stringWithFormat:jsFormat, scriptMessage, scriptMessage]
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:YES];
    [userContentController addUserScript:userScript];
    if (self.URL != nil) {
        [self evaluateJavaScript:userScript.source completionHandler:nil];
    }
}


#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL allow = YES;
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:decidePolicyWithRequest:navigationType:isMainFrame:)]) {
        allow = [self.mttWebViewDelegate mttWebView:self
                            decidePolicyWithRequest:navigationAction.targetFrame.request
                                     navigationType:(NSInteger)navigationAction.navigationType
                                        isMainFrame:navigationAction.targetFrame.isMainFrame];
    }
    if (decisionHandler) {
        decisionHandler(allow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebViewDidStartProvisionalNavigation:)]) {
        [self.mttWebViewDelegate mttWebViewDidStartProvisionalNavigation:self];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebViewDidCommitNavigation:)]) {
        [self.mttWebViewDelegate mttWebViewDidCommitNavigation:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebViewDidFinishNavigation:)]) {
        [self.mttWebViewDelegate mttWebViewDidFinishNavigation:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:didFailNavigationWithError:)]) {
        [self.mttWebViewDelegate mttWebView:self didFailNavigationWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:didFailNavigationWithError:)]) {
        [self.mttWebViewDelegate mttWebView:self didFailNavigationWithError:error];
    }
}

#pragma mark WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:createWebViewWithConfiguration:withRequest:navigationType:isMainFrame:)]) {
        return (WKWebView *)[self.mttWebViewDelegate mttWebView:self createWebViewWithConfiguration:configuration
                                                    withRequest:navigationAction.targetFrame.request
                                                 navigationType:(NSInteger)navigationAction.navigationType
                                                    isMainFrame:navigationAction.targetFrame.isMainFrame];
    }
    else {
        return nil;
    }
}

#pragma mark Private
- (UIScrollViewDelegateProxy *)scrollViewDelegateProxy
{
    return objc_getAssociatedObject(self, @selector(scrollViewDelegateProxy));
}

- (void)setScrollViewDelegateProxy:(UIScrollViewDelegateProxy *)scrollViewDelegateProxy
{
    objc_setAssociatedObject(self, @selector(scrollViewDelegateProxy), scrollViewDelegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MttScriptMessageHandler *)scriptMessageHandler
{
    return objc_getAssociatedObject(self, @selector(scriptMessageHandler));
}

- (void)setScriptMessageHandler:(MttScriptMessageHandler *)scriptMessageHandler
{
    objc_setAssociatedObject(self, @selector(scriptMessageHandler), scriptMessageHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

