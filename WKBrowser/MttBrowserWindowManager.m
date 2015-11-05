//
//  MttBrowserWindowManager.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttBrowserWindowManager.h"
#import "MttNotifications.h"

@interface MttBrowserWindowManager ()
@end

@implementation MttBrowserWindowManager
DEF_SINGLETON(MttBrowserWindowManager)

- (instancetype)init
{
    if (self = [super init]) {
        self.browserWindows = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (MttBrowserWindowController *)createNewBrowserWindowAfter:(MttBrowserWindowController *)theBrowserWindow withConfiguration:(WKWebViewConfiguration *)conf
{
    MttBrowserWindowController *browserWindow = [[MttBrowserWindowController alloc] initWithConfiguration:conf];
    if (theBrowserWindow) {
        NSInteger index = [self.browserWindows indexOfObject:theBrowserWindow];
        if (index >= 0) {
            [self.browserWindows insertObject:browserWindow atIndex:index];
        }
        else {
            [self.browserWindows addObject:browserWindow];
        }
    }
    else {
        [self.browserWindows addObject:browserWindow];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCountOfBrowserWindowChangedNotification object:nil];
    
    return browserWindow;
}

- (NSInteger)countOfBrowserWindows
{
    return self.browserWindows.count;
}

- (void)setCurrentBrowserWindow:(MttBrowserWindowController *)currentBrowserWindow
{
    if (_currentBrowserWindow != currentBrowserWindow) {
        _currentBrowserWindow = currentBrowserWindow;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentBrowserWindowChangedNotification object:nil];
    }
}

@end
