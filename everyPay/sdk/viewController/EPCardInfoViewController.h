//
//  CardInfoViewController.h
//  everyPay
//
//  Created by Lauri Eskor on 25/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPCard;

/**
 EPCardInfoViewControllerDelegate provides data from card info input viewcontroller.
 */
@protocol EPCardInfoViewControllerDelegate <NSObject>

/** 
 cardInfoViewController:didEnterInfoForCard will be called after user has pressed 'Done' button on EPCardInfoViewController and if entered information is valid for a card.
 */
- (void)cardInfoViewController:(UIViewController *)controller didEnterInfoForCard:(EPCard *)card;


@end

/** 
 EPCardInfoViewController presents a card info input form with card holder name, card number, expiration date and cvc fields.
 
 After user taps 'Done' button, input is validated. If valid card data is present, delegate method cardInfoViewController:didEnterInfoForCard is called with created EPCard object. If there are problems with entered information, an alert will be shown.
 
 Error messages as well as filed placeholder texts can be customized and translated from Localizable.strings file.
 */

@interface EPCardInfoViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <EPCardInfoViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *cvc;
@property (weak, nonatomic) IBOutlet UITextField *expiration;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end
