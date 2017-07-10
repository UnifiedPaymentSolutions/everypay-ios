//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import "BasedApi.h"
#import "NSError+Additions.h"

NSString *const kApiVersion = @"api_version";

NSString *const kKeyErrors = @"errors";
NSString *const kKeyMessage = @"message";
NSString *const kKeyCode = @"code";
NSInteger const EP_DEFAULT_TIMEOUT = 30;

@interface BasedApi ()
@property(nonatomic, strong) NSString *apiVersion;
@property(nonatomic, strong) NSURLSession *urlSession;
@end

@implementation BasedApi {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.apiVersion = @"2";
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        conf.TLSMinimumSupportedProtocol = kTLSProtocol11;
        self.urlSession = [NSURLSession sessionWithConfiguration:conf delegate:nil delegateQueue:nil];
        self.timeout = EP_DEFAULT_TIMEOUT;
    }
    return self;
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
//    FIXME: maybe need refactor this part
    self.urlSession.configuration.timeoutIntervalForRequest = self.timeout;
    self.urlSession.configuration.timeoutIntervalForResource = self.timeout;
}


- (void)execute:(NSMutableURLRequest *)request parameters:(NSDictionary *)parameters completionHandler:(completionHandler)handler {
    completionHandler handlerCopy = [handler copy];
    if (parameters == nil)
        parameters = @{};
    NSError *jsonConversionError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&jsonConversionError];
    if (jsonConversionError) {
        EPLog(@"> JsonConversionError: %@\n", jsonConversionError);
        handlerCopy(nil, nil, @[jsonConversionError]);
        return;
    }
    EPLog(@"> URL: %@\n", request);
    EPLog(@"> METHOD: %@\n", request.HTTPMethod);
    EPLog(@"> HEADERS: %@\n", request.allHTTPHeaderFields);
    EPLog(@"> BODY: %@\n", parameters);
    __strong void (^completionTaskHandler)(NSData *, NSURLResponse *, NSError *)=^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            EPLog(@"< Response: %@\n", response);
            if (error) {
                EPLog(@"< Error: %@\n", error);
                handlerCopy(response, nil, @[error]);
                return;
            }
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (jsonParsingError) {
                EPLog(@"< JsonParsingError: %@\n", error);
                handlerCopy(response, nil, @[jsonParsingError]);
                return;
            }
            EPLog(@"< Response body %@\n", responseDictionary);
            NSArray *errors = [BasedApi errorsFromDictionary:responseDictionary];
            if ([errors count] > 0) {
                EPLog(@"< Error processing payment: %@\n", errors);
                handlerCopy(response, nil, errors);
                return;
            }
            handlerCopy(response, responseDictionary, nil);
        });
    };
    NSURLSessionDataTask *uploadTask;
    if ([request.HTTPMethod isEqual:@"GET"])
        uploadTask = [self.urlSession dataTaskWithRequest:request completionHandler:completionTaskHandler];
    else
        uploadTask = [self.urlSession uploadTaskWithRequest:request fromData:requestData completionHandler:completionTaskHandler];
    [uploadTask resume];
}


/** Errordictionary has the following structure:
 {
 errors =     (
 {
 code = 2055;
 message = "Unknown api_user '7e250861ef710b10'";
 },
 {
 code = 2067;
 message = "Missing processing account field";
 },
 {
 code = 2068;
 message = "The processing account '' is invalid";
 }
 );
 }

 */
+ (NSArray *)errorsFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *returnArray = [NSMutableArray array];
    NSArray *errorsArray = dictionary[kKeyErrors];
    for (NSDictionary *errorDictionary in errorsArray) {
        NSInteger code = [errorDictionary[kKeyCode] integerValue];
        NSString *message = errorDictionary[kKeyMessage];
        NSError *error = [NSError errorWithDescription:message andCode:code];
        [returnArray addObject:error];
    }
    return [returnArray copy];
}

- (NSMutableURLRequest *)getPostRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"POST";
    return request;
}

- (void)dealloc {
    EPLog(@"dealloc: %@", [self class]);
}

@end