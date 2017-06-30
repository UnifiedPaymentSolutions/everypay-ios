//
//  EPMerchantApi.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "EPMerchantApi.h"
#import "EPMerchantInfo.h"


NSString *const kGetMerchantInfoPath = @"/merchant_mobile_payments/generate_token_api_parameters";
NSString *const kSendPaymentPath = @"/merchant_mobile_payments/pay";

@interface EPMerchantApi ()
@property(nonatomic, strong) NSURL *url;
@end

@implementation EPMerchantApi
- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}


- (void)getMerchantDataWithSuccess:(void (^)(EPMerchantInfo *))successCallback failure:(void (^)(NSError *))failureCallback {
    void (^successCallbackCopy)(EPMerchantInfo *)=[successCallback copy];
    void (^failureCallbackCopy)(NSError *)=failureCallback;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = @"POST";

    EPLog(@"Start request %@\n", request);
    EPLog(@"Header request %@\n", request.allHTTPHeaderFields);

    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[self.apiVersion] = kApiVersion;
    NSData *requestData = [EPMerchantApi convertToDataWithDictionary:requestDictionary];
    EPLog(@"Request body %@", [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding]);

//    NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        EPLog(@"Request completed with response\n %@", response);
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                failure(error);
//            });
//        } else {
//            NSError *jsonParsingError;
//            NSDictionary *responseDictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
//            EPLog(@" Get Merchant Data Response body %@", responseDictionary);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                success(responseDictionary);
//            });
//        }
//    }];
//
//    [uploadTask resume];
    [self execute:request parameters:@{} completionHandler:^(NSURLResponse *rawResponse, NSDictionary *jsonResponse, NSError *error) {
    }];
}

- (void)sendPaymentWithToken:(NSString *)token andMerchantInfo:(NSDictionary *)merchantInfo withSuccess:(DictionarySuccessBlock)success andError:(FailureBlock)failure {
    NSURL *merchantApiBaseUrl = [NSURL URLWithString:self.merchantApiBaseUrl];
    NSURL *url = [NSURL URLWithString:kSendPaymentPath relativeToURL:merchantApiBaseUrl];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    EPLog(@"Start request %@\n", request);
    EPLog(@"Header request %@\n", request.allHTTPHeaderFields);

    NSString *hmac = merchantInfo[kKeyHmac];
    NSDictionary *requestDictionary = @{kKeyHmac: hmac, kKeyEncryptedToken: token};
    NSError *jsonConversionError = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:kNilOptions error:&jsonConversionError];
    EPLog(@"Request body %@", [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding]);
    NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        EPLog(@"Request completed with response\n %@", response);

        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        } else {
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];
            EPLog(@" Send payment response body %@", requestDictionary);
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseDictionary);
            });
        }
    }];

    [uploadTask resume];
}
@end
