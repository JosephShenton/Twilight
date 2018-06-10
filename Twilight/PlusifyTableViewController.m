//
//  PlusifyTableViewController.m
//  Twilight
//
//  Created by Joseph Shenton on 10/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "PlusifyTableViewController.h"

@interface PlusifyTableViewController ()

@end

@implementation PlusifyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    751x1334
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"plusify"]) {
        self.plusifyStatus.text = @"Enabled";
    } else {
        self.plusifyStatus.text = @"Disabled";
    }
}


- (IBAction)applyTweak:(id)sender {
    
    NSLog(@"[INFO]: Width: %@, Height: %@", @"751", @"1334");
    
    
    if ([changeScreenResolutions(751, 1334) isEqual: @"reboot"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"plusify"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addTimerToButtonIndex:0 reverse:YES];
        [alert alertIsDismissed:^{
            rebootDevice();
        }];
        [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 6 seconds!" closeButtonTitle:@"Reboot" duration:6.0f];
    }
}

@end
