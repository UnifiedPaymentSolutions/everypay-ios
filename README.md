# EveryPay iOS SDK

> Warning: the iOS SDK is still in an alpha stage. Significant API changes may happen before a 1.0 release.

* [Overview](https://github.com/UnifiedPaymentSolutions/everypay-ios#overview)
* [Integrating the SDK](https://github.com/UnifiedPaymentSolutions/everypay-ios#integrating-the-sdk)
  * [Configure the SDK parameters](https://github.com/UnifiedPaymentSolutions/everypay-ios#configure-the-sdk-parameters)
  * [Get card information](https://github.com/UnifiedPaymentSolutions/everypay-ios#get-card-information)
  * [Send card information to EveryPay server](https://github.com/UnifiedPaymentSolutions/everypay-ios#send-card-your-everypay-credentials-and-needed-security-information-to-everypay-server)
* [Customising the app <-> merchant server communication steps](https://github.com/UnifiedPaymentSolutions/everypay-ios#customising-the-app---merchant-server-communication-steps)
* [Customising the card input form](https://github.com/UnifiedPaymentSolutions/everypay-ios#customising-the-card-input-form)

## Overview

The payment process happens in four steps.

1. Card input. The user enters their card details, which are validated for basic errors (length and checksum on the number, length of the verification code, date of expiry in the future).
2. API call to the merchant (your) server, requesting EveryPay API credentials.
3. EveryPay API call, which saves & validates the card details, and returns an encrypted card token.
4. API call to the merchant (your) server with the encrypted card token. The merchant can decrypt the card token with a server-side EveryPay API call, and make a payment immediately or save it for later.

Example implementation is provided for steps 2 and 4, even if they are likely to be replaced in most apps. EPCardInfoViewController can be replaced or modified for step 1 to match your branding.

## Integrating the SDK

### Manually

Add folder sdk to your project and include EPApi.h where needed.

### Using CocoaPods

Add 'everyPay-ios' to podfile.

### Configure the SDK parameters

Modify kEveryPayApiLive and kEveryPayApiTesting URLs in Constants.h to your needs.

```objectivec
NSString *const kEveryPayApiTesting = YOUR_TESTING_URL;
NSString *const kEveryPayApiLive = YOUR_LIVE_URL;
```

### Get card information

Open a EPCardInfoViewController from your viewcontroller:

```objectivec
	EPCardInfoViewController *cardInfoViewController = [[EPCardInfoViewController alloc] initWithNibName:NSStringFromClass([EPCardInfoViewController class]) bundle:nil];
    [cardInfoViewController setDelegate:self];
    [self presentViewController:cardInfoViewController animated:YES completion:nil];
```

Let your viewcontroller implement EPCardViewControllerDelegate method `cardInfoViewController:didEnterInfoForCard:`.
After user has entered all needed data this delegate method will be called with a validated EPCard object.

```objectivec
- (void)cardInfoViewController:(UIViewController *)controller didEnterInfoForCard:(EPCard *)card {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self sendCardInfoToMerchant:card];
}
```

### Send card, your EveryPay credentials and needed security information to EveryPay server

Call `sendCard:withMerchantInfo:withSuccess:andError:`, where `merchantinfo` is dictionary containing your EveryPay username, account, ip and security info:
```
"account_id" = EUR1;
"api_username" = apiuserame;
hmac = 6c893c8642176b401e918ba61a47123456780c1d;
nonce = b58a1ff58cd9817347e206f30fcb82d5;
timestamp = 1440506937;
"user_ip" = "100.100.100.100";
```

```objectivec
[EPApi sendCard:card withMerchantInfo:merchantInfo withSuccess:^(NSString *token) {
        [self payWithToken:token andMerchantInfo:merchantInfo];
    } andError:^(NSArray *errors) {
        [self showAlertWithError:[errors firstObject]];
    }];
```

Success block will be called with encrypted token, failure block will contain array of NSError objects. Both blocks will be called on main thread.

## Customising the app <-> merchant server communication steps

The SDK includes example implementation for the app - merchant API calls, with the minimal required data for a payment. However, most apps using EveryPay will want to replace the communication step between the app and your server - for example to add your own user accounts, save shopping baskets or subscription plans.
To provide a replacement, rewrite methods in EPMerchantApi class.

## Customising the card input form

If the EveryPay card input form does not match your requirements, or if you wish to add custom branding beyond the configuration options, then you can create a custom one. There are two requirements for a custom card form:

* It should construct a [EPCard](https://github.com/UnifiedPaymentSolutions/everypay-ios/blob/master/everyPay/sdk/model/EPCard.h). The Card model can also be used to validate the inputs.
