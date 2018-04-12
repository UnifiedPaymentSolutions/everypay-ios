//
//  Constants.h
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Define constants for global use
 */
#ifdef __OBJC__
#   ifndef EPLog
#       ifdef DEBUG
#           define EPLog(format, ...) NSLog(format, ##__VA_ARGS__)
#       else
#           define EPLog(format, ...) (void)0
#       endif
#   endif
#endif
//
//// base urls
//extern NSString *const kEveryPayApiStaging;
//extern NSString *const kEveryPayApiLive;
//extern NSString *const kMerchantApiStaging;
//extern NSString *const kEveryPayApiDemo;
//extern NSString *const kMerchantApiDemo;
//extern NSString *const kEveryPayApiStagingHost;
//extern NSString *const kEveryPayApiDemoHost;
//extern NSString *const kEveryPayApiLiveHost;
//
//// browserflow urls
//extern NSString *const kBrowserFlowEndURLPrefixStating;
//extern NSString *const kBrowserFlowEndURLPrefixDemo;
//extern NSString *const kBrowserFlowEndURLPrefixLive;
//extern NSString *const kBrowserFlowInitURL;
//// Json keys
//extern NSString *const kKeyAccountId;
//extern NSString *const kKeyApiUsername;
//extern NSString *const kKeyHmac;
//extern NSString *const kKeyNonce;
//extern NSString *const kKeyTimestamp;
//extern NSString *const kKeyUserIp;
//extern NSString *const kKeyCardNumber;
//extern NSString *const kKeyCardCVC;
//extern NSString *const kKeyCardYear;
//extern NSString *const kKeyCardMonth;
//extern NSString *const kKeyCardName;
//extern NSString *const kKeySingleUseToken;
//extern NSString *const kKeyEncryptedToken;
//extern NSString *const kPaymentState;
//extern NSString *const kPaymentStateAuthorised;
//extern NSString *const kPaymentStateWaiting3dsResponse;
//extern NSString *const kKeyPaymentReference;
//extern NSString *const kKeySecureCodeOne;
//
//extern NSString *const kKeyErrors;
//extern NSString *const kKeyError;
//extern NSString *const kKeyMessage;
//extern NSString *const kKeyCode;
//extern NSString *const kAuthorised;
//extern NSString *const kFailed;
