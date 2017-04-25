/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebPlayer.h"
#import "SAMRAID.h"
#import "SAMRAIDCommand.h"
#import "SANetwork.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SAWebPlayer () <UIWebViewDelegate, SAMRAIDCommandProtocol>

// the internal web view
@property (nonatomic, strong) SAWebView         *webView;
@property (nonatomic, assign) CGSize            contentSize;

@property (nonatomic, strong) SAMRAID           *mraid;

@property (nonatomic, strong) SAWebPlayer       *expandedPlayer;

@property (nonatomic, strong) NSString          *html;

@property (nonatomic, strong) UIButton          *closeBtn;

@property (nonatomic, assign) CGFloat           scaleX;
@property (nonatomic, assign) CGFloat           scaleY;

@property (nonatomic, weak) SAWebPlayer         *parent;

// param that says the web view was once loaded
@property (nonatomic, assign) BOOL                         finishedLoading;

// strong references to the click and event handlers
@property (nonatomic, strong) saWebPlayerDidReceiveEvent   eventHandler;
@property (nonatomic, strong) saWebPlayerDidReceiveClick   clickHandler;

@end

@implementation SAWebPlayer

- (id) initWithContentSize:(CGSize) contentSize
            andParentFrame:(CGRect) parentRect{
    
    // get a weak self reference
    __weak typeof (self) weakSelf = self;
    
    // init w/ defaults
    _eventHandler = ^(SAWebPlayerEvent event) {};
    _clickHandler = ^(NSURL *url) {};
    
    // set to false
    _finishedLoading = false;
    
    // save the content size
    _contentSize = contentSize;
    
    if (self = [super init]) {
        
        // clear color
        self.backgroundColor = [UIColor clearColor];
        
        // init MRAID
        _mraid = [[SAMRAID alloc] init];
        
        // create the webview and add it as a subview
        _webView = [[SAWebView alloc] initWithFrame:CGRectMake(0, 0, _contentSize.width, _contentSize.height)];
        
        JSContext *ctx = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        ctx[@"console"][@"log"] = ^(JSValue * msg) {
            
            if ([msg isString] && [msg toString] != nil && [[msg toString] rangeOfString:@"SAMRAID_EXT"].location != NSNotFound) {
                
                NSString *jsMsg = [[msg toString] stringByReplacingOccurrencesOfString:@"SAMRAID_EXT" withString:@""];
                
                BOOL hasMraid = [jsMsg rangeOfString:@"mraid"].location != NSNotFound;
                [_mraid setHasMRAID:hasMraid];
                
                if ([_mraid hasMRAID]) {
                    
                    CGSize screen = [UIScreen mainScreen].bounds.size;
                    
                    [_mraid setPlacementInline];
                    [_mraid setViewableTrue];
                    [_mraid setScreenSize:screen];
                    [_mraid setMaxSize:screen];
                    [_mraid setCurrentPosition:_contentSize];
                    [_mraid setDefaultPosition:_contentSize];
                    if (_isExpanded) {
                        [_mraid setStateToExpanded];
                    }
                    else if (_isResized) {
                        [_mraid setReady];
                        [_mraid setStateToResized];
                    }
                    else  {
                        [_mraid setStateToDefault];
                    }
                    [_mraid setReady];
                    
                    // create the close button
                    if ((_isExpanded || _isResized) && _mraid.expandedCustomClosePosition != Unavailable) {
                        
                        _closeBtn = [[UIButton alloc] init];
                        
                        [self updateCloseBtnFrame:_mraid.expandedCustomClosePosition];
                        
                        [_closeBtn setBackgroundColor:[UIColor redColor]];
                        [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
                        [[_closeBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
                        [[_closeBtn titleLabel] setTextColor:[UIColor whiteColor]];
                        [_closeBtn addTarget:self action:@selector(closeCommand) forControlEvents:UIControlEventTouchUpInside];
                        [self addSubview:_closeBtn];
                    }
                }
            }
        };
        
        // add notfication rotation
        [[NSNotificationCenter defaultCenter] addObserverForName:@"UIDeviceOrientationDidChangeNotification"
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:
         ^(NSNotification * note) {
             
             CGRect superFrame = weakSelf.isExpanded ? [UIScreen mainScreen].bounds : weakSelf.superview.frame;
             [weakSelf updateParentFrame:superFrame];
             [weakSelf updateCloseBtnFrame:weakSelf.mraid.expandedCustomClosePosition];
             
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIDeviceOrientationDidChangeNotification"
                                                  object:nil];
    [super removeFromSuperview];
}

- (void) updateParentFrame:(CGRect) parentRect {
    
    if (_isResized) {
        
        _webView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        CGRect screen = [UIScreen mainScreen].bounds;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        NSInteger finalHeight = _contentSize.height * _parent.scaleY;
        
        NSInteger finalHalfHeight = finalHeight / 2;
        NSInteger locY = [_parent convertPoint:_parent.bounds.origin toView:root.view].y;
        NSInteger wwYMidle = locY + (_parent.frame.size.height / 2);
        NSInteger bottomDif = screenSize.height - wwYMidle;
        NSInteger topDiff = wwYMidle;
        NSInteger downMax = MIN(bottomDif, finalHalfHeight);
        NSInteger upMax = MIN(topDiff, finalHalfHeight);
        upMax += downMax < finalHalfHeight ? (finalHalfHeight - bottomDif) : 0;
        NSInteger finalY = wwYMidle - upMax;
        
        NSInteger finalWidth = _contentSize.width * _parent.scaleX;
        
        NSInteger finalHalfWidth = finalWidth / 2;
        NSInteger locX = [_parent convertPoint:_parent.bounds.origin toView:root.view].x;
        NSInteger wwXMidle = locX + (_parent.frame.size.width / 2);
        NSInteger rightDiff = screenSize.width - wwXMidle;
        NSInteger leftDiff = wwXMidle;
        NSInteger rightMax = MIN(rightDiff, finalHalfWidth);
        NSInteger leftMax = MIN(leftDiff, finalHalfWidth);
        leftMax += rightMax < finalHalfWidth ? (finalHalfWidth - rightDiff) : 0;
        NSInteger finalX = wwXMidle - leftMax;
        
        CGRect finalRect;
        
        if (finalWidth < screenSize.width && finalHeight < screenSize.height) {
            finalRect = CGRectMake(finalX, finalY, finalWidth, finalHeight);
            _scaleX = finalRect.size.width / _contentSize.width;
            _scaleY = finalRect.size.height / _contentSize.height;
        } else {
            finalRect = screen;
            CGRect result = [self map:_webView.frame into:finalRect];
            _scaleX = result.size.width / _contentSize.width;
            _scaleY = result.size.height / _contentSize.height;
        }
        
        [self setFrame:finalRect];
        
        _webView.transform = CGAffineTransformMakeScale(_scaleX, _scaleY);
        
        CGFloat cX = self.center.x - self.frame.origin.x;
        CGFloat cY = self.center.y - self.frame.origin.y;
        
        _webView.center = CGPointMake(cX, cY);
    }
    else {
    
        CGRect contentRect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
        CGRect result = [self map:contentRect into:parentRect];
        _scaleX = result.size.width / _contentSize.width;
        _scaleY = result.size.height / _contentSize.height;
        
        [self setFrame:CGRectMake(0, 0, parentRect.size.width, parentRect.size.height)];
        
        _webView.transform = CGAffineTransformMakeScale(_scaleX, _scaleY);
        _webView.center = self.center;
    }
}

- (void) updateCloseBtnFrame:(SACustomClosePosition) closePos {
    NSInteger width = 40;
    NSInteger height = 40;
    NSInteger x = 0;
    NSInteger y = 0;
    
    switch (closePos) {
        case Top_Left:
            x = 0;
            y = 0;
            break;
        case Top_Right:
            x = self.frame.size.width - 40;
            y = 0;
            break;
        case Center:
            x = (self.frame.size.width / 2) - 20;
            y = (self.frame.size.height / 2) - 20;
            break;
        case Bottom_Left:
            x = 0;
            y = self.frame.size.height - 40;
            break;
        case Bottom_Right:
            x = self.frame.size.width - 40;
            y = self.frame.size.height - 40;
            break;
        case Top_Center:
            x = (self.frame.size.width / 2) - 20;
            y = 0;
            break;
        case Bottom_Center:
            x = (self.frame.size.width / 2) - 20;
            y = self.frame.size.height - 40;
            break;
        case Unavailable:
        default:
            x = 0; y = 0; width = 0; height = 0;
            break;
    }
    
    _closeBtn.frame = CGRectMake(x, y, width, height);
}

- (void) loadHTML:(NSString*)html witBase:(NSString*)base {
    // the base HTML that wraps the content html
    NSString *baseHtml = @"<html><header><style>html, body, div { margin: 0px; padding: 0px; }</style></header><body>_CONTENT_</body></html>";
    
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

- (void) setEventHandler:(saWebPlayerDidReceiveEvent) handler {
    _eventHandler = handler != nil ? handler : _eventHandler;
}

- (void) setClickHandler:(saWebPlayerDidReceiveClick) handler {
    _clickHandler = handler != nil ? handler : _clickHandler;
}

- (UIWebView*) getWebView {
    return _webView;
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
            if ([urlStr rangeOfString:@"about:blank"].location != NSNotFound) return true;
            
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

    if (_isExpanded || _isResized) {
        
        [self removeFromSuperview];
    }
}

- (void) expandCommand:(NSString*)url {
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    _expandedPlayer = [[SAWebPlayer alloc] initWithContentSize:screenSize andParentFrame:screen];
    _expandedPlayer.layer.zPosition = MAXFLOAT;
    _expandedPlayer.isExpanded = true;
    _expandedPlayer.backgroundColor = [UIColor blackColor];
    _expandedPlayer.mraid.expandedCustomClosePosition = _mraid.expandedCustomClosePosition;
    
    if (url != nil) {
        
        SANetwork* network = [[SANetwork alloc] init];
        [network sendGET:url withQuery:@{} andHeader:@{} withResponse:^(NSInteger status, NSString *payload, BOOL success) {
    
            if (payload != nil && success) {
                [_expandedPlayer loadHTML:payload witBase:nil];
            }
            
        }];
        
    }
    else {
        [_expandedPlayer loadHTML:_html witBase:nil];
    }
    
    [root.view addSubview:_expandedPlayer];
}

- (void) resizeCommand {
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    _expandedPlayer = [[SAWebPlayer alloc] initWithContentSize:CGSizeMake(_mraid.expandedWidth, _mraid.expandedHeight) andParentFrame:CGRectZero];
    _expandedPlayer.layer.zPosition = MAXFLOAT;
    _expandedPlayer.isResized = true;
    _expandedPlayer.backgroundColor = [UIColor blackColor];
    _expandedPlayer.parent = self;
    [_expandedPlayer loadHTML:_html witBase:nil];
    [root.view addSubview:_expandedPlayer];
    [_expandedPlayer updateParentFrame:CGRectZero];
    
}

- (void) useCustomCloseCommand:(BOOL) useCustomClose {
    
    _mraid.expandedCustomClosePosition = Unavailable;
    
    if (_isExpanded) {
        [_closeBtn removeFromSuperview];
    }
    
}

- (void) createCalendarEventCommand:(NSString*)eventJSON {
    // do nothing
}

- (void) openCommand:(NSString*)url {
    
    if (url != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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

@end
