//
//  ViewController.h
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCardInfoViewController.h"
#import "EPAuthenticationWebViewController.h"

@class EPMerchantApi;
@class EPEncryptedPaymentInstrument;

@interface ViewController : UIViewController <EPCardInfoViewControllerDelegate, EPAuthenticationWebViewControllerDelegate>
@property (nonatomic, copy) NSString *merchantApiBaseUrl;
@property (nonatomic, copy) NSString *everypayApiBaseUrl;
@end
