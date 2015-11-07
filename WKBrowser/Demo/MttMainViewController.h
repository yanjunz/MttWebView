//
//  MttMainViewController.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 3/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "MttAddressBar.h"

@interface MttMainViewController : UIViewController<MttAddressBarDelegate, MttAddressBarDataSource>
@property (nonatomic, weak) IBOutlet MttAddressBar *addressBar;
@end
