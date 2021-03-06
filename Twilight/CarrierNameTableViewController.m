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
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSString *pathForFile = @"/var/Twilight.plist";
            
            if (![fileManager fileExistsAtPath:pathForFile]) {
                
            }
            
            NSMutableDictionary *data;
            
            if ([fileManager fileExistsAtPath:pathForFile]) {
                data = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
            }
            else {
                data = [[NSMutableDictionary alloc] init];
            }
            
            if ([data objectForKey:@"CustomCarrier"] != nil) {
                //To insert the data into the plist
                [data setValue:@"Enabled" forKey:@"CustomCarrier"];
                [data writeToFile:pathForFile atomically:YES];
                
                //To retrieve the data from the plist
                NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
                NSString *value = [savedValue objectForKey:@"CustomCarrier"];
                NSLog(@"%@",value);
            } else {
                //To insert the data into the plist
                [data setObject:@"Enabled" forKey:@"CustomCarrier"];
                [data writeToFile:pathForFile atomically:YES];
                
                //To retrieve the data from the plist
                NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
                NSString *value = [savedValue objectForKey:@"CustomCarrier"];
                NSLog(@"%@",value);
            }
            
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
