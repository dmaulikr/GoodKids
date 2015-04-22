//
//  EditMessageVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "EditMessageVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "API.h"
@interface EditMessageVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (strong,nonatomic) NSMutableArray *InfoArray;
@end

@implementation EditMessageVC
{
    NSString *boardID;
    NSString *memoID;
    NSString *UserName;
}



-(NSString *)getNowTime{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    //    NSLog(@"The Current Time is %@",[dateFormatter stringFromDate:now]);
    NSString *nowTime=[dateFormatter stringFromDate:now];
    return nowTime;
}

#pragma mark - SQL Method
-(void)uploadImg:(UIImage *)img {
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];

    UIImage *image = img;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //NSDictionary *parameters = @{@"foo": @"bar"};
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"pictureUp", @"cmd", memoID, @"memo_id", nil];
    [manager POST:@"management.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {//[formData appendPartWithFormData:imageData name:@"userfile"];
    NSString *fileName = [[NSString alloc]initWithFormat:@"%@%@.jpg",memoID, UserName];
    [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"imgSuccess: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"imgError: %@", error);
    }];
}



-(void)uploadTitle:(NSString *)title content:(NSString *)content date:(NSString *)date{
    //使用內定值
    
//    NSString *UserName =@"oktenokis@yahoo.com.tw";
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"mngSubject", @"cmd",boardID, @"board_id",title,@"subject", content, @"content", date, @"date_time", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
         [self uploadImg:_InfoArray[0]];
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

-(void)editTitle:(NSString *)title content:(NSString *)content date:(NSString *)date{
    //使用內定值
    
    //    NSString *UserName =@"oktenokis@yahoo.com.tw";
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"updateSubject", @"cmd",memoID, @"memo_id",title,@"subject", content, @"content", date, @"date_time", nil];
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



#pragma mark - SQL Control
-(void)doneCust{
    if (self.flag==1) {
        //新增存擋
        [_messageDic setValue:_titleText.text forKey:@"title"];
        [_messageDic setValue:[self getNowTime] forKey:@"date"];
        [_messageDic setValue:_contentText.text forKey:@"content"];
        if (_InfoArray.count){
        [_messageDic setValue:_InfoArray[0] forKey:@"image"];
        }
        [self uploadTitle:_titleText.text content:_contentText.text date:[self getNowTime]];
        [self.Delegate EditMessageVC:self messageDic:_messageDic];
    }else if (_flag==2){
        //修改存擋
        [_messageDic setValue:_titleText.text forKey:@"title"];
        [_messageDic setValue:[self getNowTime] forKey:@"date"];
        [_messageDic setValue:_contentText.text forKey:@"content"];
        if (_InfoArray.count){
            [_messageDic setValue:_InfoArray[0] forKey:@"image"];
        }
        
        [self editTitle:_titleText.text content:_contentText.text date:[self getNowTime]];
        
        [self.Delegate EditMessageVC:self messageDic:_messageDic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Main
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //新增完成按鈕
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCust)];
    self.navigationItem.rightBarButtonItem=doneButton;
    //資料初始化
    _messageDic =[NSMutableDictionary new];
    _InfoArray=[NSMutableArray new];
    if (_flag==1) {
        //新增模式
        self.title=@"New Message";
        _dateText.text=[self getNowTime];
    }else if(_flag==2){
        //修改模式
        self.title=@"Edit Message";
        NSLog(@"%@",_receiveEditDic);
        if (!(_receiveEditDic[@"image"] ==nil)){
            _InfoArray[0]=_receiveEditDic[@"image"];
        }

        _titleText.text=_receiveEditDic[@"title"];
        _dateText.text=_receiveEditDic[@"date"];
        _contentText.text=_receiveEditDic[@"content"];
        if (_InfoArray.count){
            _imageView1.image=_receiveEditDic[@"image"];
        }
        
        [_button setBackgroundColor:[UIColor clearColor]];
        [_button setTitle:@"" forState:UIControlStateNormal];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    boardID=@"8";
    memoID=@"4";
    UserName=@"oktenokis@yahoo.com.tw";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)imagePickerBtn:(id)sender {
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
    [_button setBackgroundColor:[UIColor clearColor]];
    [_button setTitle:@"" forState:UIControlStateNormal];
    //    NSLog(@"%@",info);
    self.imageView1.image =info[UIImagePickerControllerOriginalImage];
    UIImage *img=info[UIImagePickerControllerOriginalImage];
    _InfoArray[0]=img;
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
