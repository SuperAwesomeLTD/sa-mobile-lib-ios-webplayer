/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebView.h"

@interface SAWebView () <UIScrollViewDelegate>

// param that says the web view was once loaded
@property (nonatomic, assign) BOOL                         loadedOnce;

// strong references to the click and event handlers
@property (nonatomic, strong) saWebPlayerDidReceiveEvent   eventHandler;
@property (nonatomic, strong) saWebPlayerDidReceiveClick   clickHandler;

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
        _loadedOnce = false;
        self.delegate = self;
        self.scrollView.delegate = self;
        self.scrollView.scrollEnabled = NO;
        self.scrollView.bounces = NO;
        self.allowsInlineMediaPlayback = NO;
        self.mediaPlaybackRequiresUserAction = YES;
        _eventHandler = ^(SAWebPlayerEvent event) {};
        _clickHandler = ^(NSURL *url) {};
    }
    
    return self;
}

- (void) setEventHandler:(saWebPlayerDidReceiveEvent) handler {
    _eventHandler = handler != nil ? handler : _eventHandler;
}

- (void) setClickHandler:(saWebPlayerDidReceiveClick) handler {
    _clickHandler = handler != nil ? handler : _clickHandler;
}

/**
 * Overridden "webView:shouldStartLoadWithRequest:navigationType" method from
 * the UIWebViewDelegate protocol.
 * Here is where messages from the web view get sent to the main library code
 * and filtered for "click" events.
 * Only clicks are registered and the click handler gets called
 *
 * @param webView           the current web view that sent the message
 * @param request           the associated network request, as a NSURLRequest
 *                          object
 * @param navigationType    the type of navigation (which is not always
 *                          that accurate)
 * @return                  true or false
 */
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    BOOL shouldContinue = true;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        shouldContinue = false;
    } else {
        if ([request.URL.absoluteString rangeOfString:@"&redir=" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            shouldContinue = false;
        }
        if ([request.URL.relativeString rangeOfString:@"/v2/click"].location != NSNotFound) {
            shouldContinue = false;
        }
    }
    
    // if the request should not continue, call the click handler
    if (!shouldContinue) {
        
        NSURL *url = [request URL];
        _clickHandler(url);
        return false;
    }
    
    return true;
}

/**
 * Overridden "webViewDidStartLoad" method from
 * the UIWebViewDelegate protocol.
 *
 * @param webView   the current web view that sent the message
 */
- (void) webViewDidStartLoad:(UIWebView *)webView {
    // do nothing
}

/**
 * Overridden "webViewDidFinishLoad" method from the UIWebViewDelegate protocol.
 *
 * @param webView   the current web view that sent the message
 */
- (void) webViewDidFinishLoad:(UIWebView *)webView {
    if (!_loadedOnce) {
        _loadedOnce = true;
        _eventHandler(saWeb_Start);
    }
}

/**
 * Overridden "webView:didFailLoadWithError:" method from the
 * UIWebViewDelegate protocol.
 *
 * @param webView   the current web view that sent the message
 * @param error     the current error that cause the webview to not load
 */
- (void) webView:(UIWebView*) webView didFailLoadWithError:(NSError *)error {
    if (!_loadedOnce) {
        _loadedOnce = true;
        _eventHandler(saWeb_Error);
    }
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
