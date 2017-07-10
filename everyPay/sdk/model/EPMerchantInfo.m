//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import "EPMerchantInfo.h"

NSString *const kKeyHmac = @"hmac";
NSString *const kKeyAccountId = @"account_id";
NSString *const kHttpPath = @"http_path";

@interface EPMerchantInfo ()
@property(nonatomic, strong) NSDictionary *dictionary;
@end

@implementation EPMerchantInfo {

}
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
    }
    return self;
}

- (NSString *)accountID {
    return self.dictionary[kKeyAccountId];
}

- (NSString *)hmac {
    return self.dictionary[kKeyHmac];
}

- (NSString *)path {
    return self.dictionary[kHttpPath];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [self.dictionary mutableCopy];
    NSArray *keys = @[
            kHttpPath,
            @"http_method",
            @"api_version",
    ];
    for (NSString *key in keys) {
        [dictionary removeObjectForKey:key];
    }
    return dictionary;
}


@end