//
//  UIWebView+MttWebView.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "UIWebView+MttWebView.h"
#import <objc/runtime.h>
#import "UIScrollViewDelegateProxy.h"

@implementation UIWebView (MttWebView)

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


#pragma mark Public
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

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self.mttWebViewDelegate respondsToSelector:@selector(mttWebView:decidePolicyForNavigationType:)]) {
        return [self.mttWebViewDelegate mttWebView:self decidePolicyForNavigationType:(NSInteger)navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.estimatedProgress = 0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.estimatedProgress = 1;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    self.estimatedProgress = 1;
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
