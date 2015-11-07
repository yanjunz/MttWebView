//
//  MttScriptMessageHandler.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 7/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttScriptMessageHandler.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MttScriptMessageHandler ()
@property (nonatomic, strong) JSContext *context;
@end

@implementation MttScriptMessageHandler

- (instancetype)init
{
    if (self = [super init]) {
        self.context = [[JSContext alloc] init];
    }
    return self;
}

- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler
{
    self.context[scriptMessage] = handler;
}

#pragma mark WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"scriptMessage %@ %@ %@", message.name, message.body, [message.body class]);
    NSString *js = [NSString stringWithFormat:@"%@.apply(null, JSON.parse('%@'))", message.name, message.body ?: @""];
    [self.context evaluateScript:js];
}

@end
