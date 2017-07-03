//
//  PaymentWebViewController.m
//  everyPay
//
//  Created by Olev Abel on 6/28/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import "EPAuthenticationWebViewController.h"
#import "Constants.h"

@interface EPAuthenticationWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL isBrowserFlowEndUrlReached;

@end

@implementation EPAuthenticationWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"3Ds authentication"];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView setDelegate:self];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    
    EPLog(@"url: %@, scheme: %@, relativePath: %@, relativeString: %@", request.URL.absoluteString, request.URL.scheme, request.URL.relativePath, request.URL.relativeString);
//    if([self isBrowserFlowEndUrlWithUrlString:urlString]){
//        [self setIsBrowserFlowEndUrlReached:YES];
//        if ([self isBrowserFlowSuccessfulWithUrlString:urlString]) {
//            NSString *urlWithoutPrefix = [[NSString alloc]init];
//            if([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiStagingHost]){
//                urlWithoutPrefix = [urlString stringByReplacingOccurrencesOfString:kBrowserFlowEndURLPrefixStating withString:@""];
//            } else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiDemoHost]) {
//                urlWithoutPrefix = [urlString stringByReplacingOccurrencesOfString:kBrowserFlowEndURLPrefixDemo withString:@""];
//            }  else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiLiveHost]) {
//                urlWithoutPrefix = [urlString stringByReplacingOccurrencesOfString:kBrowserFlowEndURLPrefixLive withString:@""];
//            }
//            NSString *paymentReference = [urlWithoutPrefix componentsSeparatedByString:@"?"][0];
//            if (self.delegate) {
//                [self.delegate authenticationSucceededWithPayentReference:paymentReference hmac:_hmac];
//            }
//        } else {
//            NSInteger errorCode = 999;
//            if (self.delegate) {
//                [self.delegate authenticationFailedWithErrorCode:errorCode];
//            }
//        }
//    }
    return YES;
}
//
//- (BOOL)isBrowserFlowEndUrlWithUrlString:(NSString *)urlString {
//    return [urlString containsString:kPaymentState];
//}
//
//- (BOOL)isBrowserFlowSuccessfulWithUrlString:(NSString *)urlString {
//    if([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiStagingHost]){
//        return [urlString hasPrefix:kBrowserFlowEndURLPrefixStating] && [urlString containsString:kPaymentStateAuthorised];
//    } else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiDemoHost]) {
//        return [urlString hasPrefix:kBrowserFlowEndURLPrefixDemo] && [urlString containsString:kPaymentStateAuthorised];
//    } else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiLiveHost]) {
//        return [urlString hasPrefix:kBrowserFlowEndURLPrefixLive] && [urlString containsString:kPaymentStateAuthorised];
//    } else {
//        return NO;
//    }
//   }
//
//- (void)didMoveToParentViewController:(UIViewController *)parent {
//    if(![parent isEqual:self.parentViewController]) {
//        EPLog(@"Back pressed");
//        if(!self.isBrowserFlowEndUrlReached) {
//            [self.delegate authenticationCanceled];
//        }
//    }
//}
@end
