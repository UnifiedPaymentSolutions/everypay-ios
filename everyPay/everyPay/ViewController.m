//
//  ViewController.m
//  everyPay
//
//  Created by Lauri Eskor on 24/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "ViewController.h"
#import "EPApi.h"

#import "EPMerchantApi.h"
#import "EPEncryptedPaymentInstrument.h"
#import "EPMerchantInfo.h"

NSString *const kMerchantApiDemo = @"https://igwshop-demo.every-pay.com";
NSString *const kMerchantApiStaging = @"https://igwshop-staging.every-pay.com";


@interface ViewController ()
@property(weak, nonatomic) IBOutlet UITextView *textView;

@property(nonatomic, strong) EPApi *epApi;
@property(nonatomic, strong) EPMerchantApi *merchantApi;

@property(nonatomic, strong) EPMerchantInfo *merchantInfo;
@property(nonatomic, strong) EPEncryptedPaymentInstrument *encryptedPaymentInstrument;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)showChooseApiBaseUrlActionSheetWithCard:(EPCard *)card {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose environment" message:@"Choose environment for requests" preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Demo environment" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            self.merchantApi = [[EPMerchantApi alloc] initWithURL:[[NSURL alloc] initWithString:kMerchantApiDemo]];
            self.epApi = [[EPApi alloc] initWithEnv:EPAPIEnvTypeDemo];
            [self showChooseAccountActionSheetWithCard:card];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Staging environment" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            self.merchantApi = [[EPMerchantApi alloc] initWithURL:[[NSURL alloc] initWithString:kMerchantApiStaging]];
            self.epApi = [[EPApi alloc] initWithEnv:EPAPIEnvTypeStanding];
            [self showChooseAccountActionSheetWithCard:card];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    });
}

- (void)showChooseAccountActionSheetWithCard:(EPCard *)card {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Choose account" message:@"Choose accountID for 3Ds or non-3Ds flow" preferredStyle:UIAlertControllerStyleActionSheet];
        NSArray *accountIdChoices = @[@"EUR3D1", @"EUR1", @"null"];
        if ([accountIdChoices count] == 0) {
            [self showResultAlertWithTitle:@"No accounts" message:@"You haven't provided any accounts"];
            return;
        }
        for (NSString *accountID in accountIdChoices) {
            [actionSheet addAction:[UIAlertAction actionWithTitle:accountID style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                NSString *id = accountID;
                if ([id isEqual:@"null"])
                    id = nil;
                [self getMerchantInfoWithCard:card accountId:id];
            }]];
        }
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    });
}

- (void)getMerchantInfoWithCard:(EPCard *)card accountId:(NSString *)accountId {
    [self appendProgressLog:@"Get API credentials from merchant..."];
    [self.merchantApi getMerchantDataByAccountId:accountId success:^(EPMerchantInfo *merchantInfo) {
        [self appendProgressLog:@"Done"];
        self.merchantInfo = merchantInfo;
        [self sendCardCredentialsToEPWithMerchantInfo:merchantInfo card:card];
    }                                    failure:^(NSArray<NSError *> *errors) {
        [self showAlertWithError:errors.firstObject];
    }];
}

- (void)sendCardCredentialsToEPWithMerchantInfo:(EPMerchantInfo *)merchantInfo card:(EPCard *)card {
    [self appendProgressLog:@"Save card details with EvertPay API..."];
    [self.epApi sendCard:card merchantInfo:merchantInfo success:^(EPEncryptedPaymentInstrument *response) {
        self.encryptedPaymentInstrument = response;
        if (response.paymentState == EPEncryptedPaymentInstrumentPaymentStateWaitingFor3dsResponse) {
            [self appendProgressLog:@"Done"];
            [self appendProgressLog:@"Starting 3DS authentication..."];
            [self startWebViewWithEncryptedPaymentInstrument:response merchantInfo:merchantInfo];
        } else if (response.paymentState == EPEncryptedPaymentInstrumentPaymentStateCompleted) {
            [self appendProgressLog:@"Done"];
            [self payWithToken:response.ccTokenEncrypted andMerchantInfo:merchantInfo];
        } else {
            [self showAlertWithError:[NSError errorWithDomain:@"Unknown account id or payment state" code:1001 userInfo:nil]];
        }
    }            failure:^(NSArray<NSError *> *errors) {
        [self showAlertWithError:[errors firstObject]];
    }];
}

- (void)payWithToken:(NSString *)token andMerchantInfo:(EPMerchantInfo *)merchantInfo {
    [self appendProgressLog:@"Send card token to merchant server..."];
    [self.merchantApi sendCardToken:token hmac:merchantInfo.hmac success:^{
        [self appendProgressLog:@"All done"];
    }                       failure:^(NSArray<NSError *> *errors) {
        [self showAlertWithError:errors.firstObject];
    }];
}

- (void)startWebViewWithEncryptedPaymentInstrument:(EPEncryptedPaymentInstrument *)encryptedPaymentInstrument merchantInfo:(EPMerchantInfo *)merchantInfo {
    NSURL *url = [self.epApi getURLFor3dsResponseWith:encryptedPaymentInstrument merchantInfo:merchantInfo];
    EPAuthenticationWebViewController *authenticationWebView = [[EPAuthenticationWebViewController alloc] initWithNibName:NSStringFromClass([EPAuthenticationWebViewController class]) bundle:nil];
    [authenticationWebView setDelegate:self];
    [authenticationWebView setUrl:url];
    [self.navigationController pushViewController:authenticationWebView animated:YES];
}

- (void)showResultAlertWithTitle:(NSString *)title message:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)showAlertWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    [self appendProgressLog:@"Failed"];
}

- (void)appendProgressLog:(NSString *)log {
    EPLog(@"> %@", log);
    NSString *stringToAppend = [NSString stringWithFormat:@"\n%@", log];
    [self.textView setText:[self.textView.text stringByAppendingString:stringToAppend]];
}

- (IBAction)restartTapped:(id)sender {
    [self.textView setText:@""];
    EPCardInfoViewController *cardInfoViewController = [[EPCardInfoViewController alloc] initWithNibName:NSStringFromClass([EPCardInfoViewController class]) bundle:nil];
    [cardInfoViewController setDelegate:self];
    [self.navigationController pushViewController:cardInfoViewController animated:YES];
    cardInfoViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [self appendProgressLog:@"\n"];
}

- (void)closeWebViewController {
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - EPAuthenticationWebViewControllerDelegate

- (void)authenticationCanceled {
    [self showAlertWithError:[NSError errorWithDomain:@"3Ds authentication canceled" code:1000 userInfo:nil]];
}

- (void)authenticationFailedWithErrorCode:(NSInteger)errorCode {
    [self.navigationController popToViewController:self animated:YES];
    EPLog(@"payment Failed with code %ld", (long) errorCode);
    [self showAlertWithError:[NSError errorWithDomain:@"3Ds authentication failed" code:errorCode userInfo:nil]];
}

- (void)authenticationSucceededWithPayentReference:(NSString *)paymentReference hmac:(NSString *)hmac {
    [self.navigationController popToViewController:self animated:YES];
    EPLog(@"payment succeeded with reference %@", paymentReference);
    [self appendProgressLog:@"Done"];
    [self appendProgressLog:@"Confirming 3DS with Everypay server ...."];
    [self.epApi encryptedPaymentInstrumentsConfirmedWith:self.encryptedPaymentInstrument merchantInfo:self.merchantInfo success:^(EPEncryptedPaymentInstrument *response) {
        self.encryptedPaymentInstrument = response;
        [self appendProgressLog:@"Done"];
        [self payWithToken:response.ccTokenEncrypted andMerchantInfo:self.merchantInfo];
    }                                            failure:^(NSArray<NSError *> *errors) {
        [self showAlertWithError:errors.firstObject];
    }];
}

#pragma mark - CardInfoViewControllerDelegate

- (void)cardInfoViewController:(UIViewController *)controller didEnterInfoForCard:(EPCard *)card {
    [self.navigationController popToViewController:self animated:YES];
    [self showChooseApiBaseUrlActionSheetWithCard:card];

}
@end
