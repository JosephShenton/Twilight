//
//  ScreenResolutionTableViewController.m
//  Twilight
//
//  Created by Joseph Shenton on 10/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "ScreenResolutionTableViewController.h"

@interface ScreenResolutionTableViewController ()

@end

@implementation ScreenResolutionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    ↓
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"customResolution"]) {
        self.currentResolution.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentResolution"];
    } else {
        self.currentResolution.text = @"Default";
    }
    
}
- (IBAction)chooseResolution:(id)sender {
        NSArray *items = @[@"iPhone SE", @"iPhone 6", @"iPhone 6S", @"iPhone 7", @"iPhone 8", @"iPhone 6 Plus", @"iPhone 6S Plus", @"iPhone 7 Plus", @"iPhone 8 Plus", @"iPhone X"];

        self.actionSheetPicker = [GKActionSheetPicker stringPickerWithItems:items selectCallback:^(id selected) {
            NSLog(@"Selected resolution: %@", selected);
            self.setNextResolution.text = selected;
//            [[NSUserDefaults standardUserDefaults] setObject:selected forKey:@"currentResolution"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"customResolution"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        } cancelCallback:nil];
    
        [self.actionSheetPicker presentPickerOnView:self.view];
}

- (IBAction)applyTweak:(id)sender {
    
    if ([[devices deviceName] containsString:@"iPod"] || [[devices deviceName] containsString:@"iPad"]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showSuccess:self title:@"Not compatible" subTitle:[NSString stringWithFormat:@"Sorry, however this tweak doesn't support the %@. Sorry about that.", [devices deviceName]] closeButtonTitle:@"Ok" duration:0.0f];
    } else {
        NSString *selected = self.setNextResolution.text;
        NSString *resolution = resolutions[selected];
        
        NSArray *widthHeight = [resolution componentsSeparatedByString:@"x"];
        
        NSLog(@"[INFO]: Width: %@, Height: %@", widthHeight[0], widthHeight[1]);
        
        
        if ([changeScreenResolutions((int)[widthHeight[0] integerValue], (int)[widthHeight[1] integerValue]) isEqual: @"reboot"]) {
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
            
            if ([data objectForKey:@"ScreenResolution"] != nil) {
                //To insert the data into the plist
                [data setValue:selected forKey:@"ScreenResolution"];
                [data writeToFile:pathForFile atomically:YES];
                
                //To retrieve the data from the plist
                NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
                NSString *value = [savedValue objectForKey:@"ScreenResolution"];
                NSLog(@"%@",value);
            } else {
                //To insert the data into the plist
                [data setValue:selected forKey:@"ScreenResolution"];
                [data writeToFile:pathForFile atomically:YES];
                
                //To retrieve the data from the plist
                NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile:pathForFile];
                NSString *value = [savedValue objectForKey:@"ScreenResolution"];
                NSLog(@"%@",value);
            }
            
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
    
    
    if ([changeScreenResolutions(751, 1334) isEqual: @"reboot"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"plusify"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addTimerToButtonIndex:0 reverse:YES];
        [alert alertIsDismissed:^{
            rebootDevice();
        }];
        [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 10 seconds!" closeButtonTitle:@"Reboot" duration:10.0f];
    }
}

@end
