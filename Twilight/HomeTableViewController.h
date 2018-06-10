//
//  HomeTableViewController.h
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *carrierNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeColorHexCode;
@property (weak, nonatomic) IBOutlet UILabel *netcatIP;

@end

NS_ASSUME_NONNULL_END
