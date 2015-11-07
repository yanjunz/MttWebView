//
//  MttWebViewFactory.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MttWebView.h"

@interface MttWebViewFactory : NSObject
+ (MttWebView *)createWebViewWithConfiguration:(id)configuration;
@end
