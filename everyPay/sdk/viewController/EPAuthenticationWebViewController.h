//
//  PaymentWebViewController.h
//  everyPay
//
//  Created by Olev Abel on 6/28/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPAuthenticationWebViewControllerDelegate
- (void)authenticationSucceededWithPaymentReference:(NSString *)paymentReference hmac:(NSString *)hmac;

- (void)authenticationFailedWithErrorCode:(NSInteger)errorCode;

- (void)authenticationCanceled;
@end

@interface EPAuthenticationWebViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, weak) id <EPAuthenticationWebViewControllerDelegate> delegate;
@property(nonatomic, copy) NSURL *url3ds;
@property(nonatomic, copy) NSString *hmac;

+ (EPAuthenticationWebViewController *)allocWithDelegate:(id)delegate withURL3ds:(NSURL *)url withHmac:(NSString *)hmac;

- (void)loadRequestBy3dsUrl;

@end
