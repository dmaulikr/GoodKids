//
//  ProfileViewController.m
//  MemoBoard2
//
//  Created by Su Shih Wen on 2015/4/13.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "API.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SWRevealViewController.h"
@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgVIew;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *FBPicture;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *borderColor = [UIColor whiteColor];
    [self.imgVIew.layer setBorderColor:borderColor.CGColor];
    [self.imgVIew.layer setBorderWidth:10.0];
    self.imgVIew.layer.cornerRadius = self.imgVIew.frame.size.width / 2;
    self.imgVIew.clipsToBounds = YES;
    
    [self.FBPicture.layer setBorderColor:borderColor.CGColor];
    [self.FBPicture.layer setBorderWidth:10.0];
    self.FBPicture.layer.cornerRadius = self.FBPicture.frame.size.width / 2;
    self.FBPicture.clipsToBounds = YES;

    self.imgVIew.image = [UIImage new];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"profile: %@", self.userInfo);
    NSString *hi = [NSString stringWithFormat:@"嗨! "];
    self.nameLabel.text = [hi stringByAppendingString:self.userInfo[@"nickname"]];
    
    if (self.userInfo[@"image"] != NULL && [self.userInfo[@"image"] isKindOfClass: [UIImage class]] ) {
        self.imgVIew.image = self.userInfo[@"image"];
        self.userInfo[@"image"] = [NSString stringWithFormat:@"%@img/%@.jpg", ServerApiURL, self.userInfo[@"account"]];
    }else{
        NSString *imgUrl = [NSString stringWithFormat:@"%@img/%@.jpg", ServerApiURL, self.userInfo[@"account"]];
        //NSLog(@"imgUrl: %@", imgUrl);
        [self.imgVIew setImageWithURL:[NSURL URLWithString:imgUrl]];
    }
    
    if ([FBSDKAccessToken currentAccessToken]) {
        self.FBPicture.profileID = @"me";
    }else{
        self.FBPicture.hidden = YES;
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //已登入
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLogin = [userDefaults boolForKey:@"isLogin"];
    NSLog(@"isLogin: %d", isLogin);
    [userDefaults setObject:self.userInfo forKey:@"userInformation"];
    
    if (isLogin) {
        sleep(1.0);
        [self performSegueWithIdentifier:@"1to2" sender:self];
    }else{
        if ([FBSDKAccessToken currentAccessToken]) {
            [[FBSDKLoginManager alloc]logOut];
        }
        
        [self performSegueWithIdentifier:@"backLogin" sender:nil];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
