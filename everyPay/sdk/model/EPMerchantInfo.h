//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kKeyHmac;
extern NSString *const kKeyAccountId;

@interface EPMerchantInfo : NSObject
@property(nonatomic, readonly) NSString *accountID;
@property(nonatomic, readonly) NSString *hmac;
@property(nonatomic, readonly) NSString *path;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;

@end