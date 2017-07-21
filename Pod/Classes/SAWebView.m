/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebView.h"

@interface SAWebView () <UIScrollViewDelegate>
@end

@implementation SAWebView

/**
 * Overridden "initWithFrame" method that sets up the Web Player internal state
 *
 * @param frame the view frame to assign the web player to
 * @return      a new instance of the Web Player
 */
- (id) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.scrollView.delegate = self;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.bounces = NO;
        self.allowsInlineMediaPlayback = YES;
        self.mediaPlaybackRequiresUserAction = NO;
    }
    
    return self;
}

/**
 * Overridden "viewForZoomingInScrollView:" method from the
 * UIWebViewDelegate protocol
 *
 * @param scrollView    the current scroll view of the web view
 * return               a scrolled zoomed UIView; or nil in this case
 */
- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

@end
