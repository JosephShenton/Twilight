//
//  utilities.h
//  Twilight
//
//  Created by Joseph Shenton on 8/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define INSTALLED_APPS_PATH "/private/var/containers/Bundle/Application"
#define APPS_DATA_PATH "/private/var/mobile/Containers/Data/Application"

#define INSTALL_UID                                    33
#define INSTALL_GID                                    33

#define ROOT_UID                                    0
#define WHEEL_GID                                   0

#define MOBILE_UID                                    501
#define MOBILE_GID                                    501

NS_ASSUME_NONNULL_BEGIN

typedef struct app_dir {
    struct app_dir* next;
    char root_path[150];
    char app_path[190];
    char jdylib_path[210];
    char *display_name;
    char *identifier;
    char *executable;
    boolean_t valid;
    
} app_dir_t;

@interface utilities : NSObject
void read_apps_data_dir(void);
void list_applications_installed(void);
NSString* carrierName(void);
UIView* statusBarArea(void);
size_t kread(uint64_t where, void *p, size_t size);
uint64_t kread_uint64(uint64_t where);
uint32_t kread_uint32(uint64_t where);
size_t kwrite(uint64_t where, const void *p, size_t size);
size_t kwrite_uint64(uint64_t where, uint64_t value);
size_t kwrite_uint32(uint64_t where, uint32_t value);
NSString* getPathForDir(NSString *dir_name);
kern_return_t set_file_permissions (char * destination_path, int uid, int gid, int perm_num, bool silent);
kern_return_t copy_file(char * source_path, char * destination_path, int uid, int gid, int num_perm, bool silent);
NSString* dir_for_path(NSString *dir_name);
pid_t pid_for_name(char *name);
UIImage *change_image_tint_to(UIImage *src_image, UIColor *color);
UIImage *get_image_for_radius(int radius, int width, int height);
void kill_springboard(int);
void invalidate_icon_cache(char *);
void rebootDevice(void);
void respringDevice(void);
@end

NS_ASSUME_NONNULL_END
