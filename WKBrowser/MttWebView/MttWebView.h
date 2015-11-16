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

#define MTT_FEATURE_WKWEBVIEW
#define MTT_TWEAK_WEBCONTENTVIEW_FIX

@protocol MttWebView;

typedef NS_ENUM(NSInteger, MttWebViewNavigationType) {
    MttWebViewNavigationTypeLinkClicked,
    MttWebViewNavigationTypeFormSubmitted,
    MttWebViewNavigationTypeBackForward,
    MttWebViewNavigationTypeReload,
    MttWebViewNavigationTypeFormResubmitted,
    MttWebViewNavigationTypeOther = -1,
};

#if defined(__DEBUG__) || defined(DEBUG)
#define WVLog(xx, ...) NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define WVLog(xx, ...)
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"

@protocol MttWebViewDelegate <UIScrollViewDelegate>
@optional
// Navigation Delegate
/**
 * Ask delegate to decide whether MttWebView go on with the request. It is also a replacement for shouldStartLoadWithRequest in UIWebView
 *
 * NOTE: Why use decisionHandler instead of return value?
 * #1 since WKWebView should not allow addUserScript within decidePolicy
 * #2 decision should be called ASAP so that WebView can request asynchronously
 **/
- (void)mttWebView:(id<MttWebView>)webView decidePolicyWithRequest:(NSURLRequest *)request
    navigationType:(MttWebViewNavigationType)navigationType
       isMainFrame:(BOOL)isMainFrame
   decisionHandler:(void (^)(BOOL allow))decisionHandler;

- (void)mttWebView:(id<MttWebView>)webView didReceiveProgress:(CGFloat)progressValue;

// 页面开始加载时调用
- (void)mttWebViewDidStartProvisionalNavigation:(id<MttWebView>)webView;
// 当内容开始返回时调用
- (void)mttWebViewDidCommitNavigation:(id<MttWebView>)webView;
// 在发送请求之前，决定是否跳转
- (void)mttWebViewDidFinishNavigation:(id<MttWebView>)webView;
// 页面加载完成之后调用
- (void)mttWebView:(id<MttWebView>)webView didFailNavigationWithError:(NSError *)error;

// Ask for new WebView
- (id<MttWebView>)mttWebView:(id<MttWebView>)webView createWebViewWithConfiguration:(id)configuration
                 withRequest:(NSURLRequest *)request
              navigationType:(MttWebViewNavigationType)navigationType
                 isMainFrame:(BOOL)isMainFrame;
@end

@protocol MttWebView <NSObject>

@property (nonatomic, readonly, strong) NSURL *URL;

@property (nonatomic, readonly, copy) NSString *title;

@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;

@property (nonatomic) BOOL scalesPageToFit;

@property (nonatomic, readonly, strong) UIScrollView *scrollView;

@property (nonatomic, weak) id<MttWebViewDelegate> mttWebViewDelegate;


- (instancetype)initWithFrame:(CGRect)frame configuration:(id)configuration;

- (void)setupWebView;

- (void)loadRequest: (NSURLRequest *) request;

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

- (BOOL)canGoBack;

- (BOOL)canGoForward;

- (void)goBack;

- (void)goForward;

- (void)reload;

- (void)stopLoading;

- (void)evaluateJavaScript: (NSString *) javaScriptString completionHandler: (void (^)(id ret, NSError *error)) completionHandler;

- (void)addScriptMessage:(NSString *)scriptMessage handler:(id)handler;

@end

#pragma clang diagnostic pop

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

#define AS_MttWebView_Category(category)    @interface UIView (category)
#define DEF_MttWebView_Category(category)   @implementation UIView (category)

#else // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER

typedef UIView<MttWebView>  MttWebView;

#define AS_MttWebView_Category(category)    @interface UIView (category)
#define DEF_MttWebView_Category(category)   @implementation UIView (category)

#endif // MTT_FEATURE_MTTWEBVIEW_AS_CLASS_CLUSTER


// Macro to define property in category conviniently
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

// For primitive type, eg. BOOL & Integer
#define DEF_CATEGORY_PROPERTY_PRIMITIVE(type, name, uppercaseFirstName) \
- (type)name { \
    return (type)[objc_getAssociatedObject(self, @selector(name)) integerValue]; \
} \
- (void)set##uppercaseFirstName:(type)name { \
    objc_setAssociatedObject(self, @selector(name), @(name), OBJC_ASSOCIATION_ASSIGN); \
}
