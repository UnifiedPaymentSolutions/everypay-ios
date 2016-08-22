//
//  Constants.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "Constants.h"

NSString *const kEveryPayApiStaging = @"https://gw-staging.every-pay.com";
NSString *const kEveryPayApiLive = @"https://gw.every-pay.com";
NSString *const kMercantApiStaging = @"https://igwshop-staging.every-pay.com";
NSString *const kEveryPayApiDemo = @"https://gw-demo.every-pay.com";
NSString *const kMerchantApiDemo = @"https://igwshop-demo.every-pay.com";
NSString *const kEveryPayApiStagingHost = @"gw-staging.every-pay.com";
NSString *const kEveryPayApiDemoHost = @"gw-demo.every-pay.com";
NSString *const kEveryPayApiLiveHost = @"gw.every-pay.com";


NSString *const kBrowserFlowEndURLPrefixStating = @"https://gw-staging.every-pay.com/authentication3ds";
NSString *const kBrowserFlowEndURLPrefixDemo = @"https://gw-demo.every-pay.com/authentication3ds";
NSString *const kBrowserFlowEndURLPrefixLive = @"https://gw.every-pay.com/authentication3ds";
NSString *const kBrowserFlowInitURL = @"https://gw-staging.every-pay.com/authentication3ds/new";
NSString *const kPaymentState = @"payment_state";
NSString *const kAuthorised = @"authorised";
NSString *const kPaymentStateAuthorised = @"payment_state=authorised";
NSString *const kPaymentStateWaiting3DsResponse = @"waiting_for_3ds_response";

NSString *const kKeyAccountId = @"account_id";
NSString *const kKeyApiUsername = @"api_username";
NSString *const kKeyHmac = @"hmac";
NSString *const kKeyNonce = @"nonce";
NSString *const kKeyTimestamp = @"timestamp";
NSString *const kKeyUserIp = @"user_ip";
NSString *const kKeyCardNumber = @"cc_number";
NSString *const kKeyCardCVC = @"cc_verification";
NSString *const kKeyCardYear = @"cc_year";
NSString *const kKeyCardMonth = @"cc_month";
NSString *const kKeyCardName = @"cc_holder_name";
NSString *const kKeySingleUseToken = @"single_use_token";
NSString *const kKeyErrors = @"errors";
NSString *const kKeyError = @"error";
NSString *const kKeyMessage = @"message";
NSString *const kKeyCode = @"code";
NSString *const kKeyEncryptedToken = @"cc_token_encrypted";
NSString *const kKeyPaymentReference = @"payment_reference";
NSString *const kKeySecureCodeOne = @"secure_code_one";
NSString *const kParamHmac = @"mobile_3ds_hmac";
NSString *const kKeyApiVersion = @"api_version";

NSString *const kKeyEncryptedPaymentInstrument = @"encrypted_payment_instrument";