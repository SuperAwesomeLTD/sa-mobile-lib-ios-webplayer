/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebPlayer.h"
#import "SANetwork.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SAExpandedWebPlayer.h"
#import "SAResizedWebPlayer.h"

@interface SAWebPlayer () <UIWebViewDelegate, SAMRAIDCommandProtocol, SAWebPlayerAuxProtocol>

@property (nonatomic, strong) NSString                      *html;

// param that says the web view was once loaded
@property (nonatomic, assign) BOOL                          finishedLoading;

// strong references to the click and event handlers
@property (nonatomic, strong) saWebPlayerDidReceiveEvent    eventHandler;
@property (nonatomic, strong) saWebPlayerDidReceiveClick    clickHandler;

// get the jscontext
@property (nonatomic, strong) JSContext                     *ctx;

@end

@implementation SAWebPlayer

- (id) initWithContentSize:(CGSize) contentSize
            andParentFrame:(CGRect) parentRect{
    
    // get a weak self reference
    __weak typeof (self) weakSelf = self;
    
    // init all defaults before init
    _eventHandler = ^(SAWebPlayerEvent event) {};
    _clickHandler = ^(NSURL *url) {};
    _finishedLoading = false;
    _contentSize = contentSize;
    _delegate = self;
    
    if (self = [super init]) {
        
        // clear color
        self.backgroundColor = [UIColor clearColor];
        
        // init MRAID
        _mraid = [[SAMRAID alloc] init];
        
        // create the webview and add it as a subview
        _webView = [[SAWebView alloc] initWithFrame:CGRectMake(0, 0, _contentSize.width, _contentSize.height)];
        
        _ctx = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        _ctx[@"console"][@"log"] = ^(JSValue * msg) {
            
            if ([msg isString] && [msg toString] != nil && [[msg toString] rangeOfString:@"SAMRAID_EXT"].location != NSNotFound) {
                
                NSString *jsMsg = [[msg toString] stringByReplacingOccurrencesOfString:@"SAMRAID_EXT" withString:@""];
                BOOL hasMraid = [jsMsg rangeOfString:@"mraid"].location != NSNotFound;
                [weakSelf.mraid setHasMRAID:hasMraid];
                
                if ([weakSelf.mraid hasMRAID]) {
                    [weakSelf.delegate didReceiveMessageFromJavaScript:jsMsg];
                }
            }
        };
        
        // add notfication rotation
        [[NSNotificationCenter defaultCenter] addObserverForName:@"UIDeviceOrientationDidChangeNotification"
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * note) {
                                                          [weakSelf.delegate didRotateScreen];
                                                      }];
        
        // set delegate
        _webView.delegate = self;
        
        // add subview
        [self addSubview:_webView];
        
        // update parent frame
        [self updateParentFrame:parentRect];
        
    }
    
    return self;
}

- (void) removeFromSuperview {
    // remove notification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIDeviceOrientationDidChangeNotification"
                                                  object:nil];
    
    // remove child expanded
    if (_expandedPlayer != nil) {
        [_expandedPlayer removeFromSuperview];
    }
    if (_resizedPlayer != nil) {
        [_resizedPlayer removeFromSuperview];
    }
    
    // finally remove self
    [super removeFromSuperview];
}

- (void) didReceiveMessageFromJavaScript:(NSString *)message {
    
    CGSize screen = [UIScreen mainScreen].bounds.size;
    
    [_mraid setPlacementInline];
    [_mraid setViewableTrue];
    [_mraid setScreenSize:screen];
    [_mraid setMaxSize:screen];
    [_mraid setCurrentPosition:_contentSize];
    [_mraid setDefaultPosition:_contentSize];
    [_mraid setStateToDefault];
    [_mraid setReady];
    
}

- (void) didRotateScreen {
    CGRect superFrame = self.superview.frame;
    [self updateParentFrame:superFrame];
}

- (void) updateParentFrame:(CGRect) parentRect {
    
    CGRect contentRect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
    CGRect result = [self map:contentRect into:parentRect];
    _scaleX = result.size.width / _contentSize.width;
    _scaleY = result.size.height / _contentSize.height;
    
    [self setFrame:CGRectMake(0, 0, parentRect.size.width, parentRect.size.height)];
    
    _webView.transform = CGAffineTransformMakeScale(_scaleX, _scaleY);
    _webView.center = self.center;
}

- (void) loadHTML:(NSString*)html witBase:(NSString*)base {
    // the base HTML that wraps the content html
    NSString *baseHtml = @"<html><header><style>html, body, div { margin: 0px; padding: 0px; } html, body { width:100%; height:100%; } </style></header><body>_CONTENT_</body></html>";
    
    // replace content keyword with actual content
    baseHtml = [baseHtml stringByReplacingOccurrencesOfString:@"_CONTENT_" withString:html];
    
    // copy base Html
    _html = baseHtml;
    
    // inject mraid
    [_mraid setWebView:_webView];
    [_mraid injectMRAID];
    
    // lock-and-load
    [_webView loadData:[baseHtml dataUsingEncoding:NSUTF8StringEncoding]
              MIMEType:@"text/html"
      textEncodingName:@"UTF-8"
               baseURL:[NSURL URLWithString:base]];
}

- (CGRect) map:(CGRect)sourceFrame into:(CGRect)boundingFrame {
    
    CGFloat sourceW = sourceFrame.size.width;
    CGFloat sourceH = sourceFrame.size.height;
    CGFloat boundingW = boundingFrame.size.width;
    CGFloat boundingH = boundingFrame.size.height;
    
    if (sourceW == 1 || sourceW == 0) { sourceW = boundingW; }
    if (sourceH == 1 || sourceH == 0) { sourceH = boundingH; }
    
    CGFloat sourceRatio = sourceW / sourceH;
    CGFloat boundingRatio = boundingW / boundingH;
    
    CGFloat X = 0, Y = 0, W = 0, H = 0;
    
    if (sourceRatio > boundingRatio) {
        W = boundingW;
        H = W / sourceRatio;
        X = 0;
        Y = (boundingH - H) / 2.0f;
    } else {
        H = boundingH;
        W = H * sourceRatio;
        Y = 0;
        X = (boundingW - W) / 2.0f;
    }
    
    return CGRectMake((NSInteger)X, (NSInteger)Y, (NSInteger)W, (NSInteger)H);
}

////////////////////////////////////////////////////////////////////////////////
// WebViewDelegate implementation
////////////////////////////////////////////////////////////////////////////////

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = [[request URL] absoluteString];
    
    SAMRAIDCommand *command = [[SAMRAIDCommand alloc] init];
    BOOL isMraid = [command isMRAIDComamnd:url];
    
    if (isMraid) {
     
        command.delegate = self;
        [command getQuery:url];
        
        return false;
    }
    else {
        if (_finishedLoading) {
            
            // get the request url
            NSURL *url = [request URL];
            
            // get the url as a string
            NSString *urlStr = [url absoluteString];
            
            // protect against about blanks
            if ([urlStr rangeOfString:@"about:blank"].location != NSNotFound) {
                return true;
            }
            
            // guard against iframes
            if ([urlStr rangeOfString:@"sa-beta-ads-uploads-superawesome.netdna-ssl.com"].location != NSNotFound &&
                [urlStr rangeOfString:@"/iframes"].location != NSNotFound) {
                
                NSLog(@"__WEBVIEW__: SA IFRAME");
                
                return true;
            }
            
            // check to see if the URL has a redirect, and take only the redirect
            NSRange redirLoc = [urlStr rangeOfString:@"&redir="];
            if (redirLoc.location != NSNotFound) {
                NSInteger strStart = redirLoc.location + redirLoc.length;
                NSString *redir = [urlStr substringFromIndex:strStart];
                
                // update the new url
                url = [NSURL URLWithString:redir];
            }
            
            // send a callback with the url
            _clickHandler(url);
            
            // don't propagate this
            return false;
        }
        
        // else just return true
        return true;
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"console.log('SAMRAID_EXT'+document.getElementsByTagName('html')[0].innerHTML);"];
    
    if (!_finishedLoading) {
        _finishedLoading = true;
        _eventHandler(saWeb_Start);
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!_finishedLoading) {
        _finishedLoading = true;
        _eventHandler(saWeb_Error);
    }
}

////////////////////////////////////////////////////////////////////////////////
// SAMRAIDCommandProtocol implementation
////////////////////////////////////////////////////////////////////////////////

- (void) closeCommand {
    [_mraid setStateToHidden];
    [self removeFromSuperview];
}

- (void) expandCommand:(NSString*)url {
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    _expandedPlayer = [[SAExpandedWebPlayer alloc] initWithContentSize:screenSize andParentFrame:screen];
    _expandedPlayer.layer.zPosition = MAXFLOAT;
    _expandedPlayer.backgroundColor = [UIColor blackColor];
    _expandedPlayer.mraid.expandedCustomClosePosition = _mraid.expandedCustomClosePosition;
    _expandedPlayer.clickHandler = _clickHandler;
    _expandedPlayer.eventHandler = _eventHandler;
    
    if (url != nil) {
        
        SANetwork* network = [[SANetwork alloc] init];
        [network sendGET:url withQuery:@{} andHeader:@{} withResponse:^(NSInteger status, NSString *payload, BOOL success) {
            
            if (payload != nil && success) {
                [self.expandedPlayer loadHTML:payload witBase:@""];
            }
            
        }];
        
    }
    else {
        [_expandedPlayer loadHTML:_html witBase:@""];
    }
    
    [root.view addSubview:_expandedPlayer];
}

- (void) resizeCommand {
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    _resizedPlayer = [[SAResizedWebPlayer alloc] initWithContentSize:CGSizeMake(_mraid.expandedWidth, _mraid.expandedHeight) andParentFrame:CGRectZero];
    _resizedPlayer.layer.zPosition = MAXFLOAT;
    _resizedPlayer.backgroundColor = [UIColor blackColor];
    _resizedPlayer.parent = self;
    _resizedPlayer.clickHandler = _clickHandler;
    _resizedPlayer.eventHandler = _eventHandler;
    [_resizedPlayer loadHTML:_html witBase:@""];
    [root.view addSubview:_resizedPlayer];
    [_resizedPlayer updateParentFrame:CGRectZero];
}

- (void) useCustomCloseCommand:(BOOL) useCustomClose {
    _mraid.expandedCustomClosePosition = Unavailable;
}

- (void) createCalendarEventCommand:(NSString*)eventJSON {
    // do nothing
}

- (void) openCommand:(NSString*)url {
    if (url != nil) {
        _clickHandler([NSURL URLWithString:url]);
    }
}

- (void) playVideoCommand:(NSString*)url {
    
    if (url != nil) {
        
        NSURL* dest =[[NSURL alloc] initWithString:url];
        
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:dest];
        player.moviePlayer.fullscreen = YES;
        player.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        player.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentMoviePlayerViewControllerAnimated:player];
        [player.moviePlayer play];
    }
}

- (void) storePictureCommand:(NSString*)url {
    // do nothing
}

- (void) setOrientationPropertiesCommand:(BOOL)allowOrientationChange
                                     and:(BOOL)forceOrientation {
    // do nothing
}

- (void) setResizePropertiesCommand:(NSInteger) width
                          andHeight:(NSInteger) height
                         andOffsetX:(NSInteger) offsetX
                         andOffsetY:(NSInteger) offsetY
                   andClosePosition:(SACustomClosePosition) customClosePosition
                  andAllowOffscreen:(BOOL) allowOffscreen {
    
    _mraid.expandedWidth = width;
    _mraid.expandedHeight = height;
    _mraid.expandedOffsetX = offsetX;
    _mraid.expandedOffsetY = offsetY;
    _mraid.expandedCustomClosePosition = customClosePosition;
    _mraid.expandedAllowsOffscreen = allowOffscreen;
    
}

////////////////////////////////////////////////////////////////////////////////
// Setters & Getters
////////////////////////////////////////////////////////////////////////////////

- (void) setEventHandler:(saWebPlayerDidReceiveEvent) handler {
    _eventHandler = handler != nil ? handler : _eventHandler;
}

- (void) setClickHandler:(saWebPlayerDidReceiveClick) handler {
    _clickHandler = handler != nil ? handler : _clickHandler;
}

- (UIWebView*) getWebView {
    return _webView;
}

@end
