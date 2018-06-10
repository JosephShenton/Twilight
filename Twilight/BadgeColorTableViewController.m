//
//  BadgeColorTableViewController.m
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "BadgeColorTableViewController.h"

@interface BadgeColorTableViewController ()

@end

@implementation BadgeColorTableViewController

@synthesize currentBadgeColor, updatedBadgeColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"hasCustomBadgeColor"]) {
        // Has Set Custom Badge Color
        NSString *color = [defaults objectForKey:@"badgeColor"];
        currentBadgeColor.text = color;
    } else {
        // Default Badge Color
        currentBadgeColor.text = @"Default";
    }
}

- (IBAction)changeBadgeColor:(id)sender {
    if ([updatedBadgeColor.text  isEqual: @""]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"Error" subTitle:@"Please enter a new badge color hex (E.G. #000000) and try again!" closeButtonTitle:@"OK" duration:0.0f];
    } else {
        int ret = bc([updatedBadgeColor.text UTF8String], FALSE);
        if (ret == 1) {
            NSString *pathForFile = @"/private/var/.TwilightTweaks.plist";
            
            NSMutableDictionary *tweaks = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
            // NSString* installStatus = (NSString*)[tweaks valueForKey: @"Plusify"];
            // NSLog(@"current install status is %@", installStatus);
            
            [tweaks setValue:updatedBadgeColor.text forKey: @"BadgeColor"];
            
            [tweaks writeToFile:pathForFile atomically: YES];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert addTimerToButtonIndex:0 reverse:YES];
            [alert alertIsDismissed:^{
                rebootDevice();
            }];
            [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 6 seconds!" closeButtonTitle:@"Reboot" duration:6.0f];
        } else if (ret == -2) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self title:@"Failed" subTitle:@"Sorry, but Twilight failed to detect the correct badge size for your device." closeButtonTitle:@"Ok" duration:0.0];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self title:@"Failed" subTitle:@"Sorry, but an unknown error has occured." closeButtonTitle:@"Ok" duration:0.0];
        }
        
    }
}

@end
