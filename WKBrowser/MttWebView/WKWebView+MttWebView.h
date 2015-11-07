//
//  WKWebView+MttWebView.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "MttWebView.h"

@interface WKWebView (MttWebView) <MttWebView, WKNavigationDelegate, WKUIDelegate>

@end
