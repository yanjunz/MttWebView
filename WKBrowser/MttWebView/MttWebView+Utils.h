//
//  MttWebView+Utils.h
//  MttHD
//
//  Created by Yanjun Zhuang on 6/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MttWebView.h"

typedef void(^MttSuccessBlock)       (__weak MttWebView *webView, id ret);
typedef void(^MttFailBlock)          (__weak MttWebView *webView, NSError *error);

AS_MttWebView_Category(Utils)

- (MttWebView *)asWebView;

- (NSString *)mttMainFrameURLString;
- (NSString *)mttMainFrameTitle;

- (UIView *)mttWebContentView;


- (void)evaluateJavaScript:(NSString *)javaScriptString successHandler:(MttSuccessBlock)successHandler failHandler:(MttFailBlock)failHandler;
- (void)evaluateJavaScript:(NSString *)javaScriptString;

// Deprecated! Just for old code migration
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end
