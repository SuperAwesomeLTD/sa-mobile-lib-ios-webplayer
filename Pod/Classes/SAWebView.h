/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>

/**
 * WebPlayer event enum, containing two main events:
 *  - saWeb_Start: happens when the web view content is fully loaded
 *  - saWeb_Error: happens when something prevents the web view
 *               from properly loading the content
 */
typedef NS_ENUM(NSInteger, SAWebPlayerEvent) {
    saWeb_Start = 0,
    saWeb_Error = 1
};

// callback for handling web view events
typedef void (^saWebPlayerDidReceiveEvent)(SAWebPlayerEvent event);

// callback for handling web view clicks
typedef void (^saWebPlayerDidReceiveClick)(NSURL* url);

/**
 * Class that abstracts away the details of loading HTML into an iOS WebView
 */
@interface SAWebView : UIWebView <UIWebViewDelegate>

/*
 * Setter for the event handler
 *
 * @param handler   a new intance of the
 *                  saWebPlayerDidReceiveEvent method callback
 */
- (void) setEventHandler:(saWebPlayerDidReceiveEvent)handler;

/*
 * Setter for the click handler
 *
 * @param handler   a new intance of the
 *                  saWebPlayerDidReceiveClick method callback
 */
- (void) setClickHandler:(saWebPlayerDidReceiveClick)handler;

@end
