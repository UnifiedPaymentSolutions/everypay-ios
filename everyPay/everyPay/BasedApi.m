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
    }

    return self;
}

- (void)execute:(NSMutableURLRequest *)request parameters:(NSDictionary *)parameters completionHandler:(completionHandler)handler {
    completionHandler handlerCopy = [handler copy];
    NSError *jsonConversionError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&jsonConversionError];
    if (jsonConversionError) {
        handlerCopy(nil, nil, @[jsonConversionError]);
        return;
    }
    EPLog(@"> URL: %@\n", request);
    EPLog(@"> HEADERS: %@\n", request.allHTTPHeaderFields);
    EPLog(@"> BODY: %@\n", parameters);
    NSURLSessionUploadTask *uploadTask = [self.urlSession uploadTaskWithRequest:request fromData:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    }];
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

@end