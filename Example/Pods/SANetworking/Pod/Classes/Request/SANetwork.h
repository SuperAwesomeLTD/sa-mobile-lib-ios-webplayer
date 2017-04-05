/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>

// method callback
typedef void (^saDidGetResponse)(NSInteger status, NSString *payload, BOOL success);

/**
 * This is the main class that abstracts away most major network operations
 * needed in order to communicate with the ad server
 */
@interface SANetwork : NSObject

/**
 * This is a sister method to the private "sendRequest" method that
 * will execute a GET HTTP request
 */
- (void) sendGET:(NSString*)endpoint
       withQuery:(NSDictionary*)query
       andHeader:(NSDictionary*)header
    withResponse:(saDidGetResponse)response;

/**
 * This is a sister method to the private "sendRequest" method that
 * will execute a POST HTTP request
 */
- (void) sendPOST:(NSString*)endpoint
        withQuery:(NSDictionary*)query
        andHeader:(NSDictionary*)header
          andBody:(NSDictionary*)body
     withResponse:(saDidGetResponse)response;

/**
 * This is a sister method to the private "sendRequest" method that
 * will execute a PUT HTTP request
 */
- (void) sendPUT:(NSString*)endpoint
       withQuery:(NSDictionary*)query
       andHeader:(NSDictionary*)header
         andBody:(NSDictionary*)body
    withResponse:(saDidGetResponse)response;


@end
