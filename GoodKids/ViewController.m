//
//  ViewController.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "ViewController.h"
#import "SWRevealViewController.h"
#import "API.h"
#import "AdminMainTVC-2.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *addBandView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//addBandView的內容物
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *introText;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController
{
    NSMutableArray *bandArray;
    NSMutableArray *originbandListArr;
    NSString *boardID;
    NSString *UserName;
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
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

-(void)deleteBand{
    
    
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"deleteBoard", @"cmd",boardID,@"board_id", nil];
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

-(void)showAdminList{
    //啟動一個hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //設定hud顯示文字
    [hud setLabelText:@"connecting"];
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"boardList", @"cmd",UserName,@"account", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        //輸出response
        bandArray =[NSMutableArray arrayWithArray:responseObject[@"api"]];
        originbandListArr = [[NSMutableArray alloc]initWithArray:bandArray];
        [self.tableview reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}





#pragma mark - Custom Method
- (void)informationReload {
    originbandListArr = [[NSMutableArray alloc]initWithArray:bandArray];
    [self.tableview reloadData];
}
#pragma mark - Main
- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;//self為何可以呼叫revealViewController?
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.searchBar.delegate=self;
    bandArray = [NSMutableArray new];
    originbandListArr = [[NSMutableArray alloc]initWithArray:bandArray];
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSDictionary *user=[userDefaults objectForKey:@"userInformation"];
    NSLog(@"%@",user);
    UserName=user[@"account"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    boardID=@"8";
    [self showAdminList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - buttonAction
- (IBAction)addBandAction:(id)sender {
    [self showView];
    }
- (IBAction)addBandImageAction:(id)sender {
    [self selectPictureMethod];
}
- (IBAction)hiddenViewAction:(id)sender {
//    [self hiddenView];
}
- (IBAction)completeAddBandAction:(id)sender {
//    [self hiddenView];
    [self uploadBandName:_nameText.text intro:_introText.text];
    [self showAdminList];
    
}

#pragma mark - buttonActionFunction
-(void)showView{
    float scw=[UIScreen mainScreen].bounds.size.width;
    float adbvh=self.addBandView.frame.size.height;
    float navh=self.navigationController.navigationBar.frame.size.height;
    float stah=[[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [UIView transitionWithView:self.addBandView duration:1.0 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, navh+stah, scw, adbvh);
        //            self.test.text=[NSString stringWithFormat:@"%@",self.datename.date];
        self.addBandView.frame=newset;
    }completion:^(BOOL finished){
        
    }];
    
}
-(void)hiddenView{
    
    float scw=[UIScreen mainScreen].bounds.size.width;
    float adbvh=self.addBandView.frame.size.height;
    
    [UIView transitionWithView:self.addBandView duration:1.0 options:UIViewAnimationOptionTransitionNone animations: ^{
        CGRect newset;
        newset =CGRectMake(0, -adbvh, scw, adbvh);
        //
        self.addBandView.frame=newset;
    }completion:^(BOOL finished){
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return bandArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryView = [self addCustAccessoryBtn];
    cell.textLabel.text= bandArray[indexPath.row][@"board_name"];
    cell.tag = [bandArray[indexPath.row][@"board_id"] integerValue];
   
    
    return cell;
}

#pragma mark - Custom Button and Method
-(UIButton *)addCustAccessoryBtn{
    UIImage *accessoryImg = [UIImage imageNamed:@"settings-25"];
    CGRect imgFrame = CGRectMake(0, 0, accessoryImg.size.width, accessoryImg.size.height);
    UIButton *custAccessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [custAccessoryBtn setFrame:imgFrame];
    [custAccessoryBtn setBackgroundImage:accessoryImg forState:UIControlStateNormal];
    [custAccessoryBtn setBackgroundColor:[UIColor clearColor]];
    [custAccessoryBtn addTarget:self action:@selector(pressAccessoryBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return custAccessoryBtn;
    
}


-(void)pressAccessoryBtn:(UIButton *)button{
    //    NSLog(@"test sucess");
    //獲得Cell：button的上一層是UITableViewCell
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    //然后使用indexPathForCell方法，就得到indexPath了~
    NSIndexPath *indexPath = [self.tableview indexPathForCell:cell];
    //  NSLog(@"%ld",(long)indexPath.row);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"一經刪除便無法復原" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //  利用NSMutableAttributedString，設定多種屬性及Range去變更alertController(局部或全部)字級、顏色，Range:“警告”為兩個字元，所以設定0~2
    NSMutableAttributedString *StringAttr = [[NSMutableAttributedString alloc]initWithString:@"警告"];
    [StringAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
    [StringAttr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
    [alertController setValue:StringAttr forKey:@"attributedTitle"];
    
    //Delete
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"刪除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSMutableAttributedString *delectstring = [[NSMutableAttributedString alloc]initWithString:@"刪除群組"];
        [delectstring addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, delectstring.length)];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@""
                                              message:@"一經刪除便無法復原"
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController setValue:delectstring forKey:@"attributedTitle"];
        
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       [bandArray removeObjectAtIndex:indexPath.row];
                                       [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                       [self deleteBand];
                                   }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }];
    //Rename
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"重新命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"重新命名"
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"群組名稱";
             textField.text=bandArray[indexPath.row][@"board_name"];
         }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"群組名稱";
             textField.text=bandArray[indexPath.row][@"intro"];
         }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       UITextField *name = alertController.textFields.firstObject;
                                       UITextField *intro = alertController.textFields.lastObject;
                                       NSDictionary *dic =@{@"board_name":name.text,
                                                            @"intro":intro.text};
                                       bandArray[indexPath.row]=dic;
                                       [self renameBandName:name.text intro:intro.text];
                                       [self informationReload];
                                       
                                   }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

        
    }];
    //Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"關閉" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:renameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AdminMainTVC_2 *tvc=segue.destinationViewController;
    NSIndexPath *indexPath=self.tableview.indexPathForSelectedRow;
    tvc.reveiceboardID=bandArray[indexPath.row][@"board_id"];
}



-(void)addBandAlertView{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"創造群組"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString (@"群組名稱", nil);
     }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString (@"群組簡介", nil);
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *name = alertController.textFields.firstObject;
                                   UITextField *intro = alertController.textFields.lastObject;
                                   
                                   [self uploadBandName:name.text intro:intro.text];
                                   [self showAdminList];
                               }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    

}

#pragma mark PictureMethod
-(void)selectPictureMethod{
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
    self.imageView.image =info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
