//
//  ShareUtility.m
//  GoodKids
//
//  Created by Su Shih Wen on 2015/4/21.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "ShareUtility.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@implementation ShareUtility{
    NSString *_title;
    NSString *_content;
    UIImage *_photo;
    NSDictionary *_parms;
    NSString *_graphPath;
}

- (instancetype)initWithTitle:(NSString *)Title content:(NSString *)content photo:(UIImage *)photo{
    
    if (self = [super init]) {
        _title = [Title copy];
        _content = [content copy];
        if (!photo) {
            _photo = nil;
            _parms = @{ @"message" : _title};
            _graphPath = @"me/feed";
        }else{
            _photo = [photo copy];
            _parms = @{ @"message" : _title, @"picture" : _photo};
            _graphPath = @"me/photos";
        }
    }
    
    return self;
}

- (void)start{
    [self _postOpenGraphAction];
    if ([FBSDKAccessToken currentAccessToken]) {
        [[FBSDKLoginManager alloc]logOut];
    }
    
}

- (void)_postOpenGraphAction {
    NSString *const publish_actions = @"publish_actions";
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:publish_actions]) {
        NSLog(@"FBSDKAccessToken hasGranted publish_actions");
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:_graphPath
          parameters: _parms
          HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
         }];
    } else {
        [[[FBSDKLoginManager alloc] init]
         logInWithPublishPermissions:@[publish_actions]
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if ([result.grantedPermissions containsObject:publish_actions]) {
                 
                 [[[FBSDKGraphRequest alloc]
                   initWithGraphPath:_graphPath
                   parameters: _parms
                   HTTPMethod:@"POST"]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      
                      if (!error) {
                          NSLog(@"Post id:%@", result[@"id"]);
                      }
                  }];
                 
                 [[FBSDKLoginManager alloc]logOut];
             } else {
                 // This would be a nice place to tell the user why publishing
                 // is valuable.
                 NSLog(@"NO grantedPermissions containsObject publish_actions");
             }
         }];
    }
}

@end
