//
// Created by Ivan Gaydamakin on 03/07/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EPEncryptedPaymentInstrumentPaymentStateNotFound,
    EPEncryptedPaymentInstrumentPaymentStateCompleted, // ‘settled’ or ‘authorised’
    EPEncryptedPaymentInstrumentPaymentStateCancelled, // ‘cancelled’
    EPEncryptedPaymentInstrumentPaymentStateFailed, // ‘failed’
    EPEncryptedPaymentInstrumentPaymentStateWaitingFor3dsResponse, // ‘waiting_for_3ds_response’
} EPEncryptedPaymentInstrumentPaymentStates;

extern NSString *const kKeyEncryptedToken;
extern NSString *const kKeyPaymentReference;
extern NSString *const kKeySecureCodeOne;

@interface EPEncryptedPaymentInstrument : NSObject
@property(nonatomic, copy) NSString *secureCodeOne;
@property(nonatomic, copy) NSString *paymentReference;
@property(nonatomic, copy) NSString *ccTokenEncrypted;
@property(nonatomic) EPEncryptedPaymentInstrumentPaymentStates paymentState;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end