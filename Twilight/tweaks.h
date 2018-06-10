//
//  tweaks.h
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface tweaks : NSObject
NSString* setCarrierName(NSString *new_name);
kern_return_t setCustomHosts(boolean_t use_custom);
NSString* setBadgeColor(const char *color_raw, const char *size_type);
NSString* changeScreenResolutions (int width, int height);
int size(void);
int bc(const char *colour, BOOL transparent);
UIColor* updateColour();
@end

static UIImage *badge;

NS_ASSUME_NONNULL_END
