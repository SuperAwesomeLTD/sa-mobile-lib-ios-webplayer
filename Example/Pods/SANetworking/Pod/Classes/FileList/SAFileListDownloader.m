/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAFileListDownloader.h"
#import "SAFileDownloader.h"

// callback for generic success with data
typedef void (^saDidDownloadFileAtIndex)(NSInteger index, BOOL success, NSString *diskUrl);


/**
 * Class that defines a file list item - that's going to be used by the
 * SAFileListDownloader class to help out in downloading a list of files
 * in the correct order.
 */
@interface SAFileListItem : NSObject

// member variables - the file index and the file path
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *file;

/**
 * Constructor that requires and index and a file path
 *
 * @param index    the index of the file that's being downloaded
 * @param file     the path of the file that's being downloaded
 * @return         a new object instance
 */
- (id) initWith:(NSInteger) index
        andFile:(NSString*) file;

@end

@implementation SAFileListItem

- (id) initWith:(NSInteger)index
        andFile:(NSString*)file {
    if (self = [super init]) {
        _index = index;
        _file = file;
    }
    
    return self;
}

/**
 * Comparison method that facilitates sorting on arrays of SAFileListItem
 * objects.
 *
 * @param other    another instance of the object, from an array
 * @return         a comparison result equating to greater, lower, equal
 */
- (NSComparisonResult) compare:(SAFileListItem*) other {
    if (_index > other.index) return NSOrderedAscending;
    if (_index < other.index) return NSOrderedDescending;
    return NSOrderedSame;
}

@end

@interface SAFileListDownloader ()

// a local property holding the response
@property (nonatomic, strong) saDidDownloadFilesInList response;

@end

@implementation SAFileListDownloader

/**
 * Custom overridden init that initializes the "response" callback parameter
 */
- (id) init {
    if (self = [super init]) {
        _response = ^(NSArray<NSString*> *files){};
    }
    
    return self;
}

- (void) downloadListOfFiles:(NSArray<NSString*> *)files withResponse:(saDidDownloadFilesInList) response {
    
    // get local non-null copy
    _response = response ? response : _response;
    
    // get the max number of files and the total downloaded files
    __block NSInteger max = [files count];
    __block NSInteger totalFilesDownloaded = 0;
    
    // get a block-scoped array of files that already have been downloaded
    __block NSMutableArray *filesDownloaded = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < max; i++) {
        
        __block NSInteger finalI = i;
        
        // get each file
        [self getFileAt:finalI withUrl:files[i] andResponse:^(NSInteger index, BOOL success, NSString *diskUrl) {
           
            [filesDownloaded addObject:[[SAFileListItem alloc] initWith:index andFile:diskUrl]];
            totalFilesDownloaded++;
            
            // at the end
            if (totalFilesDownloaded == max) {
                
                // sort array of
                NSArray <SAFileListItem*> *sorted = [filesDownloaded sortedArrayUsingSelector:@selector(compare:)];
                
                // get a string array
                NSMutableArray <NSString*> *resultArray = [@[] mutableCopy];
                
                for (SAFileListItem *item in sorted) {
                    if (item.file != nil && item.file != (NSString*)[NSNull null]) {
                        [resultArray addObject:item.file];
                    } else {
                        [resultArray addObject:(NSString*)[NSNull null]];
                    }
                }
                
                // call this
                _response (resultArray);
            }
            
        }];
    }
}

/**
 * Method that wraps the SAFileDownloader "downloadFileFrom" method and
 * returns a callback method that specifies the order in which the file
 * should be put back as well as the disk url
 *
 * @param index     the order (array index) at which the new result
 *                   should be put in
 * @param file      the remote file url to be downloaded
 * @param response  instance of the saDidDownloadFileAtIndex to send the 
 *                   message back to the calling method
 */
- (void) getFileAt:(NSInteger)index withUrl:(NSString*)file andResponse:(saDidDownloadFileAtIndex) response {
    
    [[SAFileDownloader getInstance] downloadFileFrom:file andResponse:^(BOOL success, NSString *diskPath) {
       
        // send this
        response (index, success, diskPath);
        
    }];
    
}

@end
