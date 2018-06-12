//
//  BadgeColorTableViewController.h
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "utilities.h"
#include "tweaks.h"
#include "SCLAlertView/SCLAlertView.h"


NS_ASSUME_NONNULL_BEGIN
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface BadgeColorTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *currentBadgeColor;
@property (weak, nonatomic) IBOutlet UITextField *updatedBadgeColor;
@property (weak, nonatomic) IBOutlet UITextField *opacityNumber;

@end

static NSUserDefaults *defaults;

NS_ASSUME_NONNULL_END
