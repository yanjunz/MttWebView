//
//  MttAddressBar.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "MttAddressBar.h"

@implementation MttAddressBar

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *text = textField.text;
    if (text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(addressBar:didFinishWithText:)]) {
            [self.delegate addressBar:self didFinishWithText:textField.text];
        }
    }
    return YES;
}

- (IBAction)onGoBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addressBarDidGoBack:)]) {
        [self.delegate addressBarDidGoBack:self];
    }
}

- (IBAction)onGoForward:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addressBarDidGoForward:)]) {
        [self.delegate addressBarDidGoForward:self];
    }
}

- (void)update
{
    NSLog(@"update %d, %d", [self.dataSource addressBarCanGoBack:self], [self.dataSource addressBarCanGoForward:self]);
    self.backButton.enabled = [self.dataSource addressBarCanGoBack:self];
    self.forwardButton.enabled = [self.dataSource addressBarCanGoForward:self];
    NSInteger count = [self.dataSource addressBarCountOfBrowserWindow:self];
    [self.multiWindowButton setTitle:@(count).stringValue forState:UIControlStateNormal];
    self.progressView.progress = [self.dataSource addressBarProgressOfBrowserWindow:self];
    self.progressView.hidden = self.progressView.progress == 1;
}

@end
