//
//  MttWebView+Utils.h
//  MttHD
//
//  Created by Yanjun Zhuang on 6/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MttWebView.h"

#define WeakSelf __weak typeof(self)

typedef void(^MttSuccessBlock)       (__weak id self, id ret);
typedef void(^MttFailBlock)          (__weak id self, NSError *error);

AS_MttWebView_Category(Utils)

- (MttWebView *)asWebView;

- (NSString *)mttMainFrameURLString;
- (NSString *)mttMainFrameTitle;

- (UIView *)mttWebContentView;


- (void)evaluateJavaScript:(NSString *)javaScriptString successHandler:(MttSuccessBlock)successHandler failHandler:(MttFailBlock)failHandler;

// Deprecated! Just for debug
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
@end
