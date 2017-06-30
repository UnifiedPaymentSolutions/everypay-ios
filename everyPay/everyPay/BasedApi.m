//
// Created by Ivan Gaydamakin on 30/06/2017.
// Copyright (c) 2017 MobiLab. All rights reserved.
//

#import "BasedApi.h"


@interface BasedApi ()
@property(nonatomic, strong) NSString *apiVersion;
@end

@implementation BasedApi {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.apiVersion = @"2";
    }

    return self;
}

@end