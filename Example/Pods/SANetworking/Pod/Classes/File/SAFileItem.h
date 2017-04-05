/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>

#define SA_KEY_PREFIX @"sasdkkey_"

/**
 * This class represents a single File Item - an object that
 * tries to group two pieces of
 * information:
 *  - the details of where a file is downloaded (and if it has been
 *    successfully downloaded)
 *  - all the possible 3rd parties that would be interested in knowing
 *    if the file has been downloaded (by using a List of
 *    seqDownloadResponse to keep a track of who needs to be notified)
 */
@interface SAFileItem : NSObject

@property (nonatomic, strong) NSString *urlKey;
@property (nonatomic, strong) NSString *diskName;
@property (nonatomic, strong) NSString *diskUrl;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) BOOL isOnDisk;
@property (nonatomic, assign) NSInteger nrRetries;

// an array of of responses / callbacks to be called when a file has
// been downloaded, in order to communicate to library users
@property (nonatomic, strong) NSMutableArray *responses;

/**
 * Init with a single file Url to be downloaded
 *
 * @param  url     the url of the file to be downloaded
 * @return id      a new instance of the object
 */
- (id) initWithUrl:(NSString *) url;

/**
 * Init with a single file Url to be downloaded and the first response
 *
 * @param  url             the url of the file to be downloaded
 * @param  firstResponse   the first response callback to be added to the
 *                         "responses" array
 * @return                 a new instance of the object
 */
- (id) initWithUrl:(NSString *) url
andInitialResponse:(id)firstResponse;

/**
 * Method that increments the number of retries a file item still has
 */
- (void) incrementNrRetries;

/**
 * Method that checks if a certain file item has retries remaining
 *
 * @return if it still has retries or not
 */
- (BOOL) hasRetriesRemaining;

/**
 * Method that clears the array of responses
 */
- (void) clearResponses;

/**
 * Method that adds a new response to the end of the "responses" array
 *
 * @param response     a new response (of type id)
 */
- (void) addResponse:(id)response;

/**
 * Method that takes a valuid url and returns a disk url
 *
 * @param url       a valid url
 * @return          a valid disk url
 */
- (NSString*) getNewDiskName:(NSString*) url;

/**
 * Method that gets the document dicrectory
 *
 * @return the name of the iOS documents directory
 */
- (NSString*) getDocumentsDirectory;

/**
 * Get a valid dictionary Key from a disk name
 *
 * @return the name of the Key
 */
- (NSString*) getKeyFromDiskName:(NSString*) name;

/**
 * Checks the file item for validity
 *
 * @return true or false
 */
- (BOOL) isValid;

@end
