//
//  EPApi.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "EPApi.h"
#import "EPCard.h"
#import "EPMerchantInfo.h"
#import "EPEncryptedPaymentInstrument.h"
#import "NSError+Additions.h"

NSString *const kEveryPayApiDemo = @"https://gw-demo.every-pay.com";
NSString *const kEveryPayApiStaging = @"https://gw-staging.every-pay.com";
NSString *const kEveryPayApiLive = @"https://gw.every-pay.eu";

NSString *const kSendCardDetailsPath = @"encrypted_payment_instruments";

NSString *const kKeyEncryptedPaymentInstrument = @"encrypted_payment_instrument";

NSString *const kParamHmac = @"mobile_3ds_hmac";
NSString *const kKeyApiVersion = @"api_version";


@interface EPApi ()
@end


@implementation EPApi
- (instancetype)initWithEnv:(EPAPIEnvTypes)envType {
    NSString *string;
    self = [super init];
    if (self) {
        switch (envType) {
            case EPAPIEnvTypeDemo:
                string = kEveryPayApiDemo;
                break;
            case EPAPIEnvTypeStanding:
                string = kEveryPayApiStaging;
                break;
            case EPAPIEnvTypeLive:
                string = kEveryPayApiLive;
                break;
        }
        self.url = [[NSURL alloc] initWithString:string];
    }
    return self;
}

/**
       Response dictionary for non 3Ds response:
       {
          "encrypted_payment_instrument" = {
              "cc_token_encrypted" = "QEVuQwBAEAAcXJQdBNP2fcVbANPoc+KdE9flBsC4O8hZQPut4MLjMKAVjTt9JDI8eqTpYiDH9dE=-1440501330";
              "payment_state" = "authorised"
          };
       }

       Response dictionary for 3Ds response:
          "encrypted_payment_instrument": {
              "payment_reference":"0aa6409492f358da0fb6d9b821ce6ca4a5609073489dcaf3456023cafca96efa",
              "payment_state":"waiting_for_3ds_response",
              "secure_code_one":"XyIfP0b7giwcJma24axOaQt2m96F/ThG62Ptd5rsX4Bj7tSAM/pfgD"
          }

**/

- (void)sendCard:(EPCard *)card merchantInfo:(EPMerchantInfo *)merchantInfo success:(void (^)(EPEncryptedPaymentInstrument *response))successCallback failure:(failureHandler)failureCallback {
    void (^successCallbackCopy)(EPEncryptedPaymentInstrument *)=[successCallback copy];
    failureHandler failureCallbackCopy = [failureCallback copy];

    NSURL *url = [NSURL URLWithString:kSendCardDetailsPath relativeToURL:self.url];
    NSMutableURLRequest *request = [self getPostRequestWithURL:url];

    NSMutableDictionary *merchantDictionary = [[merchantInfo toDictionary] mutableCopy];
    [merchantDictionary addEntriesFromDictionary:[card toDictionary]];
    merchantDictionary[kApiVersion] = self.apiVersion;

    NSDictionary *requestDictionary = @{kKeyEncryptedPaymentInstrument: [merchantDictionary copy]};
    [self executeApiRequest:request parameters:requestDictionary success:successCallbackCopy failure:failureCallbackCopy];
}

- (void)encryptedPaymentInstrumentsConfirmedWith:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo success:(void (^)(EPEncryptedPaymentInstrument *response))successCallback failure:(failureHandler)failureCallback {
    void (^successCallbackCopy)(EPEncryptedPaymentInstrument *)=[successCallback copy];
    failureHandler failureCallbackCopy = [failureCallback copy];

    NSURL *url = [self getURLEncryptedPaymentInstrumentsConfirmedWith:encryptedPaymentInstrument merchantInfo:merchantInfo];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    [self executeApiRequest:request parameters:nil success:successCallbackCopy failure:failureCallbackCopy];
}

- (void)executeApiRequest:(NSMutableURLRequest *)request parameters:(NSDictionary *)parameters success:(void (^)(EPEncryptedPaymentInstrument *))successCallback failure:(failureHandler)failureCallback {
    [self execute:request parameters:parameters completionHandler:^(NSURLResponse *rawResponse, NSDictionary *jsonResponse, NSArray<NSError *> *errors) {
        if (errors) {
            failureCallback(errors);
            return;
        }
        NSDictionary *encryptedPaymentInstrumentResponse = jsonResponse[kKeyEncryptedPaymentInstrument];
        if (![encryptedPaymentInstrumentResponse isKindOfClass:[NSDictionary class]]) {
            NSError *error = [NSError errorWithDescription:@"Not found key kKeyEncryptedPaymentInstrument in dictionary" andCode:1001];
            failureCallback(@[error]);
            return;
        }
        successCallback([[EPEncryptedPaymentInstrument alloc] initWithDictionary:encryptedPaymentInstrumentResponse]);
    }];
}

- (NSURL *)getURLFor3dsResponseWith:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo {
    NSURLQueryItem *paymentRef = [NSURLQueryItem queryItemWithName:kKeyPaymentReference value:encryptedPaymentInstrument.paymentReference];
    NSURLQueryItem *secureCode = [NSURLQueryItem queryItemWithName:kKeySecureCodeOne value:encryptedPaymentInstrument.secureCodeOne];
    NSURLQueryItem *mobile3DsHmac = [NSURLQueryItem queryItemWithName:kParamHmac value:merchantInfo.hmac];
    NSURLQueryItem *apiVer = [NSURLQueryItem queryItemWithName:kKeyApiVersion value:self.apiVersion]; // todo: need to test

    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:self.url.host];
    [components setPath:@"/authentication3ds/new"];
    [components setQueryItems:@[paymentRef, secureCode, mobile3DsHmac, apiVer]];
    return [components URL];
}

- (NSURL *)getURLEncryptedPaymentInstrumentsConfirmedWith:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo {
    NSURLQueryItem *mobile3DsHmac = [NSURLQueryItem queryItemWithName:kParamHmac value:merchantInfo.hmac];
    NSURLQueryItem *apiVer = [NSURLQueryItem queryItemWithName:kKeyApiVersion value:self.apiVersion];

    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:self.url.host];
//    TODO: ask EveryPay about merchantInfo.path ?
    [components setPath:[NSString stringWithFormat:@"%@/%@", @"/encrypted_payment_instruments", encryptedPaymentInstrument.paymentReference]];
    [components setQueryItems:@[mobile3DsHmac, apiVer]];
    return [components URL];
}

@end
