//
//  NSObject+MttExt.h
//  MttHD
//
//  Created by Yanjun Zhuang on 29/10/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MttExt)
- (BOOL)matchKindOfClassCrumbs:(NSArray *)classCrumbs;
- (BOOL)matchMemberOfClassCrumbs:(NSArray *)classCrumbs;
- (id)findValueForKeyPathCrumbs:(NSArray *)keyPathCrumbs;
@end

