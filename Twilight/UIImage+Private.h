//
//  UIImage+Private.h
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#include <UIKit/UIKit.h>
#include <sys/cdefs.h>

@class LSApplicationProxy;

__BEGIN_DECLS

UIImage *_UIImageWithName(NSString *name);

__END_DECLS

@interface UIImage (Private)

+ (instancetype)kitImageNamed:(NSString *)name;
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

+ (instancetype)imageWithContentsOfCPBitmapFile:(NSString *)filename flags:(NSInteger)flags; // TODO: make this an enum


- (instancetype)_flatImageWithColor:(UIColor *)color;

- (BOOL)writeToCPBitmapFile:(NSString *)filename flags:(NSInteger)flags; // TODO: make this an enum

@property CGFloat scale;

@end
