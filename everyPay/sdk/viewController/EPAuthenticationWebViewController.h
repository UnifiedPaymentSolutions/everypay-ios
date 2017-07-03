//
//  PaymentWebViewController.h
//  everyPay
//
//  Created by Olev Abel on 6/28/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EPAuthenticationWebViewControllerDelegate
- (void)authenticationSucceededWithPayentReference:(NSString *)paymentReference hmac:(NSString *)hmac;
- (void)authenticationFailedWithErrorCode:(NSInteger)errorCode;
- (void)authenticationCanceled;
@end

@interface EPAuthenticationWebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, assign) id <EPAuthenticationWebViewControllerDelegate> delegate;

@property(nonatomic, strong) NSURL *url;
@end
