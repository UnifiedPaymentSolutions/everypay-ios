//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


typedef void (^completionHandler)(NSURLResponse *rawResponse, NSDictionary *jsonResponse, NSArray <NSError *> *errors);

typedef void (^failureHandler)(NSArray<NSError *> *errors);
extern NSString *const kApiVersion;

@interface BasedApi : NSObject
@property(nonatomic, readonly) NSString *apiVersion;
@property(nonatomic, strong) NSURL *url;

- (NSMutableURLRequest *)getPostRequestWithURL:(NSURL *)url;

- (void)execute:(NSMutableURLRequest *)request parameters:(NSDictionary *)parameters completionHandler:(completionHandler)handler;

+ (NSArray *)errorsFromDictionary:(NSDictionary *)dictionary;


@end
