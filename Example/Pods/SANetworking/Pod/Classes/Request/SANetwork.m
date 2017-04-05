/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

// file header
#import "SANetwork.h"

@implementation SANetwork

/**
 * This is the generic request method.
 * It abstracts away the standard iOS NSURLSession wraps it so that it just
 * returns a callback.
 * This method does not get exposed to the public; Rather, sister methods
 * like sendPUT, sendGET, etc, will be presented as public.
 *
 * @param endpoint  URL to send the request to
 * @param method    the HTTP method to be executed, as a string.
 *                  Based on the methods possible in iOS
 *                  (OPTIONS, GET, HEAD, POST, PUT, DELETE and TRACE)
 * @param query     a NSDictionary object containing all the query parameters
 *                  to be added to an URL (mostly for a GET type request)
 * @param header    a NSDictionary object containing all the header
 *                  parameters to be added to the request
 * @param body      a NSDictionary object containing all the body
 *                  parameters to be added to a PUT or POST request
 * @param response  a method of type saDidGetResponse to be used as a
 *                  callback mechanism when the network operation
 *                  finally succeeds
 */
- (void) sendRequestTo:(NSString*)endpoint
            withMethod:(NSString*)method
              andQuery:(NSDictionary*)query
             andHeader:(NSDictionary*)header
               andBody:(NSDictionary*)body
          withResponse:(saDidGetResponse) response {
    
    // check the URL for nullness
    if (endpoint == nil || endpoint == (NSString*)[NSNull null]) {
        response(0, nil, false);
        return;
    }
    
    // form main URL
    __block NSMutableString *_mendpoint = [endpoint mutableCopy];
    if (query != nil && query != (NSDictionary*)[NSNull null] && query.allKeys.count > 0) {
        [_mendpoint appendString:@"?"];
        [_mendpoint appendString:[self formGetQueryFromDict:query]];
    }
    
    // get the actual URL
    NSURL *url = [NSURL URLWithString:_mendpoint];
    
    // create the requrest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:method];
    
    // set headers
    if (header != nil && header != (NSDictionary*)[NSNull null] && header.allKeys.count > 0) {
        for (NSString *key in header.allKeys) {
            [request setValue:[header objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // set body, if post
    if (([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) &&
         body != nil && body != (NSDictionary*)[NSNull null] && body.allKeys.count > 0) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
    }
    
    // get the response handler
    id resp = ^(NSData *data, NSURLResponse *httpresponse, NSError *error) {
        
        // handle two failure cases
        if (error != nil || data == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[false] | HTTP %@ | 0 | %@", method, _mendpoint);
                if (response != nil) {
                    response(0, nil, false);
                }
            });
            return;
        }
        
        // get actual result
        NSInteger status = ((NSHTTPURLResponse*)httpresponse).statusCode;
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // send response on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[true] | HTTP %@ | %ld | %@", method, (long)status, _mendpoint);
            if (response != nil) {
                response(status, payload, true);
            }
        });
    };
    
    // start the session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:resp];
    [task resume];
}

- (void) sendGET:(NSString*)endpoint
       withQuery:(NSDictionary*)query
       andHeader:(NSDictionary*)header
    withResponse:(saDidGetResponse)response {
    [self sendRequestTo:endpoint withMethod:@"GET" andQuery:query andHeader:header andBody:nil withResponse:response];
}

- (void) sendPOST:(NSString*)endpoint
        withQuery:(NSDictionary*)query
        andHeader:(NSDictionary*)header
          andBody:(NSDictionary*)body
     withResponse:(saDidGetResponse)response {
    [self sendRequestTo:endpoint withMethod:@"POST" andQuery:query andHeader:header andBody:body withResponse:response];
}

- (void) sendPUT:(NSString *)endpoint
       withQuery:(NSDictionary *)query
       andHeader:(NSDictionary *)header
         andBody:(NSDictionary *)body
    withResponse:(saDidGetResponse)response {
    [self sendRequestTo:endpoint withMethod:@"PUT" andQuery:query andHeader:header andBody:body withResponse:response];
}


/**
 * This method takes a NSDictionary paramter and returns it as a valid
 * GET query string (e.g. a JSON { "name": "John", "age": 23 }
 * would become "name=John&age=23"
 *
 * @param dict  a NSDictionary object to be transformed into a
 *              GET query string
 * @return      a valid GET query string
 */
- (NSString*) formGetQueryFromDict:(NSDictionary *)dict {
    NSMutableString *query = [[NSMutableString alloc] init];
    NSMutableArray *getParams = [[NSMutableArray alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [getParams addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    [query appendString:[getParams componentsJoinedByString:@"&"]];
    
    return query;
}

@end
