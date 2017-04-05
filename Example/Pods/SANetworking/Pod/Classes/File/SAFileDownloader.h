/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>

@class SADownloadItem;

// callback for generic success
typedef void (^saDidDownloadFile)(BOOL success, NSString* diskPath);

/**
 * This class abstracts away the details of downloading files through a queue.
 * The main purpose is for class users to add files to be downloaded on
 * the queue and then for it to proceed to downloaded them one at a time.
 *
 * This is very useful when downloading large video files off the network,
 * for example.
 *
 */
@interface SAFileDownloader : NSObject

/**
 * Main singleton instance accessor method
 *
 * @return  the only instance of the SAFileDownloader object
 */
+ (instancetype) getInstance;

/**
 * This method allows users to add URLs to a queue of downloading items.
 * It will then know how to download them one after another so as not to
 * cause too much strain on network resources.
 *
 * @param url      The remote URL from where to get a certain file
 * @param response instance of the seqDownloadResponse method, which acts
 *                 as a callback to the main thread for this method
 */
- (void) downloadFileFrom:(NSString*) url
              andResponse:(saDidDownloadFile) response;

/**
 * This method is used to cleanup all existing files in the iOS
 * "documents directory" that may have been downloaded in a previous session.
 * This is useful so as to not end up with a lot of space being wasted
 * on the user's device.
 */
- (void) cleanup;

@end
