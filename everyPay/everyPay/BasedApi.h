//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

typedef void (^DictionarySuccessBlock)(NSDictionary *dictionary);

typedef void (^StringSuccessBlock)(NSString *string);

typedef void (^FailureBlock)(NSError *error);

typedef void (^ArrayBlock)(NSArray *array);


@interface BasedApi : NSObject
@property(nonatomic, readonly) NSString *apiVersion;
@end