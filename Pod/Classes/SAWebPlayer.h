/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>

// types of events
typedef NS_ENUM(NSInteger, SAWebPlayerEvent) {
    Web_Start = 0,
    Web_Error = 1
};

// callback for handling web view events
typedef void (^saWebPlayerDidReceiveEvent)(SAWebPlayerEvent event);

// callback for handling web view clicks
typedef void (^saWebPlayerDidReceiveClick)(NSURL* url);

/**
 * Class that abstracts away the details of loading HTML into an iOS WebView
 */
@interface SAWebPlayer : UIWebView <UIWebViewDelegate>

/**
 * Method that sets an ad size for the web player. On this ad size the
 * scaling method will be handled
 *
 * @param adSize a CGSize struct holding an ad width & height that are
                 supposed to be handle by the web view
 */
- (void) setAdSize:(CGSize)adSize;

/**
 * Method that loads a HTML string into the Web Player
 *
 * @param html a valid HTML string
 */
- (void) loadAdHTML:(NSString*)html;

/*
 * Method that updates the content of the Web Player to a new frame it may
 * have transitioned to.
 *
 * @param frame the new Web Player frame
 */
- (void) updateToFrame:(CGRect)frame;

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
