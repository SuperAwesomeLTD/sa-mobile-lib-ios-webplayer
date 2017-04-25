#import "SAMRAIDCommand.h"

@interface SAMRAIDCommand ()
@property (nonatomic, assign) SACommand command;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *params;
@end

@implementation SAMRAIDCommand

- (BOOL) isMRAIDComamnd: (NSString*) query {
    return [query rangeOfString:@"mraid://"].location != NSNotFound;
}

- (void) getQuery: (NSString*) query {
    
    NSArray<NSString*> *parts = [[query stringByReplacingOccurrencesOfString:@"mraid://" withString:@""] componentsSeparatedByString:@"?"];
    
    if (parts.count >= 1) {
        
        // for the actual command
        _command = getSACommandFromString(parts.firstObject);
        
        // for the command params, if they exist
        if (parts.count >= 2) {
            
            NSString* paramStr = parts[1];
            NSArray<NSString*> *pairs = [paramStr componentsSeparatedByString:@"&"];
            
            NSMutableDictionary *lparams = [@{} mutableCopy];
            
            for (NSString* pair in pairs) {
                NSArray<NSString*> *kv = [pair componentsSeparatedByString:@"="];
                if (kv.count == 2) {
                    NSString *key = kv[0];
                    NSString *value = kv[1];
                    [lparams setObject:value forKey:key];
                }
            }
            
            if ([self checkParamsForCommand:_command andParams:lparams]) {
                _params = lparams;
            }
        }
        
        // now send out messages
        switch (_command) {
            case None: {
                break;
            }
            case Close: {
                [_delegate closeCommand];
                break;
            }
            case CreateCalendarEvent: {
                [_delegate createCalendarEventCommand:nil];
                break;
            }
            case Expand: {
                NSString *url = [self parseUrl:[_params objectForKey:@"url"]];
                [_delegate expandCommand:url];
                break;
            }
            case Open: {
                NSString *url = [self parseUrl:[_params objectForKey:@"url"]];
                [_delegate openCommand:url];
                break;
            }
            case PlayVideo: {
                NSString *url = [self parseUrl:[_params objectForKey:@"url"]];
                [_delegate playVideoCommand:url];
                break;
            }
            case StorePicture: {
                NSString *url = [self parseUrl:[_params objectForKey:@"url"]];
                [_delegate storePictureCommand:url];
                break;
            }
            case Resize: {
                [_delegate resizeCommand];
                break;
            }
            case SetOrientationProperties: {
                [_delegate setOrientationPropertiesCommand:false and:false];
                break;
            }
            case SetResizeProperties: {
                
                NSInteger width = [[_params objectForKey:@"width"] integerValue];
                NSInteger height = [[_params objectForKey:@"height"] integerValue];
                NSInteger offsetX = [[_params objectForKey:@"offsetX"] integerValue];
                NSInteger offsetY = [[_params objectForKey:@"offsetY"] integerValue];
                BOOL allowOffscreen = [[_params objectForKey:@"allowOffscreen"] boolValue];
                
                NSString *customClosePosition = [_params objectForKey:@"customClosePosition"];
                if (customClosePosition == nil) {
                    customClosePosition = [_params objectForKey:@"expandedCustomClosePosition"];
                }
                SACustomClosePosition customClose = getCustomClosePositionFromString(customClosePosition);
                
                [_delegate setResizePropertiesCommand:width
                                            andHeight:height
                                           andOffsetX:offsetX
                                           andOffsetY:offsetY
                                     andClosePosition:customClose
                                    andAllowOffscreen:allowOffscreen];
                
                break;
            }
            case UseCustomClose: {
                [_delegate useCustomCloseCommand:true];
                break;
            }
                
            default:
                break;
        }
        
    }
    
}

- (NSString*) parseUrl: (NSString*) url {
    return url == nil ? nil : [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL) checkParamsForCommand: (SACommand)command andParams:(NSDictionary<NSString*, NSString*> *)params {
    
    switch (command) {
        case None:
            return false;
        case Close:
        case Expand:
        case Resize:
            return true;
        case UseCustomClose:
            return [params objectForKey:@"useCustomClose"] != nil;
        case CreateCalendarEvent:
            return [params objectForKey:@"eventJSON"] != nil;
        case Open:
        case PlayVideo:
        case StorePicture:
            return [params objectForKey:@"url"] != nil;
        case SetOrientationProperties:
            return [params objectForKey:@"allowOrientationChange"] != nil &&
            [params objectForKey:@"forceOrientation"] != nil;
        case SetResizeProperties:
            return [params objectForKey:@"width"] != nil &&
            [params objectForKey:@"height"] != nil &&
            [params objectForKey:@"offsetX"] != nil &&
            [params objectForKey:@"offsetY"] != nil &&
            ([params objectForKey:@"customClosePosition"] != nil ||
             [params objectForKey:@"expandedCustomClosePosition"] != nil) &&
            [params objectForKey:@"allowOffscreen"] != nil;
    }
    
    return false;
}

@end
