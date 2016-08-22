//
//  SAWebPlayer.h
//  Pods
//
//  Created by Gabriel Coman on 06/03/2016.
//
//

#import <UIKit/UIKit.h>

// types of events
typedef NS_ENUM(NSInteger, SAWebPlayerEvent) {
    Web_Start = 0,
    Web_Error = 1
};

// callbacks
typedef void (^sawebplayerEventHandler)(SAWebPlayerEvent event);
typedef void (^sawebplayerClickHandler)(NSURL* url);

// main class
@interface SAWebPlayer : UIWebView <UIWebViewDelegate>

// main public functions
- (void) setAdSize:(CGSize)adSize;
- (void) loadAdHTML:(NSString*)html;
- (void) updateToFrame:(CGRect)frame;
- (void) setEventHandler:(sawebplayerEventHandler)eventHandler;
- (void) setClickHandler:(sawebplayerClickHandler)clickHandler;

@end