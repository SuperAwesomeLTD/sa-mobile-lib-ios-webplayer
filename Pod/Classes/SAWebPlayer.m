/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebPlayer.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SAMRAID.h"
#import "SAMRAIDCommand.h"
#import <QuartzCore/QuartzCore.h>
#import "SANetwork.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SAWebPlayer () <UIWebViewDelegate, SAMRAIDCommandProtocol>

// the internal web view
@property (nonatomic, strong) SAWebView         *webView;
@property (nonatomic, assign) CGSize            contentSize;
@property (nonatomic, assign) CGAffineTransform webTransform;

@property (nonatomic, strong) SAMRAID           *mraid;

@property (nonatomic, strong) SAWebPlayer       *expandedPlayer;

@property (nonatomic, strong) NSString          *html;

@property (nonatomic, strong) UIButton          *closeBtn;

@end

@implementation SAWebPlayer

- (id) initWithContentSize:(CGSize) contentSize
            andParentFrame:(CGRect) parentRect{
    
    // save the content size
    _contentSize = contentSize;
    
    // make transform identity
    _webTransform = CGAffineTransformIdentity;
    
    if (self = [super init]) {
        
        // clear color
        self.backgroundColor = [UIColor clearColor];
        
        // init MRAID
        _mraid = [[SAMRAID alloc] init];
        
        // create the webview and add it as a subview
        _webView = [[SAWebView alloc] initWithFrame:CGRectMake(0, 0, _contentSize.width, _contentSize.height)];
        
        JSContext *ctx = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        ctx[@"console"][@"log"] = ^(JSValue * msg) {
            
            NSLog(@"%@", msg);
            
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
                        [_mraid setStateToResized];
                    }
                    else  {
                        [_mraid setStateToDefault];
                    }
                    [_mraid setReady];
                    
                    // create the close button
                    if ((_isExpanded || _isResized) && _mraid.expandedCustomClosePosition != Unavailable) {
                        
                        _closeBtn = [[UIButton alloc] init];
                        
                        NSInteger width = 40;
                        NSInteger height = 40;
                        NSInteger x = 0;
                        NSInteger y = 0;
                        
                        switch (_mraid.expandedCustomClosePosition) {
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
        
        // set delegate
        _webView.delegate = self;
        
        // add subview
        [self addSubview:_webView];
        
        // update parent frame
        [self updateParentFrame:parentRect];
        
    }
    
    return self;
    
}

- (void) updateParentFrame:(CGRect) parentRect {
    
    // do the calcs
    CGRect contentRect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
    CGRect result = [self map:contentRect into:parentRect];
    CGFloat scaleX = result.size.width / _contentSize.width;
    CGFloat scaleY = result.size.height / _contentSize.height;
    CGFloat diffX = (result.size.width - _contentSize.width) / 2.0f;
    CGFloat diffY = (result.size.height - _contentSize.height) / 2.0f;
    
    // update web player frame
    [self setFrame:result];
    
    // invert transform
    _webView.transform = CGAffineTransformInvert(_webTransform);
    
    // update instance transform
    _webTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleX, scaleY),
                                            CGAffineTransformMakeTranslation(diffX, diffY));
    
    // apply new transform
    _webView.transform = _webTransform;
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
    [_webView setEventHandler:handler];
}

- (void) setClickHandler:(saWebPlayerDidReceiveClick) handler {
    [_webView setClickHandler:handler];
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
    
    NSLog(@"URL is %@", [request URL]);
    
    NSString *url = [[request URL] absoluteString];
    
    SAMRAIDCommand *command = [[SAMRAIDCommand alloc] init];
    BOOL isMraid = [command isMRAIDComamnd:url];
    
    if (isMraid) {
     
        command.delegate = self;
        [command getQuery:url];
        
        return false;
    }
    else {
        // do normal stuff
        return true;
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"console.log('SAMRAID_EXT'+document.getElementsByTagName('html')[0].innerHTML);"];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

////////////////////////////////////////////////////////////////////////////////
// SAMRAIDCommandProtocol implementation
////////////////////////////////////////////////////////////////////////////////

- (void) closeCommand {
    
    if (_isExpanded) {
        [self removeFromSuperview];
    }
    
}

- (void) expandCommand:(NSString*)url {
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGSize screen = [UIScreen mainScreen].bounds.size;
    
    _expandedPlayer = [[SAWebPlayer alloc] initWithContentSize:screen andParentFrame:CGRectMake(0, 0, screen.width, screen.height)];
    _expandedPlayer.layer.zPosition = MAXFLOAT;
    _expandedPlayer.isExpanded = true;
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
    
}

@end
