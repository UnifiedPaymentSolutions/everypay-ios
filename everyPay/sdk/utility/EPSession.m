//
//  EPSession.m
//  everyPay
//
//  Created by Olev Abel on 6/30/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import "EPSession.h"

@implementation EPSession

+ (EPSession *)sharedInstance {
    static dispatch_once_t pred;
    static EPSession *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end

