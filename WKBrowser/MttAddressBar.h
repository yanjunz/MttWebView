//
//  MttAddressBar.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MttAddressBar;

@protocol MttAddressBarDelegate <NSObject>
- (void)addressBar:(MttAddressBar *)addressBar didFinishWithText:(NSString *)text;

- (void)addressBarDidGoBack:(MttAddressBar *)addressBar;
- (void)addressBarDidGoForward:(MttAddressBar *)addressBar;
@end

@protocol MttAddressBarDataSource <NSObject>

- (BOOL)addressBarCanGoBack:(MttAddressBar *)addressBar;
- (BOOL)addressBarCanGoForward:(MttAddressBar *)addressBar;
- (NSInteger)addressBarCountOfBrowserWindow:(MttAddressBar *)addressBar;
- (CGFloat)addressBarProgressOfBrowserWindow:(MttAddressBar *)addressBar;

@end

@interface MttAddressBar : UIView<UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet id<MttAddressBarDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<MttAddressBarDataSource> dataSource;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *forwardButton;
@property (nonatomic, strong) IBOutlet UIButton *multiWindowButton;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

- (void)update;
@end
