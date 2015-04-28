//
//  ProfileVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "ProfileVC.h"
#import "SWRevealViewController.h"
#import "API.h"
#import "UIImageView+AFNetworking.h"
@interface ProfileVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;


@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;//self為何可以呼叫revealViewController?
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
        UIColor *borderColor = [UIColor whiteColor];
        [self.imgView.layer setBorderColor:borderColor.CGColor];
        [self.imgView.layer setBorderWidth:10.0];
        self.imgView.layer.cornerRadius = self.imgView.frame.size.width / 2;
        self.imgView.clipsToBounds = YES;

    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [userDefaults dictionaryForKey:@"userInformation"];
    NSLog(@"userInfo:%@", userInfo);
    
    self.nicknameLabel.text = userInfo[@"nickname"];
    self.accountLabel.text = userInfo[@"account"];
    NSString *imgUrl = [NSString stringWithFormat:@"%@img/%@.jpg", ServerApiURL, userInfo[@"account"]];
    [self.imgView setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeInfoAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改個人資料" message:@"更改您的暱稱" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"暱稱";
        [textField addTarget:self
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *nickname = alertController.textFields.firstObject;
        self.nicknameLabel.text = nickname.text;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction: okAction];
    okAction.enabled = NO;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *nickname = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = nickname.text.length >= 2;
    }
}

- (IBAction)upImgAction:(id)sender {
    
    
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
