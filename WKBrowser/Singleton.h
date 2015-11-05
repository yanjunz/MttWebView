//
//  Singleton.h
//  mtt
//
//  Created by Zhuang Yanjun on 13-7-24.
//  Copyright (c) 2013年 Tencent. All rights reserved.
//

#ifndef mtt_Singleton_h
#define mtt_Singleton_h

#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
        + (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
        + (__class *)sharedInstance \
        { \
            static dispatch_once_t once; \
            static __class * __singleton__; \
            dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
            return __singleton__; \
        }

#endif
