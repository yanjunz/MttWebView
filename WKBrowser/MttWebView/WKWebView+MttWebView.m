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


#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL allow = YES;
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:decidePolicyForNavigationType:)]) {
        allow = [self.mttWebViewDelegate mttWebView:self decidePolicyForNavigationType:(NSInteger)navigationAction.navigationType];
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
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:createWebViewWithConfiguration:forNavigationType:)]) {
        return (WKWebView *)[self.mttWebViewDelegate mttWebView:self createWebViewWithConfiguration:configuration forNavigationType:(NSInteger)navigationAction.navigationType];
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

@end

