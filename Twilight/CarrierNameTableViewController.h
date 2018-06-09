//
//  CarrierNameTableViewController.h
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CarrierNameTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *currentName;
@property (weak, nonatomic) IBOutlet UITextField *carrierNameNew;
@property (weak, nonatomic) IBOutlet UIImageView *carrierScreenshot;

@end

NS_ASSUME_NONNULL_END
