#import "SAResizedWebPlayer.h"

@implementation SAResizedWebPlayer

- (void) didReceiveMessageFromJavaScript:(NSString *)message {
    
    CGSize screen = [UIScreen mainScreen].bounds.size;
    
    [super.mraid setPlacementInline];
    [super.mraid setViewableTrue];
    [super.mraid setScreenSize:screen];
    [super.mraid setMaxSize:screen];
    [super.mraid setCurrentPosition:super.contentSize];
    [super.mraid setDefaultPosition:super.contentSize];
    [super.mraid setReady];
    [super.mraid setStateToResized];
    [super.mraid setReady];
    
    if (super.mraid.expandedCustomClosePosition != Unavailable) {
        
        super.closeBtn = [[UIButton alloc] init];
        
        [self updateCloseBtnFrame:super.mraid.expandedCustomClosePosition];
        
        [super.closeBtn setBackgroundColor:[UIColor redColor]];
        [super.closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [[super.closeBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        [[super.closeBtn titleLabel] setTextColor:[UIColor whiteColor]];
        [super.closeBtn addTarget:self action:@selector(closeCommand) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:super.closeBtn];
    }
}

- (void) didRotateScreen {
    CGRect superFrame = self.superview.frame;
    [self updateParentFrame:superFrame];
    [self updateCloseBtnFrame:super.mraid.expandedCustomClosePosition];
}

- (void) updateParentFrame:(CGRect)frame {
    
    super.webView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect screen = [UIScreen mainScreen].bounds;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    NSInteger finalHeight = super.contentSize.height * _parent.scaleY;
    
    NSInteger finalHalfHeight = finalHeight / 2;
    NSInteger locY = [_parent convertPoint:_parent.bounds.origin toView:root.view].y;
    NSInteger wwYMidle = locY + (_parent.frame.size.height / 2);
    NSInteger bottomDif = screenSize.height - wwYMidle;
    NSInteger topDiff = wwYMidle;
    NSInteger downMax = MIN(bottomDif, finalHalfHeight);
    NSInteger upMax = MIN(topDiff, finalHalfHeight);
    upMax += downMax < finalHalfHeight ? (finalHalfHeight - bottomDif) : 0;
    NSInteger finalY = wwYMidle - upMax;
    
    NSInteger finalWidth = super.contentSize.width * _parent.scaleX;
    
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
        super.scaleX = finalRect.size.width / super.contentSize.width;
        super.scaleY = finalRect.size.height / super.contentSize.height;
    } else {
        finalRect = screen;
        CGRect result = [self map:super.webView.frame into:finalRect];
        super.scaleX = result.size.width / super.contentSize.width;
        super.scaleY = result.size.height / super.contentSize.height;
    }
    
    [self setFrame:finalRect];
    
    super.webView.transform = CGAffineTransformMakeScale(super.scaleX, super.scaleY);
    
    CGFloat cX = self.center.x - self.frame.origin.x;
    CGFloat cY = self.center.y - self.frame.origin.y;
    
    super.webView.center = CGPointMake(cX, cY);
}

@end
