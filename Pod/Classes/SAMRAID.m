#import "SAMRAID.h"

@implementation SAMRAID

- (id) init {
    if (self = [super init]) {
        _expandedAllowsOffscreen = false;
        _expandedCustomClosePosition = Top_Right;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// Init MRAID
////////////////////////////////////////////////////////////////////////////////

- (NSString*) mraidJs {
    return @"";
}

- (void) injectJS: (NSString*) js {
    [_webView loadHTMLString:[NSString stringWithFormat:@"javascript: %@", js] baseURL:NULL];
}

- (void) injectMRAID {
    NSString *mraid = [self mraidJs];
    [self injectJS:mraid];
}

////////////////////////////////////////////////////////////////////////////////
// State Changed
////////////////////////////////////////////////////////////////////////////////

- (void) fireStateChangedEvent: (NSString*) event {
    NSString *method = [NSString stringWithFormat:@"mraid.fireStateChangeEvent('%@');", event];
    [self injectJS:method];
}

- (void) setStateToLoading {
    [self fireStateChangedEvent:@"loading"];
}

- (void) setStateToDefault {
    [self fireStateChangedEvent:@"default"];
}

- (void) setStateToExpanded {
    [self fireStateChangedEvent:@"expanded"];
}

- (void) setStateToResized {
    [self fireStateChangedEvent:@"resized"];
}

- (void) setStateToHidden {
    [self fireStateChangedEvent:@"hidden"];
}

////////////////////////////////////////////////////////////////////////////////
// State Viewable
////////////////////////////////////////////////////////////////////////////////

- (void) fireViewableChangeEvent: (BOOL) isViewable {
    NSString *method = [NSString stringWithFormat:@"mraid.fireViewableChangeEvent('%d');", isViewable];
    [self injectJS:method];
}

- (void) setViewableTrue {
    [self fireViewableChangeEvent:true];
}

- (void) setViewableFalse {
    [self fireViewableChangeEvent:false];
}

////////////////////////////////////////////////////////////////////////////////
// Placement Type
////////////////////////////////////////////////////////////////////////////////

- (void) setPlacementType: (BOOL) isInterstitial {
    NSString *method = [NSString stringWithFormat:@"mraid.setPlacementType('%@');", (isInterstitial ? @"interstitial": @"inline")];
    [self injectJS:method];
}

- (void) setPlacementInline {
    [self setPlacementType:false];
}

- (void) setPlacementInterstitial {
    [self setPlacementType:true];
}

////////////////////////////////////////////////////////////////////////////////
// Ready
////////////////////////////////////////////////////////////////////////////////

- (void) setReady {
    NSString *method = @"method.fireReadyEvent()";
    [self injectJS:method];
}

////////////////////////////////////////////////////////////////////////////////
// Position & screen size
////////////////////////////////////////////////////////////////////////////////

- (void) setCurrentPosition: (CGSize)size {
    NSInteger x = 0, y = 0, width = size.width, height = size.height;
    NSString *method = [NSString stringWithFormat:@"mraid.setCurrentPosition(%d, %d, %d, %d);", x, y, width, height];
    [self injectJS:method];
}

- (void) setDefaultPosition: (CGSize) size {
    NSInteger x = 0, y = 0, width = size.width, height = size.height;
    NSString *method = [NSString stringWithFormat:@"mraid.setDefaultPosition(%d, %d, %d, %d);", x, y, width, height];
    [self injectJS:method];
}

- (void) setScreenSize: (CGSize) size {
    int width = size.width, height = size.height;
    NSString *method = [NSString stringWithFormat:@"mraid.setScreenSize(%d, %d)", width, height];
    [self injectJS:method];
}

- (void) setMaxSize: (CGSize) size {
    int width = size.width, height = size.height;
    NSString *method = [NSString stringWithFormat:@"mraid.setMaxSize(%d, %d)", width, height];
    [self injectJS:method];
}

- (void) setResizeProperties: (NSInteger) width
                   andHeight: (NSInteger) height
                  andOffsetX: (NSInteger) offsetX
                  andOffsetY: (NSInteger) offsetY
              andCustomClose: (SACustomClosePosition) customClose
          andAllowsOffscreen: (BOOL) allowsOffscreen {
    _expandedWidth = width;
    _expandedHeight = height;
    _expandedOffsetX = offsetX;
    _expandedOffsetY = offsetY;
    _expandedCustomClosePosition = customClose;
    _expandedAllowsOffscreen = allowsOffscreen;
}

@end
