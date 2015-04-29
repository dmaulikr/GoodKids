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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIImageView+AFNetworking.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "custButton.h"

@interface ProfileVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSMutableDictionary *userInfo;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *FBPicture;

@property (strong, nonatomic) IBOutlet custButton *upimgBtn;
@property (strong, nonatomic) IBOutlet custButton *changeBtn;

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
        
        [self.FBPicture.layer setBorderColor:borderColor.CGColor];
        [self.FBPicture.layer setBorderWidth:10.0];
        self.FBPicture.layer.cornerRadius = self.FBPicture.frame.size.width / 2;
        self.FBPicture.clipsToBounds = YES;

    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *temp = [userDefaults dictionaryForKey:@"userInformation"];
    userInfo = [NSMutableDictionary dictionaryWithDictionary:temp];
    //NSLog(@"userInfo:%@", userInfo);
    
    self.nicknameLabel.text = [NSString stringWithFormat:@"嗨！%@",userInfo[@"nickname"]];
    self.accountLabel.text = userInfo[@"account"];
    
    if (![self.imgView.image isKindOfClass:[UIImage class]]) {
        NSString *imgUrl = [NSString stringWithFormat:@"%@img/%@.jpg", ServerApiURL, userInfo[@"account"]];
        
        [self.imgView setImageWithURL:[NSURL URLWithString:imgUrl]];
    }
    if ([FBSDKAccessToken currentAccessToken]) {
        self.FBPicture.profileID = @"me";
        [_upimgBtn setHidden:YES];
        [_changeBtn setHidden:YES];
        
    }else{
        self.FBPicture.hidden = YES;
    }
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
        self.nicknameLabel.text = [NSString stringWithFormat:@"嗨！%@",nickname.text];
        userInfo[@"nickname"] = nickname.text;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userInfo forKey:@"userInformation"];
        
        [self updateNickname:nickname.text];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction: okAction];
    okAction.enabled = NO;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateNickname: (NSString*)nickname{
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"updateNickname", @"cmd", userInfo[@"account"], @"account", nickname, @"nickname", nil];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:@"login.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *apiResponse = [responseObject objectForKey:@"api"];
        NSLog(@"apiResponse: %@", apiResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
    }];
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
    [self selectImg];
}
//上傳圖片
- (void)uploadImg: (UIImage *)image  {
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"picUp", @"cmd", userInfo[@"account"], @"account", nil];
    [manager POST:@"login.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFormData:imageData name:@"userfile"];
        NSString *fileName = [[NSString alloc]initWithFormat:@"%@.jpg", userInfo[@"account"]];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"imgSuccess: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"imgError: %@", error);
    }];
    
}

- (void) selectImg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新增圖片" message:@"選取方式" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *pickerImageView =[[UIImagePickerController alloc] init];
        pickerImageView.delegate=self;
        //如果要使用相機要先測試iDevice是否有相機
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            pickerImageView.sourceType=UIImagePickerControllerSourceTypeCamera;
        }else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
            pickerImageView.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
        }
        
        pickerImageView.mediaTypes =@[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        
        [self presentViewController:pickerImageView animated:YES completion:nil];
        
        
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"從相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *pickerImageView =[[UIImagePickerController alloc] init];
        pickerImageView.delegate=self;
        pickerImageView.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImageView.mediaTypes =@[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        
        [self presentViewController:pickerImageView animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"關閉" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imgView setImage:info[UIImagePickerControllerOriginalImage]];
    [self uploadImg: info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
