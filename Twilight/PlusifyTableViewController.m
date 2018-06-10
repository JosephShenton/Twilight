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
    
    resolutions = @{
        @"iPhone SE" : @"640x1136",
        @"iPhone 6" : @"750x1134",
        @"iPhone 6S" : @"750x1134",
        @"iPhone 7" : @"750x1134",
        @"iPhone 8" : @"750x1134",
        @"iPhone 6 Plus" : @"1080x1920",
        @"iPhone 6S Plus" : @"1080x1920",
        @"iPhone 7 Plus" : @"1080x1920",
        @"iPhone 8 Plus" : @"1080x1920",
        @"iPhone X" : @"1125x2436"
    };
}


- (IBAction)applyTweak:(id)sender {
    
    if ([[devices deviceName] containsString:@"iPod"] || [[devices deviceName] containsString:@"iPad"]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showSuccess:self title:@"Not compatible" subTitle:[NSString stringWithFormat:@"Sorry, however this tweak doesn't support the %@. Sorry about that.", [devices deviceName]] closeButtonTitle:@"Ok" duration:0.0f];
    } else {
        NSLog(@"[INFO]: Width: %@, Height: %@", @"751", @"1334");
        
        
        if ([changeScreenResolutions(751, 1334) isEqual: @"reboot"]) {
            
            NSString *pathForFile = @"/private/var/.TwilightTweaks.plist";
            
            NSMutableDictionary *tweaks = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
            // NSString* installStatus = (NSString*)[tweaks valueForKey: @"Plusify"];
            // NSLog(@"current install status is %@", installStatus);
            
            [tweaks setValue:@"Enabled" forKey: @"Plusify"];
            
            [tweaks writeToFile:pathForFile atomically: YES];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert addTimerToButtonIndex:0 reverse:YES];
            [alert alertIsDismissed:^{
                rebootDevice();
            }];
            [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 10 seconds!" closeButtonTitle:@"Reboot" duration:10.0f];
        }
    }
}

- (IBAction)uninstallTweak:(id)sender {
    
    NSString *resolution = resolutions[[devices deviceName]];
    
    NSArray *widthHeight = [resolution componentsSeparatedByString:@"x"];
    
    NSLog(@"[INFO]: Width: %@, Height: %@", widthHeight[0], widthHeight[1]);
    
    
    if ([changeScreenResolutions((int)[widthHeight[0] integerValue], (int)[widthHeight[1] integerValue]) isEqual: @"reboot"]) {
        NSString *pathForFile = @"/private/var/.TwilightTweaks.plist";
        
        NSMutableDictionary *tweaks = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
        // NSString* installStatus = (NSString*)[tweaks valueForKey: @"Plusify"];
        // NSLog(@"current install status is %@", installStatus);
        
        [tweaks setValue:@"Disabled" forKey: @"Plusify"];
        
        [tweaks writeToFile:pathForFile atomically: YES];
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addTimerToButtonIndex:0 reverse:YES];
        [alert alertIsDismissed:^{
            rebootDevice();
        }];
        [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 10 seconds!" closeButtonTitle:@"Reboot" duration:10.0f];
    }
}


@end
