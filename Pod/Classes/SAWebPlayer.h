/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>
#import "SAWebView.h"

/**
 * Class that abstracts away the details of loading HTML into an iOS WebView
 */
@interface SAWebPlayer : UIView

/**
 * Web Player init method with an ad size and a parent rect
 *
 * @param contentSize   the size of the ad that's going to be displayed
 * @param parentRect    the frame of the parent frame
 * @return              a new instance of the web player
 */
- (id) initWithContentSize:(CGSize) contentSize
            andParentFrame:(CGRect) parentRect;

/*
 * Method that updates the content of the Web Player to a new frame it may
 * have transitioned to.
 *
 * @param frame the new Web Player frame
 */
- (void) updateParentFrame:(CGRect)frame;

/**
 * Method that loads a HTML string into the Web Player
 *
 * @param html a valid HTML string
 */
- (void) loadHTML:(NSString*)html witBase:(NSString*)base;

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

/**
 * Getter for the web view
 *
 * @return the current used instance of the web view
 */
- (UIWebView*) getWebView;

@end
