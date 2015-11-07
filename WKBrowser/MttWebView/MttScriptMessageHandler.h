//
//  MttScriptMessageHandler.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 7/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MttWebView.h"
#import "WKWebView+MttWebView.h"

@interface MttScriptMessageHandler : NSObject<WKScriptMessageHandler>
- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler;
@end
