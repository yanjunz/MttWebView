//
//  MttWebViewFactory.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttWebViewFactory.h"
#import "MttWebView.h"
#import <WebKit/WebKit.h>
#import "UIWebView+MttWebView.h"
#import "WKWebView+MttWebView.h"

@implementation MttWebViewFactory

+ (MttWebView *)createWebViewWithConfiguration:(id)configuration
{
    MttWebView *webView;
 
#ifdef MTT_FEATURE_WKWEBVIEW
    if ([self isWKWebViewEnabled] && NSClassFromString(@"WKWebView")) {
        if (configuration == nil) {
            configuration = [[WKWebViewConfiguration alloc] init];
        }
        webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    }
#endif // MTT_FEATURE_WKWEBVIEW
    
    if (webView == nil) {
        webView = [[UIWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    }
    
    
    [webView setupWebView];
    return webView;
}

+ (BOOL)isWKWebViewEnabled
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"wkWebViewEnabled" : @(YES)}];
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"wkWebViewEnabled"];
}

+ (void)setWKWebViewEnabled:(BOOL)wkWebViewEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:wkWebViewEnabled forKey:@"wkWebViewEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

