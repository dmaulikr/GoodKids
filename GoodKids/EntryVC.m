//
//  ViewController.m
//  MemoBoard2
//
//  Created by Su Shih Wen on 2015/4/13.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import "EntryVC.h"
#import "API.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "ProfileViewController.h"

@interface EntryVC ()<FBSDKLoginButtonDelegate>{
    NSMutableDictionary *userInfo;
}

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation EntryVC

#pragma mark - Object lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //設定背景GIF
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GoodKidsGif" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    UIWebView *webViewBG = [[UIWebView alloc]initWithFrame:self.view.frame];
    [webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webViewBG.userInteractionEnabled = NO;
    [webViewBG setScalesPageToFit:YES];
    [self.view addSubview:webViewBG];
    [self.view sendSubviewToBack:webViewBG];
    
    //按鈕圓角
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeProfileChange:) name:FBSDKProfileDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeTokenChange:) name:FBSDKAccessTokenDidChangeNotification object:nil];
    self.loginButton.readPermissions = @[@"public_profile", @"email"];
    
    // If there's already a cached token, read the profile information.
    if ([FBSDKAccessToken currentAccessToken]) {
        [self observeProfileChange:nil];
    }
    
    [self checkNetworkConnection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - check 網路連線

- (BOOL)checkNetworkConnection {
    //check 網路連線
    Reachability *reachability = [Reachability reachabilityWithHostName:hostName];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        NSLog(@"OK");
        return YES;
    }else{
        [self alertWithTitle:@"連線發生錯誤" message:@"網路無法連線，請檢查網路連\n或是稍後再試"];
        return NO;
    }
}

#pragma mark - UIAlerViewController:alert

- (void) alertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error) {
        NSLog(@"Unexpected login error: %@", error);
        NSString *alertMessage = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?: @"There was a problem logging in. Please try again later.";
        NSString *alertTitle = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops";
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
}

#pragma mark - Observations

- (void)observeProfileChange:(NSNotification *)notfication {
    
    if ([FBSDKAccessToken currentAccessToken]  && [self checkNetworkConnection]) {
        //public_profile
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 //profile view
                 
                 if ([self checkNetworkConnection]) {
                     //啟動一個hud
                     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     //設定hud顯示文字
                     [hud setLabelText:@"FB connecting"];
                     //取的account及password
                     NSString *nickname = result[@"name"];
                     NSString *account;
                     if (result[@"email"]) {
                         account = result[@"email"];
                     }else{
                         account = result[@"id"];
                     }
                     userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys: result[@"name"], @"nickname", account, @"account", nil];
                     [self performSegueWithIdentifier:@"entryToProfileViewController" sender:self];
                     //已登入
                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                     [userDefaults setBool:YES forKey:@"isLogin"];
                     [userDefaults synchronize];
                     //設定伺服器的根目錄
                     NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
                     //設定post內容
                     NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"FBLogin", @"cmd", account, @"fbId", nickname, @"nickname", nil];
                     //產生控制request物件
                     AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
                     //accpt text/html
                     manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
                     //POST
                     [manager POST:@"login.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         //request成功之後要做的事
                         //輸出response
                         NSLog(@"response: %@", responseObject);
                         NSDictionary *json = responseObject;
                         //取出api的key值，並輸出
                         NSDictionary *apiResponse = [json objectForKey:@"api"];
                         NSLog(@"apiResponse: %@", apiResponse);
                         //判斷signIn的key值是不是等於success
                         NSString *result = [apiResponse objectForKey:@"FBsingUp"];
                         NSLog(@"result %@", result);
                         if ([result isEqualToString:@"success"]) {
                             //註冊成功
                             NSLog(@"FBRegister: %@", result);
                         }else{
                             //註冊失敗
                             NSLog(@"FBRegister: %@", apiResponse[@"FBsignUp"]);
                         }
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         //request失敗之後要做的事
                         NSLog(@"request error: %@", error);
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     }];
                 }
             }
         }];
    }
}

- (void)observeTokenChange:(NSNotification *)notfication {
    if (![FBSDKAccessToken currentAccessToken]  && [self checkNetworkConnection]) {
        NSLog(@"not login");
    } else {
        [self observeProfileChange:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"entryToProfileViewController"]) {
        UIViewController *target = segue.destinationViewController;
        if([target isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *proViewController = (ProfileViewController *)target;
            proViewController.userInfo = [userInfo mutableCopy];
        }
    }
}

#pragma mark - Actions

- (IBAction)showLogin:(UIStoryboardSegue *)segue
{
    // This method exists in order to create an unwind segue to this controller.
}
@end
