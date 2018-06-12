//
//  utilities.m
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "utilities.h"
#include "jelbrek/kern_utils.h"
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
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

NSString* getPathForDir(NSString *dir_name) {
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *final_path = [docDir stringByAppendingPathComponent:dir_name];
    
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:final_path isDirectory:&isDir])
    {
        if([fm createDirectoryAtPath:final_path withIntermediateDirectories:YES attributes:nil error:nil])
            printf("[INFO]: created dir with name: %s\n", [dir_name UTF8String]);
        else
            printf("[ERROR]: could not create dir with name: %s\n", [dir_name UTF8String]);
    }
    
    return final_path;
}

kern_return_t set_file_permissions (char * destination_path, int uid, int gid, int perm_num, bool silent) {
    
    // Chown the destination
    int ret = chown(destination_path, uid, gid);
    
    if (ret == -1) {
        if (!silent) {
            printf("[ERROR]: could not chown destination file: %s\n", destination_path);
        }
        return KERN_FAILURE;
    }
    
    // Chmod the destination
    ret = chmod(destination_path, perm_num);
    
    if (ret == -1) {
        if (!silent) {
            printf("[ERROR]: could not chmod destination file: %s\n", destination_path);
        }
        return KERN_FAILURE;
    }
    
    return KERN_SUCCESS;
}

kern_return_t copy_file(char * source_path, char * destination_path, int uid, int gid, int num_perm, bool silent) {
    
    if (!silent) {
        printf("[INFO]: deleting %s\n", destination_path);
    }
    
    // unlink destination first
    unlink(destination_path);
    
    if (!silent) {
        printf("[INFO]: copying files from (%s) to (%s)..\n", source_path, destination_path);
    }
    
    size_t read_size, write_size;
    char buffer[100];
    
    int read_fd = open(source_path, O_RDONLY, 0);
    int write_fd = open(destination_path, O_RDWR | O_CREAT | O_APPEND, 0777);
    
    FILE *read_file = fdopen(read_fd, "r");
    FILE *write_file = fdopen(write_fd, "wb");
    
    if(read_file == NULL) {
        if (!silent) {
            printf("[ERROR]: can't copy. failed to read file from path: %s\n", source_path);
        }
        return KERN_FAILURE;
        
    }
    
    if(write_file == NULL) {
        if (!silent) {
            printf("[ERROR]: can't copy. failed to write file with path: %s\n", destination_path);
        }
        return KERN_FAILURE;
    }
    
    while(feof(read_file) == 0) {
        
        if((read_size = fread(buffer, 1, 100, read_file)) != 100) {
            
            if(ferror(read_file) != 0) {
                if (!silent) {
                    printf("[ERROR]: could not read from: %s\n", source_path);
                }
                return KERN_FAILURE;
            }
        }
        
        if((write_size = fwrite(buffer, 1, read_size, write_file)) != read_size) {
            if (!silent) {
                printf("[ERROR]: could not write to: %s\n", destination_path);
            }
            return KERN_FAILURE;
        }
    }
    
    fclose(read_file);
    fclose(write_file);
    
    close(read_fd);
    close(write_fd);
    
    
    // Chown the destination
    kern_return_t ret = set_file_permissions(destination_path, uid, gid, num_perm, YES);
    if (ret != KERN_SUCCESS) {
        return KERN_FAILURE;
    }
    
    printf("[INFO]: Successfully copied files.");
    return KERN_SUCCESS;
}

void rebootDevice() {
    reboot(0);
}

@interface LSApplicationWorkspace : NSObject
+ (id) defaultWorkspace;
- (BOOL) registerApplication:(id)application;
- (BOOL) unregisterApplication:(id)application;
- (BOOL) invalidateIconCache:(id)bundle;
- (BOOL) registerApplicationDictionary:(id)application;
- (BOOL) installApplication:(id)application withOptions:(id)options;
- (BOOL) _LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)system internal:(BOOL)internal user:(BOOL)user;
@end

Class lsApplicationWorkspace = NULL;
LSApplicationWorkspace* workspace = NULL;

void invalidate_icon_cache(char *identifier) {
    
    // TODO (this won't work in iOS 11)
    
    if(lsApplicationWorkspace == NULL || workspace == NULL) {
        
        lsApplicationWorkspace = (objc_getClass("LSApplicationWorkspace"));
        workspace = [lsApplicationWorkspace performSelector:@selector(defaultWorkspace)];
        
    }
    
    if ([workspace respondsToSelector:@selector(invalidateIconCache:)]) {
        [workspace invalidateIconCache:nil];
    }
    
    
}

//pid_t pid_for_name(char *name) {
//    
//    extern uint64_t task_port_kaddr;
//    uint64_t struct_task = rk64(task_port_kaddr + koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
//    
//    
//    while (struct_task != 0) {
//        uint64_t bsd_info = rk64(struct_task + koffset(KSTRUCT_OFFSET_TASK_BSD_INFO));
//        
//        if(bsd_info <= 0)
//            return -1; // fail!
//        
//        if (((bsd_info & 0xffffffffffffffff) != 0xffffffffffffffff)) {
//            
//            char comm[MAXCOMLEN + 1];
//            kread(bsd_info + 0x268 /* KSTRUCT_OFFSET_PROC_COMM */, comm, 17);
//            printf("name: %s\n", comm);
//            
//            if(strcmp(name, comm) == 0) {
//                
//                // get the process pid
//                uint32_t pid = rk32(bsd_info + koffset(KSTRUCT_OFFSET_PROC_PID));
//                return (pid_t)pid;
//            }
//        }
//        
//        struct_task = rk64(struct_task + koffset(KSTRUCT_OFFSET_TASK_PREV));
//        
//        if(struct_task == -1)
//            return -1;
//    }
//    return -1; // we failed :/
//}

void respringDevice() {
    
    // remove all cached icons
    char *path = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.lsd.iconscache/Library/Caches/com.apple.IconsCache";
    
    DIR *target_dir;
    struct dirent *file;
    
    int fd = open(path, O_RDONLY, 0);
    
    if (fd >= 0) {
        
        target_dir = fdopendir(fd);
        while((file = readdir(target_dir)) != NULL) {
            
            NSString *file_name = [NSString stringWithFormat:@"%s", strdup(file->d_name)];
            
            NSString *full_path = [NSString stringWithFormat:@"%s/%@", path, file_name];
            printf("[INFO]: unlinking: %s\n", strdup([full_path UTF8String]));
            unlink(strdup([full_path UTF8String]));
            
        }
        
        closedir(target_dir);
        close(fd);
    }
    
    invalidate_icon_cache(nil);
    path = "/var/mobile/Library/Caches";
    
    DIR *mydir;
    struct dirent *myfile;
    
    fd = open(path, O_RDONLY, 0);
    
    if (fd < 0)
        return;
    
    mydir = fdopendir(fd);
    while((myfile = readdir(mydir)) != NULL) {
        
        NSString *file_name = [NSString stringWithFormat:@"%s", strdup(myfile->d_name)];
        if ([file_name containsString:@".csstore"]) {
            
            printf("[INFO]: deleting csstore: %s\n", strdup([file_name UTF8String]));
            
            NSString *full_path = [NSString stringWithFormat:@"%s/%@", path, file_name];
            unlink(strdup([full_path UTF8String]));
            
        }
        
    }
    
    closedir(mydir);
    close(fd);
    
    // kill lsd
    pid_t lsd_pid = pid_for_name("/usr/libexec/lsd");
    kill(lsd_pid, SIGKILL);
    
    // remove caches
    unlink("/var/mobile/Library/Caches/com.apple.springboard-imagecache-icons");
    unlink("/var/mobile/Library/Caches/com.apple.springboard-imagecache-icons.plist");
    unlink("/var/mobile/Library/Caches/com.apple.springboard-imagecache-smallicons");
    unlink("/var/mobile/Library/Caches/com.apple.springboard-imagecache-smallicons.plist");
    
    unlink("/var/mobile/Library/Caches/SpringBoardIconCache");
    unlink("/var/mobile/Library/Caches/SpringBoardIconCache-small");
    unlink("/var/mobile/Library/Caches/com.apple.IconsCache");
    
    
    // kill installd
    pid_t installd_pid = pid_for_name("/usr/libexec/installd");
    kill(installd_pid, SIGKILL);
    
    // kill springboard
    kill_springboard(SIGKILL);
}

void kill_springboard(int sig) {
    
    printf("[INFO]: requested to kill SpringBoard!\n");
    pid_t springboard_pid = pid_for_name("/System/Library/CoreServices/SpringBoard.app/SpringBoard");
    if(springboard_pid == -1)
        springboard_pid = pid_for_name("SpringBoard");
    
    printf("[INFO]: springboard's pid: %d\n", springboard_pid);
    
    kill(springboard_pid, sig);
    
    if(sig == SIGKILL)
        exit(0);
}

NSString* carrierName() {
    UIView* statusBar = statusBarArea();
    
    UIView* statusBarForegroundView = nil;
    
    for (UIView* view in statusBar.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarForegroundView")])
        {
            statusBarForegroundView = view;
            break;
        }
    }
    
    UIView* statusBarServiceItem = nil;
    
    for (UIView* view in statusBarForegroundView.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarServiceItemView")])
        {
            statusBarServiceItem = view;
            break;
        }
    }
    
    if (statusBarServiceItem)
    {
        id value = [statusBarServiceItem valueForKey:@"_serviceString"];
        
        if ([value isKindOfClass:[NSString class]])
        {
            return (NSString *)value;
        }
    }
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* carrier = networkInfo.subscriberCellularProvider;
    NSString* iOSCarrierName = carrier.carrierName;
    if (![iOSCarrierName  isEqual: @""]) {
        return iOSCarrierName;
    }
    return @"Unavailable";
}

UIView* statusBarArea() {
    NSString *statusBarString = [NSString stringWithFormat:@"%@ar", @"_statusB"];
    return [[UIApplication sharedApplication] valueForKey:statusBarString];
}

// contains list of apps taken from INSTALLED_APPS_DIR
NSMutableDictionary *all_apps;


// contains list of apps (bundle data uuid) taken from APPS_DATA_PATH
NSMutableArray *all_apps_data;

void read_apps_root_dir() {
    
    DIR *mydir;
    struct dirent *myfile;
    
    int fd = open(INSTALLED_APPS_PATH, O_RDONLY, 0);
    
    if (fd < 0)
        return;
    
    mydir = fdopendir(fd);
    
    if(mydir == NULL)
        return;
    
    while((myfile = readdir(mydir)) != NULL) {
        
        char *dir_name = myfile->d_name;
        
        // skip dirs that start with '.'
        if(strncmp(".", dir_name, 1) == 0 || myfile->d_type != DT_DIR) {
            continue;
        }
        
        NSString *app_uuid =  [NSString stringWithFormat:@"%s", strdup(dir_name)];
        NSString *full_path = [NSString stringWithFormat:@"%s/%@", INSTALLED_APPS_PATH, app_uuid];
        NSMutableDictionary *app_dict = [[NSMutableDictionary alloc]
                                         initWithObjectsAndKeys:
                                         app_uuid, @"uuid",
                                         full_path, @"full_path",
                                         nil];
        
        [all_apps setObject:app_dict forKey:app_uuid];
        
    }
    
    closedir(mydir);
    close(fd);
}

char * list_child_dirs(NSMutableDictionary *app_dict) {
    
    DIR *mydir;
    struct dirent *myfile;
    
    char *full_path = strdup([[app_dict objectForKey:@"full_path"] UTF8String]);
    int fd = open(full_path, O_RDONLY, 0);
    
    if (fd < 0)
        goto failed;
    
    mydir = fdopendir(fd);
    while((myfile = readdir(mydir)) != NULL) {
        
        char *dir_name = myfile->d_name;
        char *ext = strrchr(dir_name, '.');
        if (ext && !strcmp(ext, ".app")) {
            
//            printf("listing dir_name: %s\n", dir_name);
            [app_dict setObject:[NSString stringWithFormat:@"%s/%s" , full_path, strdup(dir_name)] forKey:@"app_path"];
            break;
        }
        
    }
    
    closedir(mydir);
    close(fd);
    
failed:
    return "";
}

/*
 *  Purpose: reads all apps along with their container_manager metadata
 *  then appends to all_apps_data
 */
void read_apps_data_dir() {
    
    if (all_apps_data == NULL) {
        all_apps_data = [[NSMutableArray alloc] init];
    }
    
    DIR *mydir;
    struct dirent *myfile;
    
    int fd = open(APPS_DATA_PATH, O_RDONLY, 0);
    
    if (fd < 0)
        return;
    
    mydir = fdopendir(fd);
    while((myfile = readdir(mydir)) != NULL) {
        
        char *data_uuid = myfile->d_name;
        
        if(strcmp(data_uuid, ".") == 0 || strcmp(data_uuid, "..") == 0)
            continue;
        
        [all_apps_data addObject:[NSString stringWithFormat:@"%s", data_uuid]];
        
    }
    
    closedir(mydir);
    close(fd);
    
}


kern_return_t read_app_info(NSMutableDictionary *app_dict, NSString *local_app_info_path) {
    
    
    FILE *info_file;
    long plist_size;
    char *plist_contents;
    
    char *info_path = strdup([[NSString stringWithFormat:@"%@/Info.plist" , [app_dict objectForKey:@"app_path"]] UTF8String]);
    int fd = open(info_path, O_RDONLY, 0);
    
    if (fd < 0)
        return KERN_FAILURE;
    
    info_file = fdopen(fd, "r");
    
    fseek(info_file, 0, SEEK_END);
    plist_size = ftell(info_file);
    rewind(info_file);
    plist_contents = malloc(plist_size * (sizeof(char)));
    fread(plist_contents, sizeof(char), plist_size, info_file);
    
    
    close(fd);
    fclose(info_file);
    
    NSString *plist_string = [NSString stringWithFormat:@"%s", plist_contents];
    NSData *data = [plist_string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSPropertyListFormat format;
    NSDictionary *dict = [NSPropertyListSerialization
                          propertyListWithData:data
                          options:kNilOptions
                          format:&format
                          error:&error];
    
    // check if we're null or not
    if(dict == NULL) { // probably a binary plist
        
        NSString *local_info_path = [NSString stringWithFormat:@"%@/Info.plist", local_app_info_path];
        
        // try to copy the file to our dir then read it
        copy_file(info_path, strdup([local_info_path UTF8String]), MOBILE_UID, MOBILE_GID, 0755, YES);
        
        dict = [NSDictionary dictionaryWithContentsOfFile:local_info_path];
        
        if(dict == NULL) {
            [app_dict setValue:@NO forKey:@"valid"];
            return KERN_FAILURE;
        }
    }
    
    
    // Some apps don't use "CFBundleDisplayName"
    if([dict objectForKey:@"CFBundleDisplayName"] != nil) {
        [app_dict setObject:[dict objectForKey:@"CFBundleDisplayName"] forKey:@"raw_display_name"];
    } else {
        if([dict objectForKey:@"CFBundleName"] != nil) {
            [app_dict setObject:[dict objectForKey:@"CFBundleName"] forKey:@"raw_display_name"];
        } else {
            [app_dict setValue:@NO forKey:@"valid"];
            return KERN_FAILURE;
        }
    }
    
    NSMutableArray *app_icons_list = [[NSMutableArray alloc] init];
    
    // Lookup Icon names
    if([dict objectForKey:@"CFBundleIcons"] != nil) {
        
        NSDictionary *icons_dict = [dict objectForKey:@"CFBundleIcons"];
        if([icons_dict objectForKey:@"CFBundlePrimaryIcon"] != nil) {
            
            
            NSDictionary *primary_icon_dict = [icons_dict objectForKey:@"CFBundlePrimaryIcon"];
            
            if([primary_icon_dict objectForKey:@"CFBundleIconFiles"] != nil) {
                
                for(NSString *raw_icon in [primary_icon_dict valueForKeyPath:@"CFBundleIconFiles"]){
                    
                    
                    NSString *icon = [raw_icon stringByReplacingOccurrencesOfString:@".png" withString:@""];
                    
                    // regular icon
                    if(![app_icons_list containsObject:icon]) {
                        [app_icons_list addObject:icon];
                    }
                    
                    // 2x icon
                    NSString *_2xicon = [icon stringByAppendingString:@"@2x"];
                    
                    if(![app_icons_list containsObject:_2xicon]) {
                        [app_icons_list addObject:_2xicon];
                    }
                    
                    // 3x icon
                    NSString *_3xicon = [icon stringByAppendingString:@"@3x"];
                    if(![app_icons_list containsObject:_3xicon]) {
                        [app_icons_list addObject:_3xicon];
                    }
                }
            }
        }
    }
    
    if([dict objectForKey:@"CFBundleIcons~ipad"] != nil) {
        
        NSDictionary *icons_dict = [dict objectForKey:@"CFBundleIcons~ipad"];
        if([icons_dict objectForKey:@"CFBundlePrimaryIcon"] != nil) {
            
            
            NSDictionary *primary_icon_dict = [icons_dict objectForKey:@"CFBundlePrimaryIcon"];
            
            if([primary_icon_dict objectForKey:@"CFBundleIconFiles"] != nil) {
                
                for(NSString *raw_icon in [primary_icon_dict valueForKeyPath:@"CFBundleIconFiles"]) {
                    
                    
                    NSString *icon = [raw_icon stringByReplacingOccurrencesOfString:@".png" withString:@""];
                    
                    // regular icon
                    if(![app_icons_list containsObject:icon]) {
                        [app_icons_list addObject:icon];
                    }
                    
                    // 2x icon
                    NSString *_2xicon = [icon stringByAppendingString:@"@2x"];
                    
                    if(![app_icons_list containsObject:_2xicon]) {
                        [app_icons_list addObject:_2xicon];
                    }
                    
                    // 2x~ipad icon
                    NSString *_2x_ipad_icon = [_2xicon stringByAppendingString:@"~ipad"];
                    if(![app_icons_list containsObject:_2x_ipad_icon]) {
                        [app_icons_list addObject:_2x_ipad_icon];
                    }
                    
                    // 3x icon
                    NSString *_3xicon = [icon stringByAppendingString:@"@3x"];
                    if(![app_icons_list containsObject:_3xicon]) {
                        [app_icons_list addObject:_3xicon];
                    }
                    
                    // 3x~ipad icon
                    NSString *_3x_ipad_icon = [_3xicon stringByAppendingString:@"~ipad"];
                    if(![app_icons_list containsObject:_3x_ipad_icon]) {
                        [app_icons_list addObject:_3x_ipad_icon];
                    }
                }
            }
        }
    }
    
    [app_dict setObject:app_icons_list forKey:@"icons"];
    [app_dict setObject:[dict objectForKey:@"CFBundleIdentifier"] forKey:@"identifier"];
    [app_dict setObject:[dict objectForKey:@"CFBundleExecutable"] forKey:@"executable"];
    [app_dict setValue:@YES forKey:@"valid"];
    
    return KERN_SUCCESS;
}

void list_applications_installed() {
    
    if (all_apps == NULL) {
        all_apps = [[NSMutableDictionary alloc] init];
    }
    
    read_apps_root_dir();
    
    
    // used for reading binary Info.plist files
    NSString *local_app_info_path = dir_for_path(@"app_info");
    
    for (NSString* uuid in all_apps) {
        NSMutableDictionary *app_dict = [all_apps objectForKey:uuid];
        list_child_dirs(app_dict);
        read_app_info(app_dict, local_app_info_path);
    }
}

NSString* dir_for_path(NSString *dir_name) {
    
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *final_path = [docDir stringByAppendingPathComponent:dir_name];
    
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:final_path isDirectory:&isDir])
    {
        if([fm createDirectoryAtPath:final_path withIntermediateDirectories:YES attributes:nil error:nil]) {
            // printf("[INFO]: created dir with name: %s\n", [dir_name UTF8String]);
        } else {
            // printf("[ERROR]: could not create dir with name: %s\n", [dir_name UTF8String]);
        }
    }
    
    return final_path;
}

UIImage *change_image_tint_to(UIImage *src_image, UIColor *color) {
    
    CGRect rect = CGRectMake(0, 0, src_image.size.width, src_image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, src_image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *colorized_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorized_image;
}

UIImage *get_image_for_radius(int radius, int width, int height) {
    
    printf("[INFO]: image for width and height: %d %d\n", width, height);
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *src_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *image_layer = [CALayer layer];
    image_layer.frame = CGRectMake(0, 0, src_image.size.width, src_image.size.height);
    image_layer.contents = (id) src_image.CGImage;
    
    image_layer.masksToBounds = YES;
    image_layer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(src_image.size);
    [image_layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *rounded_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rounded_image;
}

void ECID() {
    
    CFMutableDictionaryRef dict = IOServiceMatching("IOPlatformExpertDevice");
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, dict);
    
    if (service) {
        CFTypeRef ecid = IORegistryEntrySearchCFProperty(service, kIODeviceTreePlane, CFSTR("unique-chip-id"), kCFAllocatorDefault, kIORegistryIterateRecursively);
        if (ecid) {
            const UInt8 *bytes = CFDataGetBytePtr(ecid);
            UInt64* b = (UInt64*)bytes;
            CFStringRef ecidString = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%llu"),*b);

            printf("%s", [(__bridge NSString *)ecidString UTF8String]);
            CFRelease(ecid);
            IOObjectRelease(service);
        } else {
            printf("[ERROR]: Failed to locate Unique Chip ID Value.");
        }
    } else {
        printf("[ERROR]: Failed to locate platform expert device service.");
        return;
    }
}
