//
//  EPApi.h
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "BasedApi.h"

typedef enum : NSUInteger {
    EPAPIEnvTypeDemo = 0,
    EPAPIEnvTypeStanding,
    EPAPIEnvTypeLive
} EPAPIEnvTypes;


@class EPCard;
@class EPMerchantInfo;
@class EPEncryptedPaymentInstrument;

/**
 EPApi contains methods needed for sending credit card data and merchant information to EveryPay server. Server will send back an encrypted token that can be used later for payment request to merchant server.
 
 Example usage:
 
 @code
 [EPApi sendCard:card withMerchantInfo:merchantInfo withSuccess:^(NSString *token) {
    [self payWithToken:token andMerchantInfo:merchantInfo];
 } andError:^(NSArray *errors) {
    [self showErros:(errors)];
 }];
 @endcode
 
 Success block will be called with token string, error block will contain array of errors. Array is needed, because there can be multiple errors related to card. For concistency HTTP errors will be wrapped to array as well.
 */

@interface EPApi : BasedApi

- (instancetype)initWithEnv:(EPAPIEnvTypes)envType;

- (void)sendCard:(EPCard *)card merchantInfo:(EPMerchantInfo *)merchantInfo success:(void (^)(EPEncryptedPaymentInstrument *response))successCallback failure:(failureHandler)failureCallback;

- (void)encryptedPaymentInstrumentsConfirmedWith:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo success:(void (^)(EPEncryptedPaymentInstrument *response))successCallback failure:(failureHandler)failureCallback;

/** 
 Send card and merchant data to EveryPay server. 
 Merchant info is a dictionary composed of keys defined as string constants:
 
 @code
 extern NSString *const kKeyAccountId;
 extern NSString *const kKeyApiUsername;
 extern NSString *const kKeyHmac;
 extern NSString *const kKeyNonce;
 extern NSString *const kKeyTimestamp;
 extern NSString *const kKeyUserIp;
 @endcode

 Completion blocks are called in main thread.
 Success block will be called with token string, error block will contain array of errors. Array is needed, because there can be multiple errors related to card. For concistency HTTP errors will be wrapped to array as well.

 @param card A EPCard object. Card is checked by server, but it is a good idea to use validateCard method on |card| for basic checking.
 @param merchantInfo is dictionary containing merchand EveryPay username, account and security info.
 
 */

- (NSURL *)getURLFor3dsResponseWith:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo;

- (NSURL *)getURLEncryptedPaymentInstrumentsConfirmedWith:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo;

@end
