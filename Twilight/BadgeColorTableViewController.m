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
        int ret = setBadgeColor([updatedBadgeColor.text UTF8String], FALSE);
        if (ret == 1) {
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
            
            if ([data objectForKey:@"BadgeColor"] != nil) {
                //To insert the data into the plist
                [data setValue:updatedBadgeColor.text forKey:@"BadgeColor"];
                [data writeToFile:pathForFile atomically:YES];
                
                //To retrieve the data from the plist
                NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
                NSString *value = [savedValue objectForKey:@"BadgeColor"];
                NSLog(@"%@",value);
            } else {
                //To insert the data into the plist
                [data setValue:updatedBadgeColor.text forKey:@"BadgeColor"];
                [data writeToFile:pathForFile atomically:YES];
                
                //To retrieve the data from the plist
                NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
                NSString *value = [savedValue objectForKey:@"BadgeColor"];
                NSLog(@"%@",value);
            }
            
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
