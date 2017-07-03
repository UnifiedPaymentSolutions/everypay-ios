//
//  EPMerchantApi.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "EPMerchantApi.h"
#import "EPMerchantInfo.h"
#import "EPEncryptedPaymentInstrument.h"


NSString *const kGetMerchantInfoPath = @"/merchant_mobile_payments/generate_token_api_parameters";
NSString *const kSendPaymentPath = @"/merchant_mobile_payments/pay";

@interface EPMerchantApi ()
@end

@implementation EPMerchantApi
- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)getMerchantDataByAccountId:(NSString *)accountId success:(void (^)(EPMerchantInfo *))successCallback failure:(failureHandler)failureCallback {
    void (^successCallbackCopy)(EPMerchantInfo *)=[successCallback copy];
    failureHandler failureCallbackCopy = [failureCallback copy];

    NSURL *url = [NSURL URLWithString:kGetMerchantInfoPath relativeToURL:self.url];
    NSMutableURLRequest *request = [self getPostRequestWithURL:url];
    NSDictionary *parameters = accountId == nil ? @{} : @{
            kKeyAccountId: accountId,
            kApiVersion: self.apiVersion,
    };
    [self execute:request parameters:parameters completionHandler:^(NSURLResponse *rawResponse, NSDictionary *jsonResponse, NSArray<NSError *> *errors) {
        if (errors) {
            failureCallbackCopy(errors);
            return;
        }
        EPMerchantInfo *merchantInfo = [[EPMerchantInfo alloc] initWithDictionary:jsonResponse];
        successCallbackCopy(merchantInfo);
    }];
}

- (void)getMerchantDataWithSuccess:(void (^)(EPMerchantInfo *))successCallback failure:(failureHandler)failureCallback {
    [self getMerchantDataByAccountId:nil success:successCallback failure:failureCallback];
}

- (void)sendCardToken:(NSString *)tokenEncrypted hmac:(NSString *)hmac success:(void (^)(void))successCallback failure:(failureHandler)failureCallback {
    void (^successCallbackCopy)(void)=[successCallback copy];
    failureHandler failureCallbackCopy = [failureCallback copy];

    NSURL *url = [NSURL URLWithString:kSendPaymentPath relativeToURL:self.url];
    NSMutableURLRequest *request = [self getPostRequestWithURL:url];
    NSDictionary *parameters = @{
            kKeyEncryptedToken: tokenEncrypted,
            kKeyHmac: hmac,
            kApiVersion: self.apiVersion,
    };
    [self execute:request parameters:parameters completionHandler:^(NSURLResponse *rawResponse, NSDictionary *jsonResponse, NSArray<NSError *> *error) {
    }];
}
@end
