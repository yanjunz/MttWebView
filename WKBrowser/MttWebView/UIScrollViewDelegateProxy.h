//
//  UIScrollViewDelegateProxy.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIScrollViewDelegateProxy : NSObject<UIScrollViewDelegate>
@property (nonatomic, weak) id<UIScrollViewDelegate> originObject;
@property (nonatomic, weak) id<UIScrollViewDelegate> proxyObject;

- (instancetype)initWithOriginObject:(id<UIScrollViewDelegate>)originObject
                         proxyObject:(id<UIScrollViewDelegate>)proxyObject;
@end
