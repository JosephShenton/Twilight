//
//  CarrierNameTableViewController.m
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "CarrierNameTableViewController.h"
#include "utilities.h"
#include "tweaks.h"
#include "SCLAlertView/SCLAlertView.h"

@interface CarrierNameTableViewController ()

@end

@implementation CarrierNameTableViewController

@synthesize currentName, carrierNameNew, carrierScreenshot;

- (void)viewDidLoad {
    [super viewDidLoad];
    currentName.text = carrierName();
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [carrierScreenshot.layer setShadowColor: [UIColor grayColor].CGColor];
    [carrierScreenshot.layer setShadowOpacity:0.8];
    [carrierScreenshot.layer setShadowRadius:3.0];
    [carrierScreenshot.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)dismissKeyboard {
    [carrierNameNew resignFirstResponder];
}

- (IBAction)setCarrier:(id)sender {
    if ([carrierNameNew.text  isEqual: @""]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"Error" subTitle:@"Please enter a new carrier text and try again!" closeButtonTitle:@"OK" duration:0.0f];
    } else {
        NSString *carrier = setCarrierName(carrierNameNew.text);
        if ([carrier  isEqual: @"reboot"]) {
            
            NSString *pathForFile = @"/private/var/.TwilightTweaks.plist";
            
            NSMutableDictionary *tweaks = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
            // NSString* installStatus = (NSString*)[tweaks valueForKey: @"Plusify"];
            // NSLog(@"current install status is %@", installStatus);
            
            [tweaks setValue:carrierNameNew.text forKey: @"CustomCarrier"];
            
            [tweaks writeToFile:pathForFile atomically: YES];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert addTimerToButtonIndex:0 reverse:YES];
            [alert alertIsDismissed:^{
                rebootDevice();
            }];
            [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 6 seconds!" closeButtonTitle:@"Reboot" duration:6.0f];
        }
    }
   
}

@end
