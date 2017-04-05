/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import <UIKit/UIKit.h>

@class SAFileItem;

/**
 * This class operates on a list of SAFileItem objects and acts as
 * a queue with limited functionality
 */
@interface SAFileQueue : NSObject

/**
 * This method adds another item to the queue
 *
 * @param item a new item that's going to be checked for nullness
 */
- (void) addToQueue:(SAFileItem*)item;

/**
 * This method removes a specified item from the queue
 *
 * @param item the item that's going to be removed; checked for nullness
 */
- (void) removeFromQueue:(SAFileItem*)item;

/**
 * This method moves an already existing item to the back of the queue
 * by first removing the item, and them adding it again
 *
 * @param item the item that's going to be moved to the back
 */
- (void) moveToBackOfQueue:(SAFileItem*)item;

/**
 * Specific method that checks if there is at least one SAFileItem
 * element in the queue that corresponds to the url given as paramter
 *
 * @param url   given URL parameter
 * @return      returns true or false if at least one element is found
 */
- (BOOL) hasItemForURL:(NSString*)url;

/**
 * Method that returns the SAFileItem specific for a given url
 *
 * @param url   given URL parameter
 * @return      return the item or null
 */
- (SAFileItem*) itemForURL:(NSString*)url;

/**
 * Method that returns the next item in queue
 *
 * @return  the next item or null, if none was found
 */
- (SAFileItem*) getNext;

/**
 * Method that returns the current length of the queue
 *
 * @return shorthand for queue.size ()
 */
- (NSInteger) getLength;

@end
