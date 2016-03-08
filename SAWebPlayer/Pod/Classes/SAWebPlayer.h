//
//  SAWebPlayer.h
//  Pods
//
//  Created by Gabriel Coman on 06/03/2016.
//
//

#import <UIKit/UIKit.h>

//
// @brief: A protocol that defines the three main callbacks for the custom
// SAWebView
@protocol SAWebPlayerProtocol <NSObject>

// @brief: called when you want to navigate
- (void) webPlayerWillNavigate:(NSURL*)url;

// @brief: callback to tell when a webview was loaded
- (void) webPlayerDidLoad;

// @brief: callback to tell when a webview wasn't loaded ok
- (void) webPlayerDidFail;

@end

@interface SAWebPlayer : UIWebView <UIWebViewDelegate>

// delegate
@property (nonatomic, weak) id<SAWebPlayerProtocol> sadelegate;

// set size (for scaling purposes)
- (void) setAdSize:(CGSize)adSize;

// load ad
- (void) loadAdHTML:(NSString*)html;

// re-arramge func
- (void) updateToFrame:(CGRect)frame;

@end