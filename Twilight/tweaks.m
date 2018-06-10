//
//  tweaks.m
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "tweaks.h"
#include "utilities.h"
#include "kmem.h"
#include "offsets.h"
#include <sys/stat.h>
#include <mach/mach.h>
#include <sys/utsname.h>
#include <stdlib.h>
#include <spawn.h>
#include <sys/dirent.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <libgen.h>
#include <dlfcn.h>
#include <objc/runtime.h>

#import <mach-o/loader.h>
#import "UIImage+Private.h"

NSString* setCarrierName(NSString *new_name) {
    
    char *path = "/var/mobile/Library/Carrier Bundles/Overlay";
    
    DIR *mydir;
    struct dirent *myfile;
    
    FILE *f = fopen("/var/mobile/.roottest", "w");
    if (f == 0) {
        //        FAILURE
        printf("[ERROR]: WHY NO ROOT FOR CARRIER NAME???");
    } else {
        
        //         SUCCESS
    }
    fclose(f);
    
    printf("[INFO]: opening %s carriers folder\n", path);
    int fd = open(path, O_RDONLY, 0);
    
    if (fd < 0)
        return @"failed";
    
    // output path
    NSString *output_dir_path = getPathForDir(@"carriers");
    
    mydir = fdopendir(fd);
    while((myfile = readdir(mydir)) != NULL) {
        
        char *name = myfile->d_name;
        
        if(strcmp(name, ".") == 0 || strcmp(name, "..") == 0)
            continue;
        
        // get the file (path + name)
        copy_file(strdup([[NSString stringWithFormat:@"%s/%s", path, name] UTF8String]), strdup([[NSString stringWithFormat:@"%@/%s", output_dir_path, name] UTF8String]), MOBILE_UID, MOBILE_GID, 0755, NO);
        
        // backup the original file
        rename(strdup([[NSString stringWithFormat:@"%s/%s", path, name] UTF8String]),
               strdup([[NSString stringWithFormat:@"%s/%s.backup", path, name] UTF8String]));
        
        
    }
    
    closedir(mydir);
    close(fd);
    
    // read each file we copied
    NSArray *directory_content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:output_dir_path error:NULL];
    for (NSString *plist_name in directory_content) {
        
        
        NSString *copied_plist_path = [NSString stringWithFormat:@"%@/%@", output_dir_path, plist_name];
        printf("[INFO]: copied file: %s\n", strdup([copied_plist_path UTF8String]));
        
        // read each plist and do the renaming
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:copied_plist_path];
        
        if(dict == NULL)
            continue;
        
        [dict setObject:new_name forKey:@"CarrierName"];
        
        if ([dict objectForKey:@"MVNOOverrides"]) {
            
            NSObject *object = [dict objectForKey:@"MVNOOverrides"];
            
            if([object isKindOfClass:[NSMutableDictionary class]]){
                NSMutableDictionary *mv_no_overriders_dict = (NSMutableDictionary *)object;
                
                if([mv_no_overriders_dict objectForKey:@"StatusBarImages"]) {
                    
                    NSMutableArray *status_bar_images_array = [mv_no_overriders_dict objectForKey:@"StatusBarImages"];
                    
                    for (NSMutableDictionary *item in status_bar_images_array) {
                        
                        if([item objectForKey:@"StatusBarCarrierName"]) {
                            [item setObject:new_name forKey:@"StatusBarCarrierName"];
                        }
                        
                        if([item objectForKey:@"CarrierName"]) {
                            [item setObject:new_name forKey:@"CarrierName"];
                        }
                    }
                }
                
            }
        }
        
        [dict setObject:new_name forKey:@"OverrideOperatorName"];
        [dict setObject:new_name forKey:@"OverrideOperatorWiFiName"];
        
        if ([dict objectForKey:@"IMSConfigSecondaryOverlay"]) {
            
            NSMutableDictionary *ims_config_dict = (NSMutableDictionary *)[dict objectForKey:@"IMSConfigSecondaryOverlay"];
            
            if([ims_config_dict objectForKey:@"CarrierName"]) {
                [ims_config_dict setValue:new_name forKey:@"CarrierName"];
            }
        }
        
        if ([dict objectForKey:@"StatusBarImages"]) {
            
            NSMutableArray *status_bar_images_array = [dict objectForKey:@"StatusBarImages"];
            
            for (NSMutableDictionary *item in status_bar_images_array) {
                
                if([item objectForKey:@"StatusBarCarrierName"]) {
                    [item setObject:new_name forKey:@"StatusBarCarrierName"];
                }
                
                if([item objectForKey:@"CarrierName"]) {
                    [item setObject:new_name forKey:@"CarrierName"];
                }
            }
            
        }
        
        
        NSString *saved_plist_path = [NSString stringWithFormat:@"%@/%@", output_dir_path, [plist_name lastPathComponent]];
        
        printf("[INFO]: saving carrier plist to: %s\n", strdup([saved_plist_path UTF8String]));
        [dict writeToFile:saved_plist_path atomically:YES];
        
        // move the file back
        copy_file(strdup([saved_plist_path UTF8String]), strdup([[NSString stringWithFormat:@"%s/%@", path, plist_name] UTF8String]), INSTALL_UID, INSTALL_GID, 0755, NO);
        
    }
    
    sleep(3);
    printf("[INFO]: saved carrier, please respring and pray it fucking works and you don't bootloop!\n");
//    rebootDevice();
    return @"reboot";
}

kern_return_t setCustomHosts(boolean_t use_custom) {
    
    kern_return_t ret = KERN_SUCCESS;
    
    // revert first
    copy_file("/etc/bck_hosts", "/etc/hosts", ROOT_UID, WHEEL_GID, 0644, NO);
    
    // delete the old 'bck_hosts' file
    unlink("/etc/bck_hosts");
    
    if(use_custom) {
        
        printf("[INFO]: requested a custom hosts file!\n");
        
        // backup the original one
        copy_file("/etc/hosts", "/etc/bck_hosts", ROOT_UID, WHEEL_GID, 0644, NO);
        
        // copy our custom hosts file
        char *custom_hosts_path = strdup([[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/custom_hosts"] UTF8String]);
        copy_file(custom_hosts_path, "/etc/hosts", ROOT_UID, WHEEL_GID, 0644, NO);
    }
    
    return ret;
}

NSString* setBadgeColor(const char *color_raw, const char *size_type) {
    
    UIImage *badge;
    NSString *file_name;
    
    NSString *color_raw_fixed = [[[NSString stringWithFormat:@"%s", color_raw] uppercaseString] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (strcmp("2x", size_type) == 0) {
        badge = get_image_for_radius(12, 24, 24);
        file_name = @"SBBadgeBG@2x.png";
    } else if (strcmp("3x", size_type) == 0) {
        badge = get_image_for_radius(24, 48, 48);
        file_name = @"SBBadgeBG@3x.png";
    }
    
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:
      [[[NSString stringWithFormat:@"%@", color_raw_fixed] uppercaseString] stringByTrimmingCharactersInSet:
       [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet]]]
     scanHexInt:&rgb];
    
    UIColor *uiColor = [UIColor colorWithRed:((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0
                                       green:((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0
                                        blue:((CGFloat)(rgb & 0xFF)) / 255.0
                                       alpha:1.0];
    badge = change_image_tint_to(badge, uiColor);
    
    
    // iOS 11, save as png and copy to SpringBoard (EDIT: 11 now stores files in Assets.car :( )
    // iOS 10, save as cpbitmap and copy to Caches
    //    if ([[[UIDevice currentDevice] systemVersion] containsString:@"11"]) {
    //
    //        NSString *saved_png_path = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], file_name];
    //
    //        NSData *image_data = UIImagePNGRepresentation(badge);
    //        [image_data writeToFile:saved_png_path atomically:YES];
    //
    //
    //        copy_file(strdup([saved_png_path UTF8String]), strdup([[@"/System/Library/CoreServices/SpringBoard.app/" stringByAppendingString:file_name] UTF8String]), MOBILE_UID, MOBILE_GID, 0666);
    //
    //    } else {
    NSString *saved_cpbitmap_path = [NSString stringWithFormat:@"%@/SBIconBadgeView.BadgeBackground.cpbitmap", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    
    [badge writeToCPBitmapFile:saved_cpbitmap_path flags:1];
    
    copy_file(strdup([saved_cpbitmap_path UTF8String]), "/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground.cpbitmap", MOBILE_UID, MOBILE_GID, 0666, NO);
    //    }
    
    return @"reboot";
    
}

NSString* changeScreenResolutions (int width, int height) {
    
    printf("[INFO]: changing resolution to (w: %d, h: %d)\n", width, height);
    
    NSMutableDictionary *iomobile_graphics_family_dict = [[NSMutableDictionary alloc] init];
    
    [iomobile_graphics_family_dict setObject:[NSNumber numberWithInteger:height] forKey:@"canvas_height"];
    [iomobile_graphics_family_dict setObject:[NSNumber numberWithInteger:width] forKey:@"canvas_width"];
    
    // output path
    NSString *output_path = [NSString stringWithFormat:@"%@/com.apple.iokit.IOMobileGraphicsFamily.plist", getPathForDir(@"display")];
    
    [iomobile_graphics_family_dict writeToFile:output_path atomically:YES];
    
    copy_file(strdup([output_path UTF8String]), "/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", ROOT_UID, ROOT_UID, 01444, NO);
    
    return @"reboot";
}

// Thanks Torngat

void uninstallBadge() {
    unlink("/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground.cpbitmap");
}

UIColor* updateColour(const char *colour) {
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:
      [[[NSString stringWithFormat:@"%s", colour] uppercaseString] stringByTrimmingCharactersInSet:
       [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet]]]
     scanHexInt:&rgb];
    
    UIColor *uiColor = [UIColor colorWithRed:((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0
                                       green:((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0
                                        blue:((CGFloat)(rgb & 0xFF)) / 255.0
                                       alpha:1.0];
    
    return uiColor;
}

int size() {
    int detected;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        detected = 3;
    } else {
        detected = 2;
    }
    return detected;
}

int bc(const char *colour, BOOL transparent) {
    printf("size: %i\n", size());
    if (size() == 2) {
         UIGraphicsBeginImageContextWithOptions(CGRectMake(0, 0, 24, 24).size, NO, 0.0);
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
         CGRect size;
         if (transparent == FALSE) {
             size =  CGRectMake(0, 0, 24, 24);
         } else {
             size = CGRectMake(0, 0, 0, 0);
         }
         CGContextFillRect(context, size);
         badge = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0, 24.0), NO, 0.0);
         CGRect bounds=(CGRect){CGPointZero, CGSizeMake(24.0, 24.0)};
         [[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:12.0f] addClip];
         [badge drawInRect:bounds];
         badge = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
     } else if (size() == 3) {
         //UIGraphicsBeginImageContextWithOptions(CGRectMake(0, 0, 48, 48).size, NO, 0.0);
         UIGraphicsBeginImageContextWithOptions(CGRectMake(0, 0, 24, 24).size, NO, 0.0);
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
         CGRect size;
         if (transparent == FALSE) {
             size =  CGRectMake(0, 0, 48, 48);
         } else {
             size = CGRectMake(0, 0, 0, 0);
         }
         CGContextFillRect(context, size);
         badge = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         //UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0, 48.0), NO, 0.0);
         //CGRect bounds=(CGRect){CGPointZero, CGSizeMake(48.0, 48.0)};
         //[[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:24.0f] addClip];
         UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0, 24.0), NO, 0.0);
         CGRect bounds=(CGRect){CGPointZero, CGSizeMake(24.0, 24.0)};
         [[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:12.0f] addClip];
         [badge drawInRect:bounds];
         badge = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
     } else {
         return -2;
     }
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:
      [[[NSString stringWithFormat:@"%s", colour] uppercaseString] stringByTrimmingCharactersInSet:
       [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet]]]
     scanHexInt:&rgb];
    
    UIColor *uiColor = [UIColor colorWithRed:((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0
                                       green:((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0
                                        blue:((CGFloat)(rgb & 0xFF)) / 255.0
                                       alpha:1.0];
    CGRect rect = CGRectMake(0, 0, badge.size.width, badge.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, badge.CGImage);
    CGContextSetFillColorWithColor(context, [uiColor CGColor]);
    CGContextFillRect(context, rect);
    badge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [badge writeToCPBitmapFile:@"/private/var/mobile/Documents/IconBadgeBackground_Twilight.cpbitmap" flags:1];
    unlink("/private/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground.cpbitmap");
    int read_fd = open("/private/var/mobile/Documents/IconBadgeBackground_Twilight.cpbitmap", O_RDONLY, 0);
    int write_fd = open("/private/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground.cpbitmap", O_RDWR | O_CREAT | O_APPEND, 0777);
    if(fdopen(read_fd, "r") == NULL) {
        return -1;
    }
    if(fdopen(write_fd, "wb") == NULL) {
        return -1;
    }
    FILE *read_f = fdopen(read_fd, "r");
    FILE *write_f = fdopen(write_fd, "wb");
    size_t write_size;
    size_t read_size;
    while(feof(read_f) == 0) {
        char buff[100];
        if((read_size = fread(buff, 1, 100, read_f)) != 100) {
            if(ferror(read_f) != 0) {
                return -1;
            }
        }
        if((write_size = fwrite(buff, 1, read_size, write_f)) != read_size) {
            return -1;
        }
    }
    fclose(read_f);
    fclose(write_f);
    close(read_fd);
    close(write_fd);
    if (unlink("/private/var/mobile/Documents/IconBadgeBackground_Twilight.cpbitmap") != 0) {
        return -1;
    }
    chown("/private/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground.cpbitmap", 501, 501);
    chmod("/private/var/mobile/Library/Caches/MappedImageCache/Persistent/SBIconBadgeView.BadgeBackground.cpbitmap", 0666);
    return 1;
}
