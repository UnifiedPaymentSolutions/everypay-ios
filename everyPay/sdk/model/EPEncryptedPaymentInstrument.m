//
// Created by Ivan Gaydamakin on 03/07/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import "EPEncryptedPaymentInstrument.h"

NSString *const kKeyEncryptedToken = @"cc_token_encrypted";
NSString *const kKeyPaymentReference = @"payment_reference";
NSString *const kKeySecureCodeOne = @"secure_code_one";

NSString *const kPaymentState = @"payment_state";

NSString *const kPaymentStateAuthorised = @"authorised";
NSString *const kPaymentStateSettled = @"settled";
NSString *const kPaymentStateFailed = @"failed";
NSString *const kPaymentStateCancelled = @"cancelled";
NSString *const kPaymentStateWaiting3dsResponse = @"waiting_for_3ds_response";

@implementation EPEncryptedPaymentInstrument {

}
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.ccTokenEncrypted = dictionary[kKeyEncryptedToken];
        self.secureCodeOne = dictionary[kKeySecureCodeOne];
        self.paymentReference = dictionary[kKeyPaymentReference];
        self.paymentState = [self getStateByString:dictionary[kPaymentState]];
    }
    return self;
}

- (EPEncryptedPaymentInstrumentPaymentStates)getStateByString:(NSString *)stringState {
    if ([stringState isEqual:kPaymentStateAuthorised] || [stringState isEqual:kPaymentStateSettled])
        return EPEncryptedPaymentInstrumentPaymentStateCompleted;

    if ([stringState isEqual:kPaymentStateCancelled])
        return EPEncryptedPaymentInstrumentPaymentStateCancelled;

    if ([stringState isEqual:kPaymentStateFailed])
        return EPEncryptedPaymentInstrumentPaymentStateFailed;

    if ([stringState isEqual:kPaymentStateWaiting3dsResponse])
        return EPEncryptedPaymentInstrumentPaymentStateWaitingFor3dsResponse;

    return EPEncryptedPaymentInstrumentPaymentStateNotFound;
}
@end