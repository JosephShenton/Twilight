//
//  PlusifyTableViewController.h
//  Twilight
//
//  Created by Joseph Shenton on 10/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "utilities.h"
#include "tweaks.h"
#include "SCLAlertView/SCLAlertView.h"
#include "devices.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlusifyTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *plusifyStatus;

@end

static NSDictionary *resolutions;

NS_ASSUME_NONNULL_END
