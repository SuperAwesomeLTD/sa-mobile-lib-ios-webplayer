/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

/**
 * Class that abstracts away the details of loading HTML into an iOS WebView
 */
@interface SAWebView : WKWebView

+ (WKWebViewConfiguration*) defaultConfiguration;

@end
