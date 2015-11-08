//
//  MttWebView.h
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//#define MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER

@protocol MttWebView;

typedef NS_ENUM(NSInteger, MttWebViewNavigationType) {
    MttWebViewNavigationTypeLinkClicked,
    MttWebViewNavigationTypeFormSubmitted,
    MttWebViewNavigationTypeBackForward,
    MttWebViewNavigationTypeReload,
    MttWebViewNavigationTypeFormResubmitted,
    MttWebViewNavigationTypeOther
};

@protocol MttWebViewDelegate <UIScrollViewDelegate>
// Navigation Delegate
- (BOOL)mttWebView:(id<MttWebView>)webView decidePolicyWithRequest:(NSURLRequest *)request
    navigationType:(MttWebViewNavigationType)navigationType
       isMainFrame:(BOOL)isMainFrame;

//- (void)mttWebView:(id<MttWebView>)webView didReceiveTitle:(NSString *)title;
- (void)mttWebView:(id<MttWebView>)webView didReceiveProgress:(CGFloat)progressValue;

/* mainfarme 开始load */
- (void)mttWebViewDidStartProvisionalNavigation:(id<MttWebView>)webView;
/* mainframe内容到了 */
- (void)mttWebViewDidCommitNavigation:(id<MttWebView>)webView;
/* mainframe加载结束 */
- (void)mttWebViewDidFinishNavigation:(id<MttWebView>)webView;
/* mainframe加载出错 */
- (void)mttWebView:(id<MttWebView>)webView didFailNavigationWithError:(NSError *)error;

// UI Delegate
- (id<MttWebView>)mttWebView:(id<MttWebView>)webView createWebViewWithConfiguration:(id)configuration
                 withRequest:(NSURLRequest *)request
              navigationType:(MttWebViewNavigationType)navigationType
                 isMainFrame:(BOOL)isMainFrame;
@end

@protocol MttWebView <NSObject>

@property (nonatomic, readonly, strong) NSURL *URL;

@property (nonatomic, readonly, copy) NSString *title;

@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic) BOOL scalesPageToFit;

@property (nonatomic, readonly, strong) UIScrollView *scrollView;

@property (nonatomic, weak) id<MttWebViewDelegate> mttWebViewDelegate;


- (instancetype)initWithFrame:(CGRect)frame configuration:(id)configuration;

- (void)setupWebView;

- (void)destroyWebView;

- (void)loadRequest: (NSURLRequest *) request;

- (BOOL)canGoBack;

- (BOOL)canGoForward;

- (void)goBack;

- (void)goForward;

- (void)reload;

- (void)stopLoading;

- (void)evaluateJavaScript: (NSString *) javaScriptString completionHandler: (void (^)(id ret, NSError *error)) completionHandler;

- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler;

@end



/**
 * Macro to define MttWebView category.
 * Since base class is UIView<MttWebView>(just category) or MttWebView(class cluster), use these macro to make code more readable
 * Usage:
 *   for Utils category for MttWebView, create file with name MttWebView+Utils.h/m
 *   add AS_MttWebView_Category(Utils) and DEF_MttWebView_Category(Utils) in the begining of .h and .m
 **/

#ifdef MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER

@interface MttWebView : UIView<MttWebView>
@end

#define AS_MttWebView_Category(category)    @interface MttWebView (category)
#define DEF_MttWebView_Category(category)   @implementation MttWebView (category)

#else // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER

typedef UIView<MttWebView>  MttWebView;

#define AS_MttWebView_Category(category)    @interface UIView (category)
#define DEF_MttWebView_Category(category)   @implementation UIView (category)

#endif // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER



#define DEF_CATEGORY_PROPERTY(type, name, uppercaseFirstName, propType) \
- (type)name { \
    return objc_getAssociatedObject(self, @selector(name)); \
} \
- (void)set##uppercaseFirstName:(type)name { \
    objc_setAssociatedObject(self, @selector(name), name, propType); \
}

// For weak delegate & dataSource
#define DEF_CATEGORY_PROPERTY_WEAK(type, name, uppercaseFirstName) \
    DEF_CATEGORY_PROPERTY(type, name, uppercaseFirstName, OBJC_ASSOCIATION_ASSIGN)

// For strong var
#define DEF_CATEGORY_PROPERTY_RETAIN_NONATOMIC(type, name, uppercaseFirstName) \
    DEF_CATEGORY_PROPERTY(type, name, uppercaseFirstName, OBJC_ASSOCIATION_RETAIN_NONATOMIC)

// For BOOL & Integer
#define DEF_CATEGORY_PROPERTY_PRIMITIVE(type, name, uppercaseFirstName) \
- (type)name { \
    return objc_getAssociatedObject(self, @selector(name)); \
} \
- (void)set##uppercaseFirstName:(type)name { \
    objc_setAssociatedObject(self, @selector(name), @(name), OBJC_ASSOCIATION_ASSIGN); \
}
