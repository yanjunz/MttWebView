//
//  WKWebView+MttWebView.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "WKWebView+MttWebView.h"
#import "MttWebView+Utils.h"
#import <objc/runtime.h>
#import "MTKObserving.h"
#import "UIScrollViewDelegateProxy.h"
#import "MttScriptMessageHandler.h"
#import "NSObject+DeallocBlock.h"

#ifdef MTT_FEATURE_WKWEBVIEW

@implementation WKWebView (MttWebView)

- (void)setupWebView
{
    self.navigationDelegate = self;
    self.UIDelegate = self;
    
#if __DEBUG__
    // TO make sure the webView is dealloc, and no need to removeAllObservations since MTKObservor should be self managed.
    __unsafe_unretained typeof(self) weakSelf = self;
    [self addDeallocBlock:^{
        WVLog(@"destroyWebView %@", weakSelf);
//        [weakSelf removeAllObservations];
    }];
#endif
    
    [self observeProperty:@keypath(self.estimatedProgress) withBlock:^(__weak typeof(self) self, id old, id newVal) {
        WVLog(@"estimatedProgress %f", self.estimatedProgress);
        if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:didReceiveProgress:)]) {
            [self.mttWebViewDelegate mttWebView:self didReceiveProgress:self.estimatedProgress];
        }
    }];
    
#ifdef MTT_TWEAK_WEBCONTENTVIEW_FIX
    [[self.mttWebContentView.subviews firstObject] observeProperties:@[@"center", @"bounds"] withBlock:^(__weak id self, NSString *keyPath, id old, id newVal) {
        WVLog(@"[KVO] %@ %@ %@ \n\t%@ \n\t%@", keyPath, old, newVal, self, [self superview]);
        if ([@"center" isEqualToString:keyPath]) {
            CGPoint newCenter = [(NSValue *)newVal CGPointValue];
            if (newCenter.y < 0) {
                NSLog(@"Got!");
            }
            if (!CGPointEqualToPoint(newCenter, CGPointZero)) {
                [self setCenter:CGPointZero];
            }
        }
//        else if ([@"bounds" isEqualToString:keyPath]) {
//            CGRect newBounds = [(NSValue *)newVal CGRectValue];
//            if ([self superview]) {
//                CGRect parentBounds = [[self superview] bounds];
//                if (!CGRectEqualToRect(newBounds, parentBounds)) {
//                    [self setBounds:parentBounds];
//                }
//            }
//        }
    }];
#endif // MTT_TWEAK_WEBCONTENTVIEW_FIX
    
    WVLog(@"setupWebView %@", self);
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

- (void)setScalesPageToFit:(BOOL)setPages
{
//    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
//
//    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
//    WKUserContentController *wkUController = self.configuration.userContentController;
//    [wkUController addUserScript:wkUScript];
//    
//    if (self.URL != nil) {
//        [self evaluateJavaScript:jScript completionHandler:nil];
//    }
    
    return; // not supported in WKWebView
}

- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler
{
    WVLog(@"[WKWebView] addScriptMessage %@", scriptMessage);
    
    WKUserContentController *userContentController = self.configuration.userContentController;
    
    MttScriptMessageHandler *scriptMessageHandler = [self scriptMessageHandler];
    if (!scriptMessageHandler) {
        scriptMessageHandler = [MttScriptMessageHandler new];
        [self setScriptMessageHandler:scriptMessageHandler];
    }
    [scriptMessageHandler addScriptMessage:scriptMessage handler:handler];
    [userContentController removeScriptMessageHandlerForName:scriptMessage]; // Can't add if existed
    [userContentController addScriptMessageHandler:scriptMessageHandler name:scriptMessage];
    
    NSString *jsFormat = @"function %@() {var that = webkit.messageHandlers.%@; that.postMessage.apply(that, [JSON.stringify(Array.prototype.slice.call(arguments))]);}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[NSString stringWithFormat:jsFormat, scriptMessage, scriptMessage]
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                   forMainFrameOnly:YES];
    [userContentController addUserScript:userScript];
    if (self.URL != nil) {
        [self evaluateJavaScript:userScript.source];
    }
}


#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL isMainFrame = navigationAction.targetFrame ? navigationAction.targetFrame.isMainFrame : YES;
    WVLog(@"[WKWebView] decidePolicy... %@ %d", navigationAction.request, isMainFrame);
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:decidePolicyWithRequest:navigationType:isMainFrame:decisionHandler:)]) {
        [self.mttWebViewDelegate mttWebView:self
                            decidePolicyWithRequest:navigationAction.request
                                     navigationType:(NSInteger)navigationAction.navigationType
                                isMainFrame:isMainFrame decisionHandler:^(BOOL allow){
                                    NSLog(@"[WKWebView] decidePolicy done! %d", allow);
                                    if (decisionHandler) {
                                        decisionHandler(allow ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
                                    }
                                }];
    }
    else {
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
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
    BOOL isMainFrame = navigationAction.targetFrame ? navigationAction.targetFrame.isMainFrame : YES;
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:createWebViewWithConfiguration:withRequest:navigationType:isMainFrame:)]) {
        return (WKWebView *)[self.mttWebViewDelegate mttWebView:self createWebViewWithConfiguration:configuration
                                                    withRequest:navigationAction.request
                                                 navigationType:(NSInteger)navigationAction.navigationType
                                                    isMainFrame:isMainFrame];
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

#endif // #ifdef MTT_FEATURE_WKWEBVIEW
