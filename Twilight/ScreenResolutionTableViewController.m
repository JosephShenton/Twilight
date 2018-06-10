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
            [[NSUserDefaults standardUserDefaults] setObject:selected forKey:@"currentResolution"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"customResolution"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } cancelCallback:nil];
    
        [self.actionSheetPicker presentPickerOnView:self.view];
}

- (IBAction)applyTweak:(id)sender {
    
    NSString *selected = self.setNextResolution.text;
    NSString *resolution = resolutions[selected];
    
    NSArray *widthHeight = [resolution componentsSeparatedByString:@"x"];
    
    NSLog(@"[INFO]: Width: %@, Height: %@", widthHeight[0], widthHeight[1]);
    
    
    if ([changeScreenResolutions((int)[widthHeight[0] integerValue], (int)[widthHeight[1] integerValue]) isEqual: @"reboot"]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addTimerToButtonIndex:0 reverse:YES];
        [alert alertIsDismissed:^{
            rebootDevice();
        }];
        [alert showSuccess:self title:@"Success" subTitle:@"Your device will now reboot in 6 seconds!" closeButtonTitle:@"Reboot" duration:6.0f];
    }
}

@end