//
//  UIScrollViewDelegateProxy.m
//  WKBrowser
//
//  Created by Yanjun Zhuang on 5/11/15.
//  Copyright © 2015 Tencent. All rights reserved.
//

#import "UIScrollViewDelegateProxy.h"

@implementation UIScrollViewDelegateProxy
- (instancetype)initWithOriginObject:(id<UIScrollViewDelegate>)originObject
                         proxyObject:(id<UIScrollViewDelegate>)proxyObject
{
    if (self = [super init]) {
        self.originObject = originObject;
        self.proxyObject = proxyObject;
        NSLog(@"UIScrollViewDelegateProxy %@ %@", originObject, proxyObject);
    }
    return self;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView // any offset changes
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidScroll:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView // any zoom scale changes
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidZoom:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidZoom:scrollView];
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewWillBeginDragging:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewWillBeginDragging:scrollView];
    }
}

// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView   // called on finger up as we are moving
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewWillBeginDecelerating:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView      // called when scroll view grinds to a halt
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidEndDecelerating:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidEndScrollingAnimation:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView     // return a view that will be scaled. if delegate returns nil, nothing happens
{
    if ([self.originObject respondsToSelector:_cmd]) {
        return [self.originObject viewForZoomingInScrollView:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        return [self.proxyObject viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view // called before the scroll view begins zooming its content
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewWillBeginZooming:scrollView withView:view];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale // scale between minimum and maximum. called after any 'bounce' animations
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView   // return a yes if you want to scroll to the top. if not defined, assumes YES
{
    if ([self.originObject respondsToSelector:_cmd]) {
        return [self.originObject scrollViewShouldScrollToTop:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        return [self.proxyObject scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([self.originObject respondsToSelector:_cmd]) {
        [self.originObject scrollViewDidScrollToTop:scrollView];
    }
    if ([self.proxyObject respondsToSelector:_cmd]) {
        [self.proxyObject scrollViewDidScrollToTop:scrollView];
    }
}

@end
