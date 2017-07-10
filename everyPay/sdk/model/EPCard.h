//
//  Card.h
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyCardNumber;
extern NSString *const kKeyCardCVC;
extern NSString *const kKeyCardYear;
extern NSString *const kKeyCardMonth;
extern NSString *const kKeyCardName;

@interface EPCard : NSObject

/**
 @discussion Create new card with given number, expirationdate and control code. All input is normalized.
 All parameters are required.
 
 @param name name on Card. Spaces from beginning and end of name are removed.
 @param number Card number. All non-numeric symbols are removed.
 @param date Card expiration date
 @param cvc Card verification code. All non-numeric symbols are removed.
 
 @return new Card object.
 
 */
- (id)initWithName:(NSString *)name number:(NSString *)number expirationYear:(NSUInteger)expirationYear expirationMonth:(NSUInteger)expirationMonth andCVC:(NSString *)cvc;

- (id)initWithName:(NSString *)name number:(NSString *)number expirationDate:(NSDate *)expirationDate andCVC:(NSString *)cvc;

/**
 Check if card is valid.
 
 - |name| can not be empty;
 
 - |number| can not be empty;
 
 - |cvc| can not be empty;
 
 - |cvc| has to be correct length (depending on card type)
 
 - |number| has to pass Luhn checksum verifycation
 
 - |number| must belong to a credid card
 
 - |expirationDate| can not be in the past
 
@return nil if card is valid, a NSError if there was a problem. Check localizedDescription to find ut exact cause. In case of multiple errors, only one is returned.
 */

- (NSError *)validateCard;

/** 
 Return card info in dictionary form suitable for API input
 */
- (NSDictionary *)toDictionary;

@end
