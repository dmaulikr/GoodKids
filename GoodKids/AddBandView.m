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


@interface AddBandView()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIViewController *viewcontroller;
    UIImage *image;
    NSString *UserName;
    NSString *boardID;
}
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *intro;

@end
@implementation AddBandView
#pragma mark - init
- (instancetype)initWithvc:(UIViewController *)vc name:(NSString *)name{
    
    viewcontroller=vc;
    UserName=name;
    float vch=vc.view.bounds.size.height;
    float vcw=vc.view.bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, -vch/2, vcw, 288)];
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup{
    
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [nib instantiateWithOwner:self options:nil];

    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.bounds;
    [self addSubview:visualEffectView];
    
    UIColor *borderColor = [UIColor whiteColor];
    [self.imageview.layer setBorderColor:borderColor.CGColor];
    [self.imageview.layer setBorderWidth:2.0];
    self.imageview.layer.cornerRadius = self.imageview.frame.size.width / 2;
    self.imageview.clipsToBounds = YES;
    self.imageview.image=[UIImage imageNamed:@"loadCircle"];
    [self addSubview:self.view];
    
}

#pragma mark - buttonAction
- (IBAction)okAction:(id)sender {
    if (self.flag==1) {
        //新增
        if (_name.text.length>=2) {
            [self uploadBandName:_name.text intro:_intro.text];
            [self hiddenView];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadList" object:nil];
        }else{
            [self alertWithTitle:@"社團名稱錯誤" message:@"請輸入一個字以上,最多二十字"];
        }
    }else{
        //修改
        if (_name.text.length>=2) {
        [self renameBandName:_name.text intro:_intro.text];
        [self hiddenView];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadList" object:nil];
        }else{
            [self alertWithTitle:@"社團名稱錯誤" message:@"請輸入一個字以上,最多二十字"];
        }
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
    
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, navh+20, scw, adbvh);
        
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


#pragma mark - 修改
-(void)setOldValue:(NSDictionary *)dic img:(UIImage *)img{
    
        _imageview.image=img;
        image=img;
    
    if (!(dic[@"board_name"] ==nil)){
        _name.text=dic[@"board_name"];
    }
    if (!(dic[@"intro"] ==nil)){
        _intro.text=dic[@"intro"];
    }
    if (!(dic[@"board_id"] ==nil)){
        boardID=dic[@"board_id"];
    }
    
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
        [self getboardID:boardName];
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

-(void)renameBandName:(NSString *)boardName intro:(NSString *)intro{
    
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"updateBoard", @"cmd",boardID,@"board_id", boardName, @"boardName", intro, @"intro", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        
        if (!(image==nil)) {
            [self uploadImg:image];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadList" object:nil];
        }
        
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}



-(void)getboardID:(NSString *)boardName{
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"getboardID", @"cmd",UserName, @"account", boardName, @"board_name", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        //輸出response
        boardID=responseObject[@"api"][@"max(board_id)"];
        if (!(image==nil)) {
            [self uploadImg:image];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadList" object:nil];
        }
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}


-(void)uploadImg:(UIImage *)img {
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    
    NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //NSDictionary *parameters = @{@"foo": @"bar"};
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"BoardPicUp", @"cmd", boardID, @"board_id", nil];
    [manager POST:@"management.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {//[formData appendPartWithFormData:imageData name:@"userfile"];
        NSString *fileName = [[NSString alloc]initWithFormat:@"%@.jpg",boardID];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reLoadList" object:nil];
        NSLog(@"imgSuccess: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"imgError: %@", error);
    }];
}



#pragma mark --addimage
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

#pragma mark - UIAlerViewController:alert

- (void) alertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [viewcontroller presentViewController:alertController animated:YES completion:nil];
}
@end
