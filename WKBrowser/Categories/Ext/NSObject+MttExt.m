//
//  NSObject+MttExt.m
//  MttHD
//
//  Created by Yanjun Zhuang on 29/10/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "NSObject+MttExt.h"

@implementation NSObject (MttExt)
- (BOOL)matchKindOfClassCrumbs:(NSArray *)classCrumbs
{
    Class cls = self.class;
    Class superClass = [cls superclass];
    BOOL match = NO;
    while (!match) {
        match = [self isClassName:NSStringFromClass(cls) matchClassCrumbs:classCrumbs];
        if (cls == superClass || !superClass) { // Reach to NSObject
            break;
        }
        else {
            cls = superClass;
            superClass = [cls superclass];
        }
    }
    return match;
}

- (BOOL)matchMemberOfClassCrumbs:(NSArray *)classCrumbs
{
    NSString *className = NSStringFromClass(self.class);
    return [self isClassName:className matchClassCrumbs:classCrumbs];
}

- (BOOL)isClassName:(NSString *)className matchClassCrumbs:(NSArray *)classCrumbs
{
    NSInteger classNameLen = className.length;
    NSInteger index = 0;
    for (NSString *crumb in classCrumbs) {
        NSInteger crumbLen = crumb.length;
        if (index + crumbLen > classNameLen ||
            ![[className substringWithRange:NSMakeRange(index, crumbLen)] isEqualToString:crumb]) {
            return NO;
        }
        index += crumbLen;
    }
    return YES;
}

- (id)findValueForKeyPathCrumbs:(NSArray *)keyPathCrumbs
{
    NSString *keyPath = [keyPathCrumbs componentsJoinedByString:@""];
    return [self valueForKeyPath:keyPath];
}

@end
