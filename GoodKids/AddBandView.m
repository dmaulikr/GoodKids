//
//  AddBandView.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/23.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "AddBandView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "API.h"
#import <CoreImage/CoreImage.h>
#import "AMBlurView.h"
@interface AddBandView()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIViewController *viewcontroller;
    UIImage *image;
    NSString *UserName;
}
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *intro;

@end
@implementation AddBandView

- (instancetype)initWithvc:(UIViewController *)vc name:(NSString *)name{
    viewcontroller=vc;
    UserName=name;
    float vch=vc.view.bounds.size.height;
    float vcw=vc.view.bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, -vch/2, vcw, vch/2)];
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup{
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    
    float vch=viewcontroller.view.bounds.size.height;
    float vcw=viewcontroller.view.bounds.size.width;
    
    AMBlurView *blurView = [AMBlurView new];
    [blurView setFrame:CGRectMake(0,0,vcw, vch/2)];
    [blurView setBlurTintColor:nil];
    
    [self addSubview:blurView];
    
    [self addSubview:self.view];
}
- (IBAction)okAction:(id)sender {
    if (self.flag==1) {
        [self uploadBandName:_name.text intro:_intro.text];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadList" object:nil];
        [self hiddenView];
    }else{
        
    }
    
    

}
- (IBAction)cancelAction:(id)sender {
    [self hiddenView];
}



#pragma mark - buttonActionFunction

-(void)showView{
    float scw=[UIScreen mainScreen].bounds.size.width;
    float adbvh=self.frame.size.height;
    float navh=viewcontroller.navigationController.navigationBar.frame.size.height;
//    float stah=[[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, navh, scw, adbvh);
        
        self.frame=newset;
    }completion:^(BOOL finished){
        
    }];
    
}

-(void)hiddenView{
    
    float scw=[UIScreen mainScreen].bounds.size.width;
    float adbvh=self.frame.size.height;
    
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, -adbvh, scw, adbvh);
        //
        self.frame=newset;
    }completion:^(BOOL finished){
        
    }];
}

#pragma mark - SQL Method

-(void)uploadBandName:(NSString *)boardName intro:(NSString *)intro{
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"mngBoard", @"cmd",UserName,@"account", boardName, @"boardName", intro, @"intro", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}




- (IBAction)addimageAction:(id)sender {
    
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
        
        [viewcontroller presentViewController:pickerImageView animated:YES completion:nil];
        
        
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"從相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *pickerImageView =[[UIImagePickerController alloc] init];
        pickerImageView.delegate=self;
        pickerImageView.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImageView.mediaTypes =@[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        
        [viewcontroller presentViewController:pickerImageView animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"關閉" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [viewcontroller presentViewController:alertController animated:YES completion:nil];
    
}




#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    self.imageview.image =info[UIImagePickerControllerOriginalImage];
    image=info[UIImagePickerControllerOriginalImage];
    [viewcontroller dismissViewControllerAnimated:YES completion:nil];
    
}

@end
