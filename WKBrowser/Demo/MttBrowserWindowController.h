//
//  MttBrowserWindowController.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MttWebViewKit.h"

@interface MttBrowserWindowController : UIViewController<
MttWebViewDelegate
//WKNavigationDelegate, WKUIDelegate
>
//@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) MttWebView *webView;
- (instancetype)initWithConfiguration:(WKWebViewConfiguration *)conf;
@end
