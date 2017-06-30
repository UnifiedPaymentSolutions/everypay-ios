//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import "BasedApi.h"

NSString *const kApiVersion = @"api_version";

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
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[kApiVersion] = self.apiVersion;
    NSData *requestData = [self convertToDataWithDictionary:requestDictionary];
    EPLog(@"Request body %@", [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding]);
    NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            EPLog(@"Request completed with response\n %@", response);
            if (error) {
                handler(response, nil, error);
                return;
            }
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (jsonParsingError) {
                handler(response, nil, jsonParsingError);
                return;
            }
            EPLog(@" Get Merchant Data Response body %@", responseDictionary);
            success(responseDictionary);

        });
    }];

    [uploadTask resume];
}

- (NSData *)convertToDataWithDictionary:(NSDictionary *)dictionary {
    NSError *jsonConversionError;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&jsonConversionError];
    return requestData;

}

@end