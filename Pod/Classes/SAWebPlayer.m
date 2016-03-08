//
//  SAWebPlayer.m
//  Pods
//
//  Created by Gabriel Coman on 06/03/2016.
//
//

#import "SAWebPlayer.h"

#define BASIC_AD_HTML @"<html><head></head><body><img src='https://ads.superawesome.tv/v2/demo_images/320x50.jpg'/></body></html>"

@interface SAWebPlayer () <UIScrollViewDelegate>

// ad view internal stuff
@property (nonatomic, strong) NSString *adHtml;
@property (nonatomic, assign) CGSize adSize;
@property (nonatomic, assign) CGFloat scalingFactor;
@property (nonatomic, assign) BOOL loadedOnce;

@end

@implementation SAWebPlayer

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
    }
    
    return self;
}

- (void) setAdSize:(CGSize)adSize {
    _adSize = adSize;
#pragma mark SA_SDK_SPECIFIC
    CGFloat xscale = self.frame.size.width / _adSize.width;
    CGFloat yscale = self.frame.size.height / _adSize.height;
    _scalingFactor = MIN(xscale, yscale);
}

- (void) loadAdHTML:(NSString *)adHtml {
    _adHtml = adHtml;
#pragma mark SA_SDK_SPECIFIC
    _adHtml = [_adHtml stringByReplacingOccurrencesOfString:@"_WIDTH_" withString:[NSString stringWithFormat:@"%ld", (long)_adSize.width]];
    _adHtml = [_adHtml stringByReplacingOccurrencesOfString:@"_HEIGHT_" withString:[NSString stringWithFormat:@"%ld", (long)_adSize.height]];
    _adHtml = [_adHtml stringByReplacingOccurrencesOfString:@"_PARAM_SCALE_" withString:[NSString stringWithFormat:@"%.2f", _scalingFactor]];
    [self loadHTMLString:_adHtml baseURL:NULL];
}

- (void) updateToFrame:(CGRect)frame {
    
    // set frame
    self.frame = frame;
    
#pragma mark SA_SDK_SPECIFIC
    // set scale
    CGFloat xscale = frame.size.width / _adSize.width;
    CGFloat yscale = frame.size.height / _adSize.height;
    _scalingFactor = MIN(xscale, yscale);
    
    NSMutableString *script = [[NSMutableString alloc] init];
    [script appendString:@"viewport = document.querySelector('meta[name=viewport]');"];
    [script appendFormat:@"viewport.setAttribute('content', 'width=device-width, initial-scale=%.2f, maximum-scale=%.2f, user-scalable=no, target-densitydpi=device-dpi');", _scalingFactor, _scalingFactor];
    
    [self stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
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
    
    if (!shouldContinue) {
        
        // send a click message
        NSURL *url = [request URL];
        if (_sadelegate != NULL && [_sadelegate respondsToSelector:@selector(webPlayerWillNavigate:)]) {
            [_sadelegate webPlayerWillNavigate:url];
        }
        
        return false;
    }
    
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // do nothing
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // call delegate
    if (_sadelegate != NULL && [_sadelegate respondsToSelector:@selector(webPlayerDidLoad)] && !_loadedOnce) {
        [_sadelegate webPlayerDidLoad];
        _loadedOnce = true;
    }
}

- (void) webView:(UIWebView*) webView didFailLoadWithError:(NSError *)error {
    if (_sadelegate != NULL && [_sadelegate respondsToSelector:@selector(webPlayerDidFail)]) {
        [_sadelegate webPlayerDidFail];
    }
}

#pragma mark <UIScrollViewDelegate>

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

@end
