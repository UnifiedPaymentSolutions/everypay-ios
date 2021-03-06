//
//  NSError+Additions.h
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (Additions)

/** 
 Compose a NSError object from description and code.
 Description will be localized and set as NSLocalizedDescription of error object.
 */
+ (NSError *)errorWithDescription:(NSString *)descrpition andCode:(NSInteger)errorCode;

@end
