//
//  SAWebPlayer.h
//  Pods
//
//  Created by Gabriel Coman on 06/03/2016.
//
//

#import <UIKit/UIKit.h>

// callback functions
typedef void (^sawebplayerLoadResult)(BOOL success);
typedef void (^sawebplayerOnClick)(NSURL *url);

@interface SAWebPlayer : UIWebView <UIWebViewDelegate>

// set size (for scaling purposes)
- (void) setAdSize:(CGSize)adSize;

// load ad
- (void) loadAdHTML:(NSString*)html
         withResult:(sawebplayerLoadResult)loadResult
    andClickHandler:(sawebplayerOnClick)onClick;

// re-arramge func
- (void) updateToFrame:(CGRect)frame;

@end