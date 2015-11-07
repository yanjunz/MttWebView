//
//  MttWebView+Utils.m
//  MttHD
//
//  Created by Yanjun Zhuang on 6/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttWebView+Utils.h"
#import "NSObject+MttExt.h"

DEF_MttWebView_Category(Utils)

- (MttWebView *)asWebView
{
    if ([self conformsToProtocol:@protocol(MttWebView)]) {
        return (MttWebView *)self;
    }
    else {
        return nil;
    }
}

- (NSString *)mttMainFrameURLString
{
    return [[self asWebView].URL absoluteString];
}

- (NSString *)mttMainFrameTitle
{
    return [self asWebView].title;
}

- (UIView *)mttWebContentView
{
    for (UIView *view in [self asWebView].scrollView.subviews) {
        if ([view matchKindOfClassCrumbs:@[@"UI", @"Web", @"Browser", @"View"]] ||  // UIWebBrowserView in UIWebView
            [view matchKindOfClassCrumbs:@[@"WK", @"Content", @"View"]]) {          // WKContentView in WKWebView
            return view;
        }
    }
    return nil;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString successHandler:(MttSuccessBlock)successHandler failHandler:(MttFailBlock)failHandler
{
    __weak id weakSelf = self;
    [[self asWebView] evaluateJavaScript:javaScriptString completionHandler:^(id ret, NSError *error) {
        if (error) {
            if (failHandler) {
                failHandler(weakSelf, error);
            }
        }
        else {
            if (successHandler) {
                successHandler(weakSelf, ret);
            }
        }
    }];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    [[self asWebView] evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultString;
}

@end
