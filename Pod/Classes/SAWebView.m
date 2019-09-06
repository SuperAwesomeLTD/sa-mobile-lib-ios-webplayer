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
    NSString *jscript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jscript
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:NO];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:userScript];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    configuration.mediaPlaybackRequiresUserAction = NO;
    configuration.userContentController = wkUController;
    
    return configuration;
}

/**
 * Overridden "viewForZoomingInScrollView:" method from the
 * UIWebViewDelegate protocol
 *
 * @param scrollView    the current scroll view of the web view
 * @return              a scrolled zoomed UIView; or nil in this case
 */
- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

@end
