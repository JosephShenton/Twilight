//
//  HomeTableViewController.m
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "HomeTableViewController.h"
#include "utilities.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

@synthesize carrierNameLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    carrierNameLabel.text = carrierName();
}

@end
