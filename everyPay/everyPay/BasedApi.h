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


typedef void (^completionHandler)(NSURLResponse *rawResponse, NSDictionary *jsonResponse, NSError *error);

@interface BasedApi : NSObject
- (void)execute:(NSMutableURLRequest *)request parameters:(NSDictionary *)parameters completionHandler:(completionHandler)handler;

@property(nonatomic, readonly) NSString *apiVersion;

@end
