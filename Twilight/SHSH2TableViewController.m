//
//  SHSH2TableViewController.m
//  Twilight
//
//  Created by Joseph Shenton on 10/6/18.
//  Copyright © 2018 JJS Digital. All rights reserved.
//

#import "SHSH2TableViewController.h"

@interface SHSH2TableViewController ()

@end

@implementation SHSH2TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

    
- (void)sendRequestRequest:(id)sender {
        // Request (POST https://tsssaver.1conan.com/app.php)
        
        // Create manager
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        // Create request
        NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://tsssaver.1conan.com/app.php" parameters:nil error:NULL];
        
        // Form URL-Encoded Body
        NSDictionary* bodyParameters = @{
                                         @"deviceID":@"iPhone8,4",
                                         @"ecid":@"4913228056185",
                                         @"boardConfig":@"N69uAP",
                                         };
        
        NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://tsssaver.1conan.com/app.php" parameters:bodyParameters error:NULL];
        
        // Add Headers
        [request setValue:@"Twilight/1.0" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        // Fetch Request
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                 NSLog(@"HTTP Response Status Code: %ld", [operation.response statusCode]);
                                                                                 NSLog(@"HTTP Response Body: %@", responseObject);
                                                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                 NSLog(@"HTTP Request failed: %@", error);
                                                                             }];
        
        [manager.operationQueue addOperation:operation];
    }
    
    


@end
