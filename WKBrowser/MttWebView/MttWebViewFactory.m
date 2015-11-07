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
    if (!NSClassFromString(@"WKWebView")) {
        if (configuration) {
            webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        }
        else {
            webView = [[WKWebView alloc] init];
        }
    }
    else {
        webView = [[UIWebView alloc] init];
    }
    [webView setupWebView];
    return webView;
}

@end

