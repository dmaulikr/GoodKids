//
//  LoginViewController.m
//  MemoBoard2
//
//  Created by Su Shih Wen on 2015/4/13.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import "LoginVC.h"
#import "API.h"

#import "ProfileViewController.h"

@interface LoginVC (){
    NSMutableDictionary *userInfo;
}

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults stringForKey:@"lastAccount"]){
        self.accountTF.text = [userDefaults stringForKey:@"lastAccount"];
    }else{
        NSLog(@"no last account");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 基本登入

//簡單帳號密碼認證
- (BOOL)validateAccount:(NSString *)account {
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}";
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:account]) {
        [self alertWithTitle:@"帳號格式錯誤" message:@"請輸入您的Email"];
    }
    return [predicate evaluateWithObject:account];
}

- (BOOL)validatePassword:(NSString *)password{
    NSString *regex = @"[A-Z0-9a-z]{6,18}";
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:password]) {
        [self alertWithTitle:@"密碼格式錯誤" message:@"請輸入6-18數字或英文"];
    }
    return [predicate evaluateWithObject:password];
}

- (IBAction)loginAction:(id)sender {
    //將鍵盤收回
    [self.accountTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    //判斷基本認證結果
    if ([self validateAccount:self.accountTF.text] && [self validatePassword:self.passwordTF.text] && [self checkNetworkConnection]) {
        //啟動一個hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //設定hud顯示文字
        [hud setLabelText:@"connecting"];
        //取的account及password
        NSString *account = self.accountTF.text;
        NSString *password = self.passwordTF.text;
        //設定伺服器的根目錄
        NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
        //設定post內容
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"signIn", @"cmd", account, @"account", password, @"password", nil];
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
            NSString *result = [apiResponse objectForKey:@"signIn"];
            NSLog(@"result %@", result);
            if ([result isEqualToString:@"success"]) {
                //登入成功，進入下個view
                userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys: apiResponse[@"nickname"], @"nickname", self.accountTF.text, @"account", nil];
                [self performSegueWithIdentifier:@"loginToProfileViewController" sender:sender];
            }else{
                //顯示登入失敗
                [self alertWithTitle:@"帳號或密碼錯誤" message:@"您的帳號或密碼錯誤，請重新輸入"];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //request失敗之後要做的事
            NSLog(@"request error: %@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else{
        //基本認證失敗
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginToProfileViewController"]) {
        UIViewController *target = segue.destinationViewController;
        if([target isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *proViewController = (ProfileViewController *)target;
            proViewController.userInfo = [userInfo mutableCopy];
            
            //已登入
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"isLogin"];
            [userDefaults setObject:self.accountTF.text forKey:@"lastAccount"];
            [userDefaults synchronize];
        }
    }
}
- (IBAction)previousButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
