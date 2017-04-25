#import "SAExpandedWebPlayer.h"
#import "SAMRAIDCommand.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SAExpandedWebPlayer () <SAWebPlayerAuxProtocol>
@end

@implementation SAExpandedWebPlayer 

- (id) initWithContentSize:(CGSize)contentSize
            andParentFrame:(CGRect)parentRect {

    if (self = [super initWithContentSize:contentSize andParentFrame:parentRect]) {
        // do nothing
    }
    
    return self;
}

- (void) didRotateScreen {
    CGRect superFrame = [UIScreen mainScreen].bounds;
    [self updateParentFrame:superFrame];
    [self updateCloseBtnFrame:super.mraid.expandedCustomClosePosition];
}

- (void) didReceiveMessageFromJavaScript:(NSString *)message {
    
    CGSize screen = [UIScreen mainScreen].bounds.size;
    
    [super.mraid setPlacementInline];
    [super.mraid setViewableTrue];
    [super.mraid setScreenSize:screen];
    [super.mraid setMaxSize:screen];
    [super.mraid setCurrentPosition:super.contentSize];
    [super.mraid setDefaultPosition:super.contentSize];
    [super.mraid setStateToExpanded];
    [super.mraid setReady];
    
    if (super.mraid.expandedCustomClosePosition != Unavailable) {
        
        _closeBtn = [[UIButton alloc] init];
        
        [self updateCloseBtnFrame:super.mraid.expandedCustomClosePosition];
        
        [_closeBtn setBackgroundColor:[UIColor redColor]];
        [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [[_closeBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        [[_closeBtn titleLabel] setTextColor:[UIColor whiteColor]];
        [_closeBtn addTarget:self action:@selector(closeCommand) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];
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

////////////////////////////////////////////////////////////////////////////////
// SAMRAIDCommandProtocol implementation
////////////////////////////////////////////////////////////////////////////////

- (void) expandCommand:(NSString*)url {
    // can't expand
}

- (void) resizeCommand {
    // can't resize
}

- (void) setResizePropertiesCommand:(NSInteger) width
                          andHeight:(NSInteger) height
                         andOffsetX:(NSInteger) offsetX
                         andOffsetY:(NSInteger) offsetY
                   andClosePosition:(SACustomClosePosition) customClosePosition
                  andAllowOffscreen:(BOOL) allowOffscreen {
    // can't set resize properties
}

@end
