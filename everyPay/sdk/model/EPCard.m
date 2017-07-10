//
//  Card.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "EPCard.h"
#import "NSString+Additions.h"
#import "NSError+Additions.h"
#import "NSDate+Additions.h"
#import "Luhn.h"

NSString *const kKeyCardNumber = @"cc_number";
NSString *const kKeyCardCVC = @"cc_verification";
NSString *const kKeyCardYear = @"cc_year";
NSString *const kKeyCardMonth = @"cc_month";
NSString *const kKeyCardName = @"cc_holder_name";

@interface EPCard ()

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *number;
@property(strong, nonatomic) NSString *cvc;
@property(strong, nonatomic) NSDate *expirationDate;

@end

@implementation EPCard

- (id)initWithName:(NSString *)name number:(NSString *)number expirationYear:(NSUInteger)expirationYear expirationMonth:(NSUInteger)expirationMonth andCVC:(NSString *)cvc {
    NSDate *expirationDate = [NSDate dateWithYear:expirationYear andMonth:expirationMonth];
    return [self initWithName:name number:number expirationDate:expirationDate andCVC:cvc];
}

- (id)initWithName:(NSString *)name number:(NSString *)number expirationDate:(NSDate *)expirationDate andCVC:(NSString *)cvc {
    self = [super init];
    if (self) {
        self.name = name;
        self.number = number;
        self.cvc = cvc;
        self.expirationDate = expirationDate;
        [self normalize];
    }

    return self;
}

/** 
 Normalize input. 
 @warning This will not ensure, that card has all correct values and is valid. It still may contain empty number, cvc, name or be expired.
 */
- (void)normalize {

    // Trim whitespace from name
    if (self.name) {
        self.name = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    // Remove all non-numeric symbols frim number and cvc.
    self.number = [self.number stringByRemovingAllNonNumerals];
    self.cvc = [self.cvc stringByRemovingAllNonNumerals];
}

- (NSError *)validateCard {
    if ([self.name length] == 0) {
        return [NSError errorWithDescription:@"Please enter the name on the card." andCode:0];
    }

    if ([self.number length] == 0) {
        return [NSError errorWithDescription:@"Please enter the card number." andCode:0];
    }

    if ([self.expirationDate dateHasPassed]) {
        return [NSError errorWithDescription:@"The expiry date has passed." andCode:0];
    }

    OLCreditCardType cardType = [Luhn typeFromString:self.number];
    if (cardType == OLCreditCardTypeInvalid) {
        return [NSError errorWithDescription:@"The card number is not valid." andCode:0];
    }

    if ([self.cvc length] == 0) {
        return [NSError errorWithDescription:@"Please enter the security code." andCode:0];
    }

    // American Express has csv length 4, other cards 3
    if (cardType == OLCreditCardTypeAmex) {
        if ([self.cvc length] != 4) {
            return [NSError errorWithDescription:@"The security code is not valid, should be 4 digits for American Express." andCode:0];
        }
    } else if (cardType != OLCreditCardTypeInvalid) {
        if ([self.cvc length] != 3) {
            return [NSError errorWithDescription:@"The security code is not valid, should be 3 digits." andCode:0];
        }
    }

    return nil;
}

- (NSDictionary *)toDictionary {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.expirationDate];
    NSNumber *month = @([components month]);
    NSNumber *year = @([components year]);

    NSDictionary *returnDictionary = @{kKeyCardNumber: self.number, kKeyCardCVC: self.cvc, kKeyCardYear: year, kKeyCardMonth: month, kKeyCardName: self.name};
    return returnDictionary;
}

@end
