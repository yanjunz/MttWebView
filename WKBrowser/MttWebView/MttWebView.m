//
//  MttWebView.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 7/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttWebView.h"
#import "MttWebViewKit.h"

#ifdef MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER

// NOTE: MttWebView is abstract class with class cluster implementation, so no need to implement protocol methods.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation MttWebView

+ (id)alloc
{
    // class cluster implementation
    if ([self class] == [MttWebView class]) {
        if (NSClassFromString(@"WKWebView")) {
            return (MttWebView *)[WKWebView alloc];
        }
        else {
            return (MttWebView *)[UIWebView alloc];
        }
    }
    return [super alloc];
}

@end

#pragma clang diagnostic pop

#endif // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER
