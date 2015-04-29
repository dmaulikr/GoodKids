//
//  ImagePickerViewController.m
//  MemoBoard2
//
//  Created by Su Shih Wen on 2015/4/14.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import "ImagePickerVC.h"
#import "ProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "API.h"

@interface ImagePickerVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *OKBtn;

@end

@implementation ImagePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *borderColor = [UIColor whiteColor];
    [self.imgView.layer setBorderColor:borderColor.CGColor];
    [self.imgView.layer setBorderWidth:10.0];
    self.imgView.layer.cornerRadius = self.imgView.frame.size.width / 2;
    self.imgView.clipsToBounds = YES;
    
    self.OKBtn.enabled = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%@", self.userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadImgAction:(id)sender {
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    
    UIImage *image = self.userInfo[@"image"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //NSDictionary *parameters = @{@"foo": @"bar"};
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"picUp", @"cmd", self.userInfo[@"account"], @"account", nil];
    [manager POST:@"login.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFormData:imageData name:@"userfile"];
        NSString *fileName = [[NSString alloc]initWithFormat:@"%@.jpg", self.userInfo[@"account"]];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"imgSuccess: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"imgError: %@", error);
    }];
    
    
}


- (IBAction)chooseImgAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新增圖片" message:@"選取方式" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //使用相機拍照
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            [self presentUIImagePickerViewWithSource:UIImagePickerControllerSourceTypeCamera];
            
            _newMedia = YES;
        }else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"此裝置沒有相機" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"打開相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([UIImagePickerController isSourceTypeAvailable:
                     UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                {
                    [self presentUIImagePickerViewWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                    _newMedia = NO;
                }
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:albumAction];
            
            [self presentViewController:alertController animated:YES completion:nil
             ];
        }
        
    }];
    //使用相簿
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            [self presentUIImagePickerViewWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            _newMedia = NO;
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)presentUIImagePickerViewWithSource:(UIImagePickerControllerSourceType)sourceType{
    
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera){
        
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        
    }else if (sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum)
    {
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        
    }
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        self.imgView.image = image;
        //add image to userInfo
        [self.userInfo setObject:image forKey:@"image"];
        self.OKBtn.enabled = YES;
        
        if (_newMedia){
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        }
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"Save failed" message:@"Failed to save image" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertcontroller addAction:okAction];
        [self presentViewController:alertcontroller animated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imgToProfileViewController"]) {
        UIViewController *target = segue.destinationViewController;
        if([target isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *profileViewController = (ProfileViewController *)target;
            
            profileViewController.userInfo = [self.userInfo mutableCopy];
        }
    }
}

@end
