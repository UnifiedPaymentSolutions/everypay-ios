//
//  CardInfoViewController.m
//  everyPay
//
//  Created by Lauri Eskor on 25/08/15.
//  Copyright (c) 2015 MobiLab. All rights reserved.
//

#import "EPCardInfoViewController.h"
#import "NSDate+Additions.h"

@interface EPCardInfoViewController ()

@property (strong, nonatomic) NSDate *selectedDate;

@end

const NSInteger kMinYear = 2015;
const NSInteger kMaxYear = 2022;

@implementation EPCardInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.name setPlaceholder:NSLocalizedString(@"Name on card", nil)];
    [self.number setPlaceholder:NSLocalizedString(@"Card number", nil)];
    [self.cvc setPlaceholder:NSLocalizedString(@"CVC", nil)];
    [self.expiration setPlaceholder:NSLocalizedString(@"Expiration", nil)];


    [self.expiration setDelegate:self];
    [self.expiration setTintColor:[UIColor clearColor]];
    [self createDatePicker];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tapRecognizer];

    // Add sample card data to fields
    [self.name setText:@"Tom Smith"];
    [self.number setText:@"5168832136360487"];
    [self.cvc setText:@"119"];
    
    NSDate *date = [NSDate dateWithYear:2018 andMonth:10];
    self.selectedDate = date;
    NSString *dateString = [date expirationString];
    [self.expiration setText:dateString];
}

- (void)createDatePicker {
    UIPickerView *picker = [UIPickerView new];
    [picker setDelegate:self];
    [picker setDataSource:self];
    [self.expiration setInputView:picker];
}

- (IBAction)doneTapped:(id)sender {
    
    EPCard *card = [[EPCard alloc] initWithName:self.name.text number:self.number.text expirationDate:self.selectedDate andCVC:self.cvc.text];
    
    NSError *validationError = [card validateCard];

    if (!validationError) {
        if ([self.delegate respondsToSelector:@selector(cardInfoViewController:didEnterInfoForCard:)]) {
            [self.delegate cardInfoViewController:self didEnterInfoForCard:card];
        }
    } else {
        [self showAlertWithError:validationError];
    }
}

- (void)showAlertWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

- (void)closeKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 12;
    } else {
        return kMaxYear - kMinYear;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger selectedYear = [@([pickerView selectedRowInComponent:1]) integerValue] + kMinYear;
    NSInteger selectedMonth = [@([pickerView selectedRowInComponent:0]) integerValue] + 1;
    NSDate *date = [NSDate dateWithYear:selectedYear andMonth:selectedMonth];
    self.selectedDate = date;
    NSString *dateString = [date expirationString];
    [self.expiration setText:dateString];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *returnString;
    
    if (component == 0) {
        returnString = [@(row + 1) stringValue];
    } else {
        returnString = [@(row + kMinYear) stringValue];
    }
    return returnString;
}

@end
