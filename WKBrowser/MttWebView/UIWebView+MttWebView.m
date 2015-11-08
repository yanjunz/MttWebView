//
//  UIWebView+MttWebView.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "UIWebView+MttWebView.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIScrollViewDelegateProxy.h"
#import "NSObject+MttExt.h"

@implementation UIWebView (MttWebView)

#pragma mark MttWebView
- (instancetype)initWithFrame:(CGRect)frame configuration:(id)configuration
{
    if (self = [self initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setupWebView
{
    self.delegate = self;
}

- (void)destroyWebView
{
    
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

- (NSURL *) URL
{
    return [[self request] URL];
}

- (NSString *)title
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (double)estimatedProgress
{
    return [objc_getAssociatedObject(self, @selector(estimatedProgress)) doubleValue];
}

- (void)setEstimatedProgress:(double)estimatedProgress
{
    objc_setAssociatedObject(self, @selector(estimatedProgress), @(estimatedProgress), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:didReceiveProgress:)]) {
        [self.mttWebViewDelegate mttWebView:self didReceiveProgress:estimatedProgress];
    }
}


/*
 * Simple way to implement WKWebView's JavaScript handling in UIWebView.
 * Just evaluates the JavaScript and passes the result to completionHandler, if it exists.
 * Since this is defined in FLWebViewProvider, we can call this method regardless of the web view used.
 */
- (void) evaluateJavaScript: (NSString *) javaScriptString completionHandler: (void (^)(id, NSError *)) completionHandler
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString: javaScriptString];
    
    if (completionHandler) {
        completionHandler(string, nil);
    }
}

- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler
{
    [self mttJavaScriptContext][scriptMessage] = handler;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    __block BOOL ret = YES;
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:decidePolicyWithRequest:navigationType:isMainFrame:decisionHandler:)]) {
        MttWebViewNavigationType mttNavigationType = navigationType == UIWebViewNavigationTypeOther ? MttWebViewNavigationTypeOther : (NSInteger)navigationType;
        BOOL isMainFrame = [request.URL.absoluteString isEqualToString:webView.URL.absoluteString];
        [self.mttWebViewDelegate mttWebView:self decidePolicyWithRequest:request navigationType:mttNavigationType isMainFrame:isMainFrame decisionHandler:^(BOOL allow) {
            ret = allow;
        }];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebViewDidStartProvisionalNavigation:)]) {
        [self.mttWebViewDelegate mttWebViewDidStartProvisionalNavigation:webView];
    }
    
    self.estimatedProgress = 0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebViewDidCommitNavigation:)]) {
        [self.mttWebViewDelegate mttWebViewDidCommitNavigation:webView];
    }
    
    self.estimatedProgress = 1;
    
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebViewDidFinishNavigation:)]) {
        [self.mttWebViewDelegate mttWebViewDidFinishNavigation:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    self.estimatedProgress = 1;
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:didFailNavigationWithError:)]) {
        [self.mttWebViewDelegate mttWebView:webView didFailNavigationWithError:error];
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

- (JSContext *)mttJavaScriptContext
{
    return [self findValueForKeyPathCrumbs:@[@"documentV", @"iew.webView.m",@"ainFrame.java", @"ScriptContext"]];
}

@end
