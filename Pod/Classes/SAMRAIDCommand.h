#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SACommand) {
    None = 0,
    Close,
    CreateCalendarEvent,
    Expand,
    Open,
    PlayVideo,
    Resize,
    SetOrientationProperties,
    SetResizeProperties,
    StorePicture,
    UseCustomClose
};

static inline SACommand getSACommandFromString (NSString* command) {
    
    if (command == nil) {
        return None;
    }
    else {
        if ([command isEqualToString:@"close"]) {
            return Close;
        }
        else if ([command isEqualToString:@"createCalendarEvent"]) {
            return CreateCalendarEvent;
        }
        else if ([command isEqualToString:@"expand"]) {
            return Expand;
        }
        else if ([command isEqualToString:@"open"]) {
            return Open;
        }
        else if ([command isEqualToString:@"playVideo"]) {
            return PlayVideo;
        }
        else if ([command isEqualToString:@"resize"]) {
            return Resize;
        }
        else if ([command isEqualToString:@"setOrientationProperties"]) {
            return SetOrientationProperties;
        }
        else if ([command isEqualToString:@"setResizeProperties"]) {
            return SetResizeProperties;
        }
        else if ([command isEqualToString:@"storePicture"]) {
            return StorePicture;
        }
        else if ([command isEqualToString:@"useCustomClose"]) {
            return UseCustomClose;
        }
        else {
            return None;
        }
    }
}

typedef NS_ENUM(NSInteger, SACustomClosePosition) {
    Unavailable = 0,
    Top_Left,
    Top_Right,
    Center,
    Bottom_Left,
    Bottom_Right,
    Top_Center,
    Bottom_Center
};

static inline SACustomClosePosition getCustomClosePositionFromString (NSString* position) {
    if (position == nil) {
        return Top_Right;
    }
    else {
        if ([position isEqualToString:@"top-left"]) {
            return Top_Left;
        }
        else if ([position isEqualToString:@"top-right"]) {
            return Top_Right;
        }
        else if ([position isEqualToString:@"center"]) {
            return Center;
        }
        else if ([position isEqualToString:@"bottom-left"]) {
            return Bottom_Left;
        }
        else if ([position isEqualToString:@"bottom-right"]) {
            return Bottom_Right;
        }
        else if ([position isEqualToString:@"top-center"]) {
            return Top_Center;
        }
        else if ([position isEqualToString:@"bottom-center"]) {
            return Bottom_Center;
        }
        else {
            return Top_Right;
        }
    }
}

@protocol SAMRAIDCommandProtocol <NSObject>

- (void) closeCommand;
- (void) expandCommand:(NSString*)url;
- (void) resizeCommand;
- (void) useCustomCloseCommand:(BOOL) useCustomClose;
- (void) createCalendarEventCommand:(NSString*)eventJSON;
- (void) openCommand:(NSString*)url;
- (void) playVideoCommand:(NSString*)url;
- (void) storePictureCommand:(NSString*)url;
- (void) setOrientationPropertiesCommand:(BOOL)allowOrientationChange
                                     and:(BOOL)forceOrientation;
- (void) setResizePropertiesCommand:(NSInteger) width
                          andHeight:(NSInteger) height
                         andOffsetX:(NSInteger) offsetX
                         andOffsetY:(NSInteger) offsetY
                   andClosePosition:(SACustomClosePosition) customClosePosition
                  andAllowOffscreen:(BOOL) allowOffscreen;

@end

@interface SAMRAIDCommand : NSObject

@property (nonatomic, weak) id<SAMRAIDCommandProtocol> delegate;

- (BOOL) isMRAIDComamnd: (NSString*) query;
- (void) getQuery: (NSString*) query;

@end
