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

- (void)evaluateJavaScript:(NSString *)javaScriptString
{
    [self evaluateJavaScript:javaScriptString successHandler:nil failHandler:nil];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
#if defined(__DEBUG__) || defined(DEBUG)
    NSString *shortOne = script;
    if (shortOne.length > 30) {
        shortOne = [NSString stringWithFormat:@"%@...%@", [script substringToIndex:15], [script substringFromIndex:shortOne.length - 15]];
    }
#endif // 
    WVLog(@"[MttWebView] stringByEvaluatingJavaScriptFromString... \n%@\n", shortOne);
    
    __block id evalResult = nil;
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    
    [[self asWebView] evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        WVLog(@"[MttWebView] evaluateJavaScript %@ %@ for %@", result, error, shortOne);
        evalResult = result;
        dispatch_semaphore_signal(waitSemaphore);
    }];
    
    NSDate *bailTime = [NSDate dateWithTimeIntervalSinceNow:2.5];
    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW)) {
        if ([bailTime compare:[NSDate date]] == NSOrderedAscending)
            return @"";
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    WVLog(@"[MttWebView] stringByEvaluatingJavaScriptFromString Done! %@", shortOne);
    return evalResult ? [evalResult description] : @"";
}

@end
