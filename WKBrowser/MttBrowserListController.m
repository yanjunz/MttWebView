//
//  MttBrowserListController.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttBrowserListController.h"
#import "MttBrowserWindowManager.h"
#import "MttBrowserItemCell.h"

@interface MttBrowserListController ()

@end

@implementation MttBrowserListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.tableView registerClass:[MttBrowserItemCell class] forCellReuseIdentifier:@"BrowserItemCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[MttBrowserWindowManager sharedInstance] countOfBrowserWindows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MttBrowserWindowController *browserWindow = [MttBrowserWindowManager sharedInstance].browserWindows[indexPath.row];
    MttBrowserItemCell *cell = (MttBrowserItemCell *)[tableView dequeueReusableCellWithIdentifier:@"BrowserItemCell" forIndexPath:indexPath];
    cell.thumbnailView.backgroundColor = [UIColor grayColor];
    cell.titleLabel.text = browserWindow.webView.title;
    for (UIView *view in cell.thumbnailView.subviews) {
        [view removeFromSuperview];
    }
    UIView *snapshotView = [browserWindow.webView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = cell.thumbnailView.bounds;
    snapshotView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.thumbnailView addSubview:snapshotView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MttBrowserWindowManager *mgr = [MttBrowserWindowManager sharedInstance];
    mgr.currentBrowserWindow = mgr.browserWindows[indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
