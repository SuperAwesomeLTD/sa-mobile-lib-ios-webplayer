/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebPlayer.h"

#define BASIC_AD_HTML @"<html><head></head><body><img src='https://ads.superawesome.tv/v2/demo_images/320x50.jpg'/></body></html>"

@interface SAWebPlayer () <UIScrollViewDelegate>

// Web Player internal variables
@property (nonatomic, strong) NSString                      *adHtml;
@property (nonatomic, assign) CGSize                        adSize;
@property (nonatomic, assign) CGFloat                       scalingFactor;
@property (nonatomic, assign) BOOL                          loadedOnce;

// strong references to the click and event handlers
@property (nonatomic, strong) saWebPlayerDidReceiveEvent   eventHandler;
@property (nonatomic, strong) saWebPlayerDidReceiveClick   clickHandler;

@end

@implementation SAWebPlayer

/**
 * Overridden "initWithFrame" method that sets up the Web Player internal state
 *
 * @param frame the view frame to assign the web player to
 * @return      a new instance of the Web Player
 */
- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _adHtml = BASIC_AD_HTML;
        _adSize = frame.size;
        
        // customize look
        self.delegate = self;
        self.scalesPageToFit = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
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

- (void) setAdSize:(CGSize)adSize {
    _adSize = adSize;
    CGFloat xscale = self.frame.size.width / _adSize.width;
    CGFloat yscale = self.frame.size.height / _adSize.height;
    _scalingFactor = MIN(xscale, yscale);
}

- (void) loadAdHTML:(NSString*)html {
    
    // copy the HTML string
    _adHtml = html;
    
    // make some changes to it
    _adHtml = [_adHtml stringByReplacingOccurrencesOfString:@"_WIDTH_" withString:[NSString stringWithFormat:@"%ld", (long)_adSize.width]];
    _adHtml = [_adHtml stringByReplacingOccurrencesOfString:@"_HEIGHT_" withString:[NSString stringWithFormat:@"%ld", (long)_adSize.height]];
    _adHtml = [_adHtml stringByReplacingOccurrencesOfString:@"_PARAM_SCALE_" withString:[NSString stringWithFormat:@"%.2f", _scalingFactor]];
    
    // call the UIWebView "loadHTMLString:baseURL:" method
    [self loadHTMLString:_adHtml baseURL:NULL];
}

- (void) updateToFrame:(CGRect)frame {
    
    // set frame
    self.frame = frame;
    
    // set scale
    CGFloat xscale = frame.size.width / _adSize.width;
    CGFloat yscale = frame.size.height / _adSize.height;
    _scalingFactor = MIN(xscale, yscale);
    
    // call Java Script in order to re-set the frame
    NSMutableString *script = [[NSMutableString alloc] init];
    [script appendString:@"viewport = document.querySelector('meta[name=viewport]');"];
    [script appendFormat:@"viewport.setAttribute('content', 'width=device-width, initial-scale=%.2f, maximum-scale=%.2f, user-scalable=no, target-densitydpi=device-dpi');", _scalingFactor, _scalingFactor];
    
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void) setEventHandler:(saWebPlayerDidReceiveEvent) handler {
    _eventHandler = handler != NULL ? handler : ^(SAWebPlayerEvent event) {};
}

- (void) setClickHandler:(saWebPlayerDidReceiveClick) handler {
    _clickHandler = handler != NULL ? handler : ^(NSURL *url) {};
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
        _eventHandler(Web_Start);
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
        _eventHandler(Web_Error);
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
