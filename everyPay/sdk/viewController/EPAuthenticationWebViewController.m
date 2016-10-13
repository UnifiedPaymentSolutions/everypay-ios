//
//  PaymentWebViewController.m
//  everyPay
//
//  Created by Olev Abel on 6/28/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import "EpAuthenticationWebViewController.h"
#import "Constants.h"
#import "EPSession.h"

@interface EPAuthenticationWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString *paymentReference;
@property (nonatomic) BOOL isBrowserFlowEndUrlReached;
@property (nonatomic, copy) NSString *secureCodeOne;
@property (nonatomic, copy) NSString *hmac;

@end

@implementation EPAuthenticationWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"3Ds authentication"];
    NSURL *url = [self buildInitURLForWebViewWithPaymentReference:_paymentReference secureCodeOne:_secureCodeOne hmac:_hmac];
    NSLog(@"webView URL %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setDelegate:self];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL *)buildInitURLForWebViewWithPaymentReference:(NSString *)paymentReference secureCodeOne:(NSString *)secureCodeOne hmac:(NSString *)hmac {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:[EPSession sharedInstance].everypayApiHost];
    [components setPath:@"/authentication3ds/new"];
    NSURLQueryItem *paymentRef = [NSURLQueryItem queryItemWithName:kKeyPaymentReference value:paymentReference];
    NSURLQueryItem *secureCode = [NSURLQueryItem queryItemWithName:kKeySecureCodeOne value:secureCodeOne];
    NSURLQueryItem *mobile3DsHmac = [NSURLQueryItem queryItemWithName:kParamHmac value:hmac];
    [components setQueryItems:@[paymentRef, secureCode, mobile3DsHmac]];
    return [components URL];
}
- (void)addURLParametersWithPaymentReference:(NSString *)paymentReference secureCodeOne:(NSString *)secureCodeOne hmac:(NSString *)hmac {
    [self setPaymentReference:paymentReference];
    [self setSecureCodeOne:secureCodeOne];
    [self setHmac:hmac];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    
    NSLog(@"url: %@, scheme: %@, relativePath: %@, relativeString: %@", request.URL.absoluteString, request.URL.scheme, request.URL.relativePath, request.URL.relativeString);
    if([self isBrowserFlowEndUrlWithUrlString:urlString]){
        [self setIsBrowserFlowEndUrlReached:YES];
        if ([self isBrowerFlowSuccessfulWithUrlString:urlString]) {
            NSString *urlWithoutPrefix = [[NSString alloc]init];
            if([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiStagingHost]){
                urlWithoutPrefix = [urlString stringByReplacingOccurrencesOfString:kBrowserFlowEndURLPrefixStaging withString:@""];
            } else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiDemoHost]) {
                urlWithoutPrefix = [urlString stringByReplacingOccurrencesOfString:kBrowserFlowEndURLPrefixDemo withString:@""];
            }  else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiLiveHost]) {
                urlWithoutPrefix = [urlString stringByReplacingOccurrencesOfString:kBrowserFlowEndURLPrefixLive withString:@""];
            }
            NSString *paymentReference = [urlWithoutPrefix componentsSeparatedByString:@"?"][0];
            if (self.delegate) {
                [self.delegate authenticationSucceededWithPayentReference:paymentReference hmac:_hmac];
            }
        } else {
            NSInteger errorCode = 999;
            if (self.delegate) {
                [self.delegate authenticationFailedWithErrorCode:errorCode];
            }
        }
    }
    return YES;
}

- (BOOL)isBrowserFlowEndUrlWithUrlString:(NSString *)urlString {
    return [urlString containsString:kPaymentState];
}

- (BOOL)isBrowerFlowSuccessfulWithUrlString:(NSString *)urlString {
    if([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiStagingHost]){
        return [urlString hasPrefix:kBrowserFlowEndURLPrefixStaging] && [urlString containsString:kPaymentStateAuthorised];
    } else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiDemoHost]) {
        return [urlString hasPrefix:kBrowserFlowEndURLPrefixDemo] && [urlString containsString:kPaymentStateAuthorised];
    } else if ([[EPSession sharedInstance].everypayApiHost isEqualToString:kEveryPayApiLiveHost]) {
        return [urlString hasPrefix:kBrowserFlowEndURLPrefixLive] && [urlString containsString:kPaymentStateAuthorised];
    } else {
        return NO;
    }
   }

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if(![parent isEqual:self.parentViewController]) {
        NSLog(@"Back pressed");
        if(!self.isBrowserFlowEndUrlReached) {
            [self.delegate authenticationCanceled];
        }
    }
}
@end
