/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAFileDownloader.h"
#import "SAFileItem.h"
#import "SAFileQueue.h"

#define TIMEOUT_INTERVAL 10

@interface SAFileDownloader () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSUserDefaults *defs;
@property (nonatomic, strong) SAFileQueue *queue;
@property (nonatomic, strong) SAFileItem *currentItem;

@property (nonatomic, strong) NSURLSessionConfiguration *defaultConfigObject;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, assign) BOOL isDownloaderBusy;

@property (nonatomic, assign) NSInteger maxFileSize;
@property (nonatomic, assign) NSInteger downloadedSize;

@end

@implementation SAFileDownloader

+ (instancetype) getInstance {
    static SAFileDownloader *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

/**
 * Overridden "init" methid that initializes all the objects needed by the
 * singleton. Only called once.
 *
 * @return a new instance of the object, just once
 */
- (id) init {
    if (self = [super init]) {
        
        // set defs & file manager
        _defs = [NSUserDefaults standardUserDefaults];
        _fileManager = [NSFileManager defaultManager];
        
        // cleanup from past
        [self cleanup];
        
        // start queue & current item
        _queue = [[SAFileQueue alloc] init];
        _currentItem = nil;
        
        // set downloader not busy
        _isDownloaderBusy = false;
        
        // set default config object
        _defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // set a session
        _session = [NSURLSession sessionWithConfiguration:_defaultConfigObject
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return self;
}

- (void) downloadFileFrom:(NSString*) url
              andResponse:(saDidDownloadFile) response {
    
    // if File is already in queue
    if ([_queue hasItemForURL:url]) {
        
        NSLog(@"File already exists for URL %@", url);
        
        // get item
        SAFileItem *item = [_queue itemForURL:url];
        
        // get status
        BOOL isOnDisk = [item isOnDisk];
        
        // if File is already downloaded
        if (isOnDisk) {
            if (response != nil) {
                response (true, [item diskName]);
            }
        }
        // if File is not already downloaded
        else {
            [item addResponse:response];
        }
    }
    // if File is not already in queue
    else {
        
        NSLog(@"Adding new URL to queue %@", url);
        
        // create a new item
        SAFileItem *newItem = [[SAFileItem alloc] initWithUrl:url
                                           andInitialResponse:response];
        
        // if the new item is valid (e.g. valid url, disk path, key, etc)
        // then proceed with the operation
        if ([newItem isValid]) {
            
            // add the new item to queue
            [_queue addToQueue:newItem];
            
            // check on queue
            [self checkOnQueue];
        }
        // if it's not ok (e.g. invalid url) then respond w/ false
        else {
            if (response != nil) {
                response (false, nil);
            }
        }
    }
}

/**
 * This is a private method that checks on the current queue and see
 * if either the queue is ready to download something new or, if it's busy,
 * to add the current item to be downloaded to the queue for later use.
 */
- (void) checkOnQueue {
    
    // start the downloader if not busy
    if (!_isDownloaderBusy && [_queue getLength] > 0) {
        
        // pop the queue
        _currentItem = [_queue getNext];
        
        // if I could find a "next" item
        if (_currentItem != nil) {
            
            // if the current selected item's nr of retires is less than 3, then
            // try to download it
            if ([_currentItem hasRetriesRemaining]) {
                
                NSLog(@"Start work on queue for %@ Try %ld / 3", [_currentItem diskUrl], (long)([_currentItem nrRetries] + 1));
                
                // re-init state vars
                _maxFileSize = 0;
                _downloadedSize = 0;
                _isDownloaderBusy = true;
                
                // create a new request
                NSURL *url = [NSURL URLWithString:[_currentItem urlKey]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:url];
                [request setTimeoutInterval: TIMEOUT_INTERVAL];
                [request setHTTPMethod:@"GET"];
                
                // create the task
                _task = [_session downloadTaskWithRequest:request];
                
                // start the task
                [_task resume];
                
            }
            // if I've tried for more than 3 times, just take the next item
            else {
                
                // send error responses
                for (saDidDownloadFile response in [_currentItem responses]) {
                    response (false, nil);
                }
                
                // clear responses
                [_currentItem clearResponses];
                
                // permanently remove
                [_queue removeFromQueue:_currentItem];
                
                // go to next on queue
                [self checkOnQueue];
            }
        }
    }
}

/**
 * Overridden "NSURLSessionDataDelegate" method that gets called when a new
 * piece of that has been downloaded.
 *
 * @param session                      the current URL session instance
 * @param downloadTask                 the current download tesk instance
 * @param bytesWritten                 the number of bytes written this time
 * @param totalBytesWritten            the total number of bytes written
 * @param totalBytesExpectedToWrite    the total file size
 */
- (void)URLSession:(NSURLSession*) session
      downloadTask:(NSURLSessionDownloadTask*) downloadTask
      didWriteData:(int64_t) bytesWritten
 totalBytesWritten:(int64_t) totalBytesWritten
totalBytesExpectedToWrite:(int64_t) totalBytesExpectedToWrite {
    
    // 1. get total
    int64_t totali = totalBytesExpectedToWrite;
    float total = 1.0f;
    
    if (totali == 0 || totali == -1) {
        NSDictionary *responseHeaders = ((NSHTTPURLResponse *)downloadTask.response).allHeaderFields;
        NSString *contentLength = [responseHeaders objectForKey:@"Content-Length"];
        if (contentLength != nil) {
            total = (float) [contentLength integerValue];
        }
    } else {
        total = (float) totali;
    }
    
    // 2. get current
    float written = (float) totalBytesWritten;
    
    // 3. get an int percent
    int percent = (int) ((float) ((written / total) * 100));
    
    // 4. print the current download status
    if (percent % 10 == 0) {
        NSLog(@"Downloaded %.2f %%", (float) ((written / total) * 100));
    }
}

/**
 * Overridden "NSURLSessionDataDelegate" method that gets called when a new
 * file has been downloaded
 *
 * @param session      the current URL session instance
 * @param downloadTask the current download tesk instance
 * @param location     the final location that the file has been downloaded to
 */
- (void) URLSession:(NSURLSession*) session
       downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
    
    NSLog(@"Finished %@ ==> %@", [_currentItem urlKey] , [_currentItem diskName]);
    
    // and a destinationURL
    NSURL *destURL = [NSURL fileURLWithPath:[_currentItem diskUrl]];
    
    // move the file
    NSError *fileError = nil;
    [_fileManager moveItemAtURL:location toURL:destURL error:&fileError];
    
    // save to be able to delete afterwards
    if (fileError == nil) {
        [_defs setObject:[_currentItem diskName] forKey:[_currentItem key]];
        [_defs synchronize];
    }
    
    // send responses
    for (saDidDownloadFile response in [_currentItem responses]) {
        response (true, [_currentItem diskName]);
    }
    
    // set on disk
    [_currentItem setIsOnDisk:true];
    
    // clear responses
    [_currentItem clearResponses];
    
    // download is not busy at the moment
    _isDownloaderBusy = false;
    
    // check again for queue
    [self checkOnQueue];
}

/**
 * Overridden "NSURLSessionDataDelegate" method that gets called when a file
 * has encountered an error while trying to download
 *
 * @param session      the current URL session instance
 * @param downloadTask the current session tesk instance
 * @param error        error object describing what's happened
 */
- (void) URLSession:(NSURLSession *)session
               task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    
    if (error) {
        NSLog(@"Errored for %@ with %@", [_currentItem diskUrl], [error localizedDescription]);
        
        // set downloader not busy
        _isDownloaderBusy = false;
        
        // add the current item again at the back of the queue
        [_currentItem incrementNrRetries];
        [_currentItem setIsOnDisk:false];
        [_queue moveToBackOfQueue:_currentItem];
        
        // check on queue again
        [self checkOnQueue];
    }
}

/**
 * Method that takes a file path (a simple name) and returns it's full path
 * as it would be in the iOS Documents directory.
 *
 * @param fpath    the name of the file
 * @return         the full file name with documents directory added
 */
- (NSString*) filePathInDocuments:(NSString*)fpath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return [basePath stringByAppendingPathComponent:fpath];
}

- (void) cleanup {
    
    NSMutableArray<NSString*> *keysToDel = [@[] mutableCopy];
    
    for (NSString *key in [[_defs dictionaryRepresentation] allKeys]) {
        
        if ([key rangeOfString:SA_KEY_PREFIX].location != NSNotFound) {
            
            NSString *filePath = [_defs objectForKey:key];
            NSString *fullFilePath = [self filePathInDocuments:filePath];
            
            if ([_fileManager fileExistsAtPath:fullFilePath] && [_fileManager isDeletableFileAtPath:fullFilePath]) {
                [_fileManager removeItemAtPath:fullFilePath error:nil];
                NSLog(@"[true] | DEL | %@", filePath);
            } else {
                NSLog(@"[false] | DEL | %@", filePath);
            }
            
            [keysToDel addObject:key];
        }
    }
    
    for (NSString* key in keysToDel) {
        [_defs removeObjectForKey:key];
    }
    [_defs synchronize];
}



@end
