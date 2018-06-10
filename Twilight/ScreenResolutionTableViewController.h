//
//  ScreenResolutionTableViewController.h
//  Twilight
//
//  Created by Joseph Shenton on 10/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKActionSheetPicker/Classes/GKActionSheetPicker.h"
#import "GKActionSheetPicker/Classes/GKActionSheetPickerItem.h"
#include "utilities.h"
#include "tweaks.h"
#include "SCLAlertView/SCLAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScreenResolutionTableViewController : UITableViewController

    @property (nonatomic, strong) GKActionSheetPicker *actionSheetPicker;
@property (weak, nonatomic) IBOutlet UILabel *currentResolution;
@property (weak, nonatomic) IBOutlet UILabel *setNextResolution;

@end

static NSDictionary *resolutions;

NS_ASSUME_NONNULL_END
