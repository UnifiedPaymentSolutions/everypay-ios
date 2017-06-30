//
//  EPApi.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "EPApi.h"
#import "Constants.h"
#import "DeviceInfo.h"
#import "ErrorExtractor.h"
#import "EPSession.h"
#import "EPCard.h"
#import "EPMerchantInfo.h"

NSString *const kSendCardDetailsPath = @"encrypted_payment_instruments";

@interface EPApi ()

@property(nonatomic) NSURLSession *urlSession;

@end


@implementation EPApi

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        conf.TLSMinimumSupportedProtocol = kTLSProtocol11;
        [self setUrlSession:[NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil]];
    }
    return self;
}


- (void)sendCard:(EPCard *)card withMerchantInfo:(NSDictionary *)merchantInfo withSuccess:(DictionarySuccessBlock)success andError:(ArrayBlock)failure {
    NSURL *baseApiUrl = [NSURL URLWithString:[EPSession sharedInstance].everyPayApiBaseUrl];
    NSURL *url = [NSURL URLWithString:kSendCardDetailsPath relativeToURL:baseApiUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSMutableDictionary *merchantDictionary = [NSMutableDictionary dictionaryWithDictionary:merchantInfo];
    [merchantDictionary removeObjectForKey:@"http_path"];
    [merchantDictionary removeObjectForKey:@"http_method"];
    [merchantDictionary addEntriesFromDictionary:[card cardInfoDictionary]];


    NSDictionary *requestDictionary = @{kKeyEncryptedPaymentInstrument: merchantDictionary};
    NSError *jsonConversionError;

    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:kNilOptions error:&jsonConversionError];

    EPLog(@"Start request %@\n", request);
    EPLog(@"Encrypted payment instruments request body %@\n", requestDictionary);

    NSURLSessionUploadTask *uploadTask = [self.urlSession uploadTaskWithRequest:request fromData:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        EPLog(@"Request completed with response\n %@", response);
        if (error) {
            failure(@[error]);
        } else {
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (jsonParsingError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(@[error]);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *errors = [ErrorExtractor errorsFromDictionary:responseDictionary];
                    if ([errors count] > 0) {
                        EPLog(@"Error processing payment: %@", errors);
                        failure(errors);
                    } else {
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

                         */
                        EPLog(@"Encrypted payment instruments response %@", responseDictionary);
                        NSDictionary *instruments = responseDictionary[kKeyEncryptedPaymentInstrument];
                        success(instruments);
                    }
                });
            }
        }
    }];

    [uploadTask resume];
}

- (void)encryptedPaymentInstrumentsConfirmedWithPaymentReference:(NSString *)paymentReference hmac:(NSString *)hmac apiVersion:(NSString *)apiVersion withSuccess:(DictionarySuccessBlock)success andError:(ArrayBlock)failure {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:[EPSession sharedInstance].everypayApiHost];
    [components setPath:[NSString stringWithFormat:@"/encrypted_payment_instruments/%@", paymentReference]];
    NSURLQueryItem *mobile3DsHmac = [NSURLQueryItem queryItemWithName:kParamHmac value:hmac];
    NSURLQueryItem *apiVer = [NSURLQueryItem queryItemWithName:kKeyApiVersion value:apiVersion];
    [components setQueryItems:@[mobile3DsHmac, apiVer]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        EPLog(@"Request completed with response\n %@", response);
        if (error) {
            failure(@[error]);
        } else {
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (jsonParsingError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(@[error]);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *errors = [ErrorExtractor errorsFromDictionary:responseDictionary];
                    if ([errors count] > 0) {
                        EPLog(@"Error processing payment: %@", errors);
                        failure(errors);
                    } else {
                        EPLog(@"Encrypted payment instruments  confirmed response %@", responseDictionary);
                        NSDictionary *instruments = responseDictionary[kKeyEncryptedPaymentInstrument];
                        success(instruments);
                    }
                });
            }
        }
    }];

    [dataTask resume];
}

- (void)encryptedPaymentInstrumentsConfirmedWithPaymentReference:(NSString *)paymentReference hmac:(NSString *)hmac withSuccess:(DictionarySuccessBlock)success andError:(ArrayBlock)failure {
    [self encryptedPaymentInstrumentsConfirmedWithPaymentReference:paymentReference hmac:hmac apiVersion:self.apiVersion withSuccess:success andError:failure];
}


@end
