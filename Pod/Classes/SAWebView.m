/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebView.h"

@interface SAWebView () <UIScrollViewDelegate>
@end

@implementation SAWebView

/**
 * Overridden "initWithFrame:configuration:" method that sets up the Web Player internal state
 *
 * @param frame         the view frame to assign the web player to
 * @param configuration the configuration for the web player
 * @return              a new instance of the Web Player
 */
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame configuration:configuration]) {
        [self configureScrollView];
    }
    return self;
}

/**
 * Overridden "initWithFrame:" method that sets up the Web Player internal state
 *
 * @param frame the view frame to assign the web player to
 * @return      a new instance of the Web Player
 */
- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureScrollView];
    }
    return self;
}

- (void) configureScrollView {
    self.scrollView.delegate = self;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = NO;
}

/**
 * "defaultConfiguration" Returns the default web player configuration,
 * to be used when initialising this web view
 *
 * @return  default configuration for the web player
 */
+ (WKWebViewConfiguration*) defaultConfiguration {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaPlaybackRequiresUserAction = NO;    
    return configuration;
}

/**
 * Overridden "viewForZoomingInScrollView:" method from the
 * UIScrollViewDelegate protocol
 *
 * @param scrollView    the current scroll view of the web view
 * @return              a scrolled zoomed UIView; or nil in this case
 */
- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

@end
