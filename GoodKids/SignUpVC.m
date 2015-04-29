//
//  SignUpViewController.m
//  MemoBoard2
//
//  Created by Su Shih Wen on 2015/4/13.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import "SignUpVC.h"

#import "ImagePickerVC.h"
#import "API.h"

@interface SignUpVC ()

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTF;

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 基本註冊

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

- (BOOL)validateNickname:(NSString *)nickname{
    if (nickname.length <2) {
        [self alertWithTitle:@"暱稱格式錯誤" message:@"請輸入至少兩個字元"];
    }
    return nickname.length>=2;
}

- (IBAction)signUpAction:(id)sender {
    //將鍵盤收回
    [self.accountTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.nicknameTF resignFirstResponder];
    //判斷基本認證結果
    if ([self validateAccount:self.accountTF.text] && [self validatePassword:self.passwordTF.text] && [self validateNickname:self.nicknameTF.text] && [self checkNetworkConnection]) {
        
        //啟動一個hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //設定hud顯示文字
        [hud setLabelText:@"connecting"];
        //取得account及password及nickname
        NSString *account = self.accountTF.text;
        NSString *password = self.passwordTF.text;
        NSString *nickname = self.nicknameTF.text;
        //設定伺服器的根目錄
        NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
        //設定post內容
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"signUp", @"cmd", account, @"account", password, @"password", nickname, @"nickname", nil];
        
        NSLog(@"params(sign up):%@", params);
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
            //判斷signUp的key值是不是等於success
            NSString *result = [apiResponse objectForKey:@"signUp"];
            //NSLog(@"result %@", result);
            if ([result isEqualToString:@"success"]) {
                [self sendMail];
                //顯示註冊成功
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"恭喜!" message:@"帳號註冊成功！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //選擇大頭貼
                    [self performSegueWithIdentifier:@"toImagePickerVIewController" sender:sender];
                }];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                //顯示註冊失敗
                [self alertWithTitle:@"註冊發生錯誤！" message:@"此帳號已有人註冊，請再重試一次～"];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //request失敗之後要做的事
            NSLog(@"request error: %@", error);
            [self alertWithTitle:@"連線失敗" message:@"請確認您的網路連線，並稍後重試！"];
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

#pragma mark - send mail
-(void)sendMail{
    
    NSString *account = self.accountTF.text;
    NSString *password = self.passwordTF.text;
    NSString *nickname = self.nicknameTF.text;
    //設定伺服器的根目錄
    NSURL *hostRootURL =[NSURL URLWithString:@"http://localhost/memoBoard/"];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:account, @"account", password, @"password", nickname, @"nickname", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"webSendMail.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toImagePickerVIewController"]) {
        UIViewController *target = segue.destinationViewController;
        //        if ([target isKindOfClass:[UINavigationController class]]) {
        //            target = [[(UINavigationController *)target viewControllers] lastObject];
        //        }
        if([target isKindOfClass:[ImagePickerVC class]]) {
            ImagePickerVC *imgViewController = (ImagePickerVC *)target;
            imgViewController.userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys: self.nicknameTF.text, @"nickname", self.accountTF.text, @"account", nil];
            
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
