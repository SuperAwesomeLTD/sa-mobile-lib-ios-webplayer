#import <UIKit/UIKit.h>
#import "SAMRAIDCommand.h"

@interface SAMRAID : NSObject

@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, assign) BOOL hasMRAID;

@property (nonatomic, assign) NSInteger expandedWidth;
@property (nonatomic, assign) NSInteger expandedHeight;
@property (nonatomic, assign) NSInteger expandedOffsetX;
@property (nonatomic, assign) NSInteger expandedOffsetY;
@property (nonatomic, assign) BOOL expandedAllowsOffscreen;
@property (nonatomic, assign) SACustomClosePosition expandedCustomClosePosition;

- (void) injectMRAID;

- (void) setStateToLoading;
- (void) setStateToDefault;
- (void) setStateToExpanded;
- (void) setStateToResized;
- (void) setStateToHidden;

- (void) setViewableTrue;
- (void) setViewableFalse;

- (void) setPlacementInline;
- (void) setPlacementInterstitial;

- (void) setReady;

- (void) setCurrentPosition: (CGSize) size;
- (void) setDefaultPosition: (CGSize) size;
- (void) setScreenSize: (CGSize) size;
- (void) setMaxSize: (CGSize) size;
- (void) setResizeProperties: (NSInteger) width
                   andHeight: (NSInteger) height
                  andOffsetX: (NSInteger) offsetX
                  andOffsetY: (NSInteger) offsetY
              andCustomClose: (SACustomClosePosition) customClose
          andAllowsOffscreen: (BOOL) allowsOffscreen;

@end
