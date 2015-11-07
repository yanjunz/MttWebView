//
//  MttMainViewController.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttMainViewController.h"
#import "MttBrowserWindowManager.h"
#import "MttNotifications.h"
#import <objc/runtime.h>

@interface MttMainViewController ()
@property (nonatomic, strong) MttBrowserWindowController *currentBrowserWindow;
@end

@implementation MttMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Method method = class_getInstanceMethod(self.class, @selector(viewDidLoad));
    IMP imp = method_getImplementation(method);
    NSLog(@"imp = %p", imp);
    
    
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBrowserWindowStateChanged:) name:kBrowserWindowStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBrowserWindowProgressChanged:) name:kBrowserWindowProgressChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCountOfBrowserWindowChanged:) name:kCountOfBrowserWindowChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurrentBrowserWindowChanged:) name:kCurrentBrowserWindowChangedNotification object:nil];
    
    
    MttBrowserWindowManager *mgr = [MttBrowserWindowManager sharedInstance];
    mgr.currentBrowserWindow = [mgr createNewBrowserWindowAfter:nil withConfiguration:[WKWebViewConfiguration new]]; // the first one
    [self changeBrowserWindow];
    
    [self.addressBar update];
    [self.currentBrowserWindow.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mail.163.com"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private
- (void)changeBrowserWindow
{
    MttBrowserWindowManager *mgr = [MttBrowserWindowManager sharedInstance];
    MttBrowserWindowController *browserWindow = mgr.currentBrowserWindow;
    if (self.currentBrowserWindow && self.currentBrowserWindow != browserWindow) {
        [self.currentBrowserWindow.view removeFromSuperview];
        [self.currentBrowserWindow removeFromParentViewController];
    }

    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.addressBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.addressBar.frame));
    
    browserWindow.view.frame = frame;
    [self.view addSubview:browserWindow.view];
    [self addChildViewController:browserWindow];
    
    self.currentBrowserWindow = browserWindow;
}


#pragma mark MttAddressBarDelegate
- (void)addressBar:(MttAddressBar *)addressBar didFinishWithText:(NSString *)text
{
    [[MttBrowserWindowManager sharedInstance].currentBrowserWindow.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:text]]];
}

- (void)addressBarDidGoBack:(MttAddressBar *)addressBar
{
    [[MttBrowserWindowManager sharedInstance].currentBrowserWindow.webView goBack];
}

- (void)addressBarDidGoForward:(MttAddressBar *)addressBar
{
    [[MttBrowserWindowManager sharedInstance].currentBrowserWindow.webView goForward];
}

#pragma mark MttAddressBarDataSource
- (BOOL)addressBarCanGoBack:(MttAddressBar *)addressBar
{
    return [MttBrowserWindowManager sharedInstance].currentBrowserWindow.webView.canGoBack;
}

- (BOOL)addressBarCanGoForward:(MttAddressBar *)addressBar
{
    return [MttBrowserWindowManager sharedInstance].currentBrowserWindow.webView.canGoForward;
}

- (NSInteger)addressBarCountOfBrowserWindow:(MttAddressBar *)addressBar
{
    return [[MttBrowserWindowManager sharedInstance] countOfBrowserWindows];
}

- (CGFloat)addressBarProgressOfBrowserWindow:(MttAddressBar *)addressBar
{
    return self.currentBrowserWindow.webView.estimatedProgress;
}

#pragma mark 
- (void)onBrowserWindowStateChanged:(NSNotification *)notif
{
    if (notif.userInfo[kBrowserWindowKey] == self.currentBrowserWindow) {
        [self.addressBar update];
    }
}

- (void)onBrowserWindowProgressChanged:(NSNotification *)notif
{
    if (notif.userInfo[kBrowserWindowKey] == self.currentBrowserWindow) {
        [self.addressBar update];
    }
}

- (void)onCountOfBrowserWindowChanged:(NSNotification *)notif
{
    [self.addressBar update];
}

- (void)onCurrentBrowserWindowChanged:(NSNotification *)notif
{
    [self changeBrowserWindow];
}

@end
