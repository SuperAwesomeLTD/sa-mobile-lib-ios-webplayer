/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */
#import <UIKit/UIKit.h>

// callback for generic success with downloading all files
typedef void (^saDidDownloadFilesInList)(NSArray <NSString*> *diskLocations);

/**
 * Class that abstracts all the problems of downloading several files
 * one-at-a-time in a list
 */
@interface SAFileListDownloader : NSObject

/**
 * Main method that starts the download process
 *
 * @param files     a list of remote files
 * @param response  the final callback to give library users a way of knowing
 *                  when it will all end
 */
- (void) downloadListOfFiles:(NSArray<NSString*> *)files
                withResponse:(saDidDownloadFilesInList) response;

@end
