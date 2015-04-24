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
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *intro;

@end
@implementation AddBandView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
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
//    [_button setBackgroundColor:[UIColor clearColor]];
//    [_button setTitle:@"" forState:UIControlStateNormal];
//    //    NSLog(@"%@",info);
    self.imageview.image =info[UIImagePickerControllerOriginalImage];
//    UIImage *img=info[UIImagePickerControllerOriginalImage];
//    _InfoArray[0]=img;
//    
//    
//
    UIViewController *viewController = [UIViewController new];
    viewController.view = self;
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
