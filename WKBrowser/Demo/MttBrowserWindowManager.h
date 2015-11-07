//
//  MttBrowserWindowManager.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "MttBrowserWindowController.h"


@interface MttBrowserWindowManager : NSObject
AS_SINGLETON(MttBrowserWindowManager)

@property (nonatomic, weak) MttBrowserWindowController *currentBrowserWindow;
@property (nonatomic, strong) NSMutableArray *browserWindows;

- (MttBrowserWindowController *)createNewBrowserWindowAfter:(MttBrowserWindowController *)theBrowserWindow withConfiguration:(WKWebViewConfiguration *)conf;
- (NSInteger)countOfBrowserWindows;

@end
