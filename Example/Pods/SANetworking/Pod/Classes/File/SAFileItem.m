/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAFileItem.h"

#define MAX_RETRIES 3

@implementation SAFileItem

- (id) init {
    if (self = [super init]) {
        _urlKey = nil;
        _diskName = nil;
        _key = nil;
        _diskUrl = nil;
        _isOnDisk = false;
        _nrRetries = 0;
        _responses = [@[] mutableCopy];
    }
    
    return self;
}

- (id) initWithUrl:(NSString *)url {
    if (self = [self init]) {
        // get the URL Key
        _urlKey = url;
        
        // get the disk location
        _diskName = [self getNewDiskName:_urlKey];
        if (_diskName != nil) {
            _diskUrl = [NSString stringWithFormat:@"%@/%@", [self getDocumentsDirectory], _diskName];
            _key = [self getKeyFromDiskName:_diskName];
        }
    }
    
    return self;
}

- (id) initWithUrl:(NSString *)url andInitialResponse:(id)firstResponse {
    if (self = [self initWithUrl:url]) {
        [self addResponse:firstResponse];
    }
    
    return self;
}

- (void) incrementNrRetries {
    _nrRetries++;
}

- (BOOL) hasRetriesRemaining {
    return _nrRetries < MAX_RETRIES;
}

- (void) clearResponses {
    [_responses removeAllObjects];
}

- (void) addResponse:(id)response {
    if (response != nil && response != [NSNull null]) {
        [_responses addObject:response];
    }
}

- (NSString*) getNewDiskName:(NSString*) url {
    return url != nil && url != (NSString*)[NSNull null] && ![url isEqualToString:@""] ? [url lastPathComponent] : nil;
}

- (NSString*) getDocumentsDirectory {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

- (NSString*) getKeyFromDiskName:(NSString*)name {
    return [NSString stringWithFormat:@"%@%@", SA_KEY_PREFIX, name];
}

- (BOOL) isValid {
    return _urlKey != nil && _diskName != nil && _diskUrl != nil && _key != nil;
}



@end
