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

NSString *const kSendCardDetailsPath = @"encrypted_payment_instruments";

@interface EPApi ()

@property (nonatomic) NSURLSession *urlSession;

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
    
    
    NSURLSessionUploadTask *uploadTask = [self.urlSession uploadTaskWithRequest:request fromData:requestData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failure(@[error]);
        } else {
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(@[error]);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *errors = [ErrorExtractor errorsFromDictionary:responseDictionary];
                    if ([errors count] > 0) {
                        failure(errors);
                    } else {
                        NSDictionary *instruments = [responseDictionary objectForKey:kKeyEncryptedPaymentInstrument];
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
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (error) {
            failure(@[error]);
        } else {
            NSError *jsonParsingError;
            NSDictionary *responseDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(@[error]);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *errors = [ErrorExtractor errorsFromDictionary:responseDictionary];
                    if ([errors count] > 0) {
                        NSLog(@"Error processing payment: %@", errors);
                        failure(errors);
                    } else {
                        NSDictionary *instruments = [responseDictionary objectForKey:kKeyEncryptedPaymentInstrument];
                        success(instruments);
                    }
                });
            }
        }
    }];
    
    [dataTask resume];
}

@end
