/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAFileQueue.h"
#import "SAFileItem.h"

@interface SAFileQueue ()

// the queue
@property (nonatomic, strong) NSMutableArray *queue;

@end

@implementation SAFileQueue

- (id) init {
    if (self = [super init]) {
        
        // init queue
        _queue = [@[] mutableCopy];
    }
    
    return self;
}

- (void) addToQueue:(SAFileItem *)item {
    if (item != nil && item != (SAFileItem*)[NSNull null]) {
        [_queue addObject:item];
    }
}

- (void) removeFromQueue:(SAFileItem *)item {
    if (item != nil && item != (SAFileItem*)[NSNull null]) {
        [_queue removeObject:item];
    }
}

- (void) moveToBackOfQueue:(SAFileItem *)item {
    [self removeFromQueue:item];
    [self addToQueue:item];
}

- (NSInteger) getLength {
    return [_queue count];
}

- (BOOL) hasItemForURL:(NSString *)url {
    
    for (SAFileItem *item in _queue) {
        if ([[item urlKey] isEqualToString:url]) {
            return true;
        }
    }
    
    return false;
}

- (SAFileItem*) itemForURL:(NSString *)url {
    
    for (SAFileItem *item in _queue) {
        if ([[item urlKey] isEqualToString:url]) {
            return item;
        }
    }
    
    return nil;
}

- (SAFileItem*) getNext {
    
    for (SAFileItem *item in _queue) {
        if (![item isOnDisk]) {
            return item;
        }
    }
    
    return nil;
}

@end
