//
//  PaymentWebViewController.m
//  everyPay
//
//  Created by Olev Abel on 6/28/16.
//  Copyright © 2016 MobiLab. All rights reserved.
//

#import "EPAuthenticationWebViewController.h"
#import "Constants.h"

NSString *const kPaymentStateWeb = @"payment_state";
NSString *const kPaymentStateWebAuthorised = @"payment_state=authorised";

@interface EPAuthenticationWebViewController ()
@property(weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic) BOOL isBrowserFlowEndUrlReached;

@end

@implementation EPAuthenticationWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"3Ds authentication"];
    [self loadRequestBy3dsUrl];
    [self.webView setDelegate:self];
}

- (void)loadRequestBy3dsUrl {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url3ds];
    [self.webView loadRequest:request];
}

+ (EPAuthenticationWebViewController *)allocWithDelegate:(id <EPAuthenticationWebViewControllerDelegate>)delegate withURL3ds:(NSURL *)url withHmac:(NSString *)hmac {
    Class selfClass = [self class];
    NSBundle *bundle = [NSBundle bundleForClass:selfClass];
    EPAuthenticationWebViewController *authenticationWebView = [[EPAuthenticationWebViewController alloc] initWithNibName:NSStringFromClass(selfClass) bundle:bundle];
    authenticationWebView.delegate = delegate;
    authenticationWebView.url3ds = url;
    authenticationWebView.hmac = hmac;
    return authenticationWebView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;

    EPLog(@"url3ds: %@, scheme: %@, relativePath: %@, relativeString: %@", request.URL.absoluteString, request.URL.scheme, request.URL.relativePath, request.URL.relativeString);
    if ([self isBrowserFlowEndUrlWithUrlString:urlString]) {
        [self setIsBrowserFlowEndUrlReached:YES];
        if ([self isBrowserFlowSuccessfulWithUrlString:urlString]) {
//https://gw-demo.every-pay.com/authentication3ds/3fc2c36ccd08c440c3ac350818e4503127dad6072a17b2b8710345ba9e57f0e2?payment_state=authorised
            urlString = [urlString componentsSeparatedByString:@"/"].lastObject;
            NSString *paymentReference = [urlString componentsSeparatedByString:@"?"].firstObject;
            if (self.delegate) {
                [self.delegate authenticationSucceededWithPaymentReference:paymentReference hmac:self.hmac];
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
    return [urlString containsString:kPaymentStateWeb];
}

- (BOOL)isBrowserFlowSuccessfulWithUrlString:(NSString *)urlString {
    return [urlString containsString:kPaymentStateWebAuthorised];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        EPLog(@"Back pressed");
        if (!self.isBrowserFlowEndUrlReached) {
            [self.delegate authenticationCanceled];
        }
    }
}

@end
