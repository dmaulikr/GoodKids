//
//  AddBandView.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/23.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "AddBandView.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface AddBandView()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIViewController *viewcontroller;
}
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *intro;

@end
@implementation AddBandView

- (instancetype)initWithvc:(UIViewController *)vc{
    viewcontroller=vc;
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
    [self addSubview:self.view];
}
- (IBAction)okAction:(id)sender {
    [self hiddenView];
}
- (IBAction)cancelAction:(id)sender {
    [self hiddenView];
}

-(void)showView{
    float scw=[UIScreen mainScreen].bounds.size.width;
    float adbvh=self.frame.size.height;
    float navh=viewcontroller.navigationController.navigationBar.frame.size.height;
    float stah=[[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [UIView transitionWithView:self duration:1.0 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, navh+stah, scw, adbvh);
        //            self.test.text=[NSString stringWithFormat:@"%@",self.datename.date];
        self.frame=newset;
    }completion:^(BOOL finished){
        
    }];
    
}

-(void)hiddenView{
    
    float scw=[UIScreen mainScreen].bounds.size.width;
    float adbvh=self.frame.size.height;
    
    [UIView transitionWithView:self duration:1.0 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, -adbvh, scw, adbvh);
        //
        self.frame=newset;
    }completion:^(BOOL finished){
        
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
    
//    [self presentViewController:pickerImageView animated:YES completion:nil];
    
    
}];

UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"從相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    UIImagePickerController *pickerImageView =[[UIImagePickerController alloc] init];
    pickerImageView.delegate=self;
    pickerImageView.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerImageView.mediaTypes =@[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    UIViewController *viewController = [UIViewController new];
    viewController.view = self;
    [viewController presentViewController:pickerImageView animated:YES completion:nil];
    
}];

UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"關閉" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
}];
[alertController addAction:cameraAction];
[alertController addAction:albumAction];
[alertController addAction:cancelAction];
    UIViewController *viewController = [UIViewController new];
    viewController.view = self;
[viewController presentViewController:alertController animated:YES completion:nil];

}




#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    self.imageview.image =info[UIImagePickerControllerOriginalImage];

    UIViewController *viewController = [UIViewController new];
    viewController.view = self;
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
