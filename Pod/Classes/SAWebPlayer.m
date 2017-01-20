/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAWebPlayer.h"

@interface SAWebPlayer ()

// the internal web view
@property (nonatomic, strong) SAWebView         *webView;
@property (nonatomic, assign) CGSize            contentSize;
@property (nonatomic, assign) CGAffineTransform webTransform;
@end

@implementation SAWebPlayer

- (id) initWithContentSize:(CGSize) contentSize
            andParentFrame:(CGRect) parentRect{
    
    // save the content size
    _contentSize = contentSize;
    
    // do the calcs
    CGRect contentRect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
    CGRect result = [self map:contentRect into:parentRect];
    CGFloat scaleX = result.size.width / _contentSize.width;
    CGFloat scaleY = result.size.height / _contentSize.height;
    CGFloat diffX = (result.size.width - _contentSize.width) / 2.0f;
    CGFloat diffY = (result.size.height - _contentSize.height) / 2.0f;
    
    // init
    if (self = [super initWithFrame: result]) {
        
        // clear color
        self.backgroundColor = [UIColor clearColor];
        
        // init the web view
        _webView = [[SAWebView alloc] initWithFrame:contentRect];
        
        // transform
        _webTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleX, scaleY),
                                                CGAffineTransformMakeTranslation(diffX, diffY));
        _webView.transform = _webTransform;
        
        // add subview
        [self addSubview:_webView];
    }
    
    return self;
    
}

- (void) loadHTML:(NSString*)html {
    // the base HTML that wraps the content html
    NSString *baseHtml = @"<html><header><style>html, body, div { margin: 0px; padding: 0px; width: 100%; height: 100%; overflow: hidden; background-color: #efefef; }</style></header><body>_CONTENT_</body></html>";
    
    // replace content keyword with actual content
    baseHtml = [baseHtml stringByReplacingOccurrencesOfString:@"_CONTENT_" withString:html];
    
    // lock-and-load
    [_webView loadHTMLString:baseHtml baseURL:nil];
}

- (void) updateToFrame:(CGRect) parentRect {
    
    // do the calcs
    CGRect adRect = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
    CGRect result = [self map:adRect into:parentRect];
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

- (void) setEventHandler:(saWebPlayerDidReceiveEvent) handler {
    [_webView setEventHandler:handler];
}

- (void) setClickHandler:(saWebPlayerDidReceiveClick) handler {
    [_webView setClickHandler:handler];
}

/**
 * Method that does the math to transform a rectangle into the bounds of
 * another rectangle.
 *
 * @param sourceFrame   the source frame I want to map to
 * @param boundingFrame the bounding frame I want the source to be mapped in
 * @return              the correctly mapped result frame
 */
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

@end
