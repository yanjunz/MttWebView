//
//  MttBrowserWindowController.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttBrowserWindowController.h"
#import "MttBrowserWindowManager.h"
#import "MttNotifications.h"

@interface MttBrowserWindowController ()

@end

@implementation MttBrowserWindowController

- (instancetype)initWithConfiguration:(WKWebViewConfiguration *)conf
{
    if (self = [super init]) {
//        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:conf];
        self.webView = [MttWebViewFactory createWebViewWithConfiguration:conf];
        self.webView.mttWebViewDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.frame = self.view.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.webView.navigationDelegate = self;
//    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.webView) {
        if ([keyPath isEqualToString:@"canGoBack"] || [keyPath isEqualToString:@"canGoForward"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBrowserWindowStateChangedNotification object:nil userInfo:@{kBrowserWindowKey : self}];
        }
        else if ([keyPath isEqualToString:@"estimatedProgress"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBrowserWindowProgressChangedNotification object:nil userInfo:@{kBrowserWindowKey : self}];
        }
    }
}
//
//
//#pragma mark WKUIDelegate
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    MttBrowserWindowController *newBrowserWindow = [[MttBrowserWindowManager sharedInstance] createNewBrowserWindowAfter:self withConfiguration:configuration];
//    [MttBrowserWindowManager sharedInstance].currentBrowserWindow = newBrowserWindow;
//    return newBrowserWindow.webView;
//}

#pragma mark MttWebViewDelegate
// Navigation Delegate
- (BOOL)mttWebView:(id<MttWebView>)webView decidePolicyWithRequest:(NSURLRequest *)request
    navigationType:(MttWebViewNavigationType)navigationType
       isMainFrame:(BOOL)isMainFrame
{
    NSLog(@"[MttWebView] decidePolicyWithRequest %@ %ld %d", request, (long)navigationType, isMainFrame);
    return YES;
}

/* mainfarme 开始load */
- (void)mttWebViewDidStartProvisionalNavigation:(id<MttWebView>)webView
{
    NSLog(@"[MttWebView] mttWebViewDidStartProvisionalNavigation %@", [webView URL]);
}

/* mainframe内容到了 */
- (void)mttWebViewDidCommitNavigation:(id<MttWebView>)webView
{
    NSLog(@"[MttWebView] mttWebViewDidCommitNavigation %@", [webView URL]);
}

/* mainframe加载结束 */
- (void)mttWebViewDidFinishNavigation:(id<MttWebView>)webView
{
    NSLog(@"[MttWebView] mttWebViewDidFinishNavigation %@", [webView URL]);
}

/* mainframe加载出错 */
- (void)mttWebView:(id<MttWebView>)webView didFailNavigationWithError:(NSError *)error
{
    NSLog(@"[MttWebView] didFailNavigationWithError %@ %@", [webView URL], error);
}

- (void)mttWebView:(id<MttWebView>)webView didReceiveProgress:(CGFloat)progressValue
{
    NSLog(@"[MttWebView] didReceiveProgress %@ %f", [webView URL], progressValue);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBrowserWindowProgressChangedNotification object:nil userInfo:@{kBrowserWindowKey : self}];
}

- (id<MttWebView>)mttWebView:(id<MttWebView>)webView createWebViewWithConfiguration:(id)configuration withRequest:(NSURLRequest *)request navigationType:(MttWebViewNavigationType)navigationType isMainFrame:(BOOL)isMainFrame
{
    NSLog(@"[MttWebView] createWebViewWithConfiguration %@", [webView URL]);
    MttBrowserWindowController *newBrowserWindow = [[MttBrowserWindowManager sharedInstance] createNewBrowserWindowAfter:self withConfiguration:configuration];
    [MttBrowserWindowManager sharedInstance].currentBrowserWindow = newBrowserWindow;
    return newBrowserWindow.webView;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll %@ %f", scrollView, scrollView.contentOffset.y);
}

@end
