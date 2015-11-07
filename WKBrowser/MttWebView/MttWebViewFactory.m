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
    
#ifdef MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER
    
    webView = [[MttWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    
#else // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER
    
    if (NSClassFromString(@"WKWebView")) {
        webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    }
    else {
        webView = [[UIWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    }
    
#endif // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER
    
    
    [webView setupWebView];
    return webView;
}

@end

