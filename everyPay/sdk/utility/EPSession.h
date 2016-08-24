//
//  EPSession.h
//  everyPay
//
//  Created by Olev Abel on 6/30/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPSession : NSObject
@property (nonatomic, strong) NSString *merchantApiBaseUrl;
@property (nonatomic, strong) NSString *everyPayApiBaseUrl;
@property (nonatomic, strong) NSString *everypayApiHost;
+ (EPSession *)sharedInstance;
@end
