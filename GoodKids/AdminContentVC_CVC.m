//
//  AdminContentVC_CVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/26.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "AdminContentVC_CVC.h"
#import "FollowContentCVCell.h"
#import "EditMessageVC.h"
#import "ShowMessageVC.h"
#import "API.h"
#import "UIImageView+AFNetworking.h"
#import "JDFPeekabooCoordinator.h"
@interface AdminContentVC_CVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;
@end

@implementation AdminContentVC_CVC
{
    NSMutableArray *messageArray;
    NSString *boardID;
    BOOL tag;
}

#pragma mark - SQL Method
-(void)deleteMemo:(NSString *)memoID{
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"deleteSubject", @"cmd",memoID,@"memo_id", nil];
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

-(void)showMemo{
    //啟動一個hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //設定hud顯示文字
    [hud setLabelText:@"connecting"];
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"showSubject", @"cmd",boardID ,@"board_id", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        messageArray =[NSMutableArray arrayWithArray:responseObject[@"api"]];
        [self.collectionView reloadData];
        
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

#pragma mark - ADD AND Delegate
- (IBAction)addMessage:(id)sender {
    EditMessageVC *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"customView"];
//    vc.Delegate=self;
    vc.flag=1;
    vc.reveiceboardID = boardID;
    [self.navigationController pushViewController:vc animated:YES];
}

//-(void)EditMessageVC:(EditMessageVC *)EditMessageVC messageDic:(NSDictionary *)message{
//    
//    [messageArray addObject:message];
//    NSLog(@"%@",messageArray);
//    [self.collectionView reloadData];
//}
#pragma mark - Main
- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollCoordinator = [[JDFPeekabooCoordinator alloc] init];
    self.scrollCoordinator.scrollView = self.collectionView;
    self.scrollCoordinator.topView = self.navigationController.navigationBar;
    self.scrollCoordinator.bottomView = self.tabBarController.tabBar;
    self.scrollCoordinator.containingView = self.tabBarController.view;
    self.scrollCoordinator.topViewMinimisedHeight = 20.0f;
    
    messageArray=[NSMutableArray new];

    tag = 1;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    self.title=_reveiceboardName;
    boardID=_reveiceboardID;

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.scrollCoordinator enable];
    NSLog(@"%@",messageArray);
    
    boardID=_reveiceboardID;
    [self showMemo];
    NSLog(@"%@",boardID);
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scrollCoordinator disable];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return messageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FollowContentCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"followContentCell" forIndexPath:indexPath];
    
    // Configure the cell
    NSLog(@"陣列內容:%@",messageArray);
    cell.titleLabel.text = messageArray[indexPath.row][@"subject"];
    cell.contentLabel.text = messageArray[indexPath.row][@"content"];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ServerApiURL,messageArray[indexPath.row][@"picture"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Rectangle"]];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ShowMessageVC *vc= [segue destinationViewController];
    NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
    NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
    vc.receiveDic=messageArray[indexPath.row];

    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
}


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
    FollowContentCVCell *cell = (FollowContentCVCell *)button.superview;
    //然后使用indexPathForCell方法，就得到indexPath了~
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    //  NSLog(@"%ld",(long)indexPath.row);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"一經刪除便無法復原" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //  利用NSMutableAttributedString，設定多種屬性及Range去變更alertController(局部或全部)字級、顏色，Range:“警告”為兩個字元，所以設定0~2
    NSMutableAttributedString *StringAttr = [[NSMutableAttributedString alloc]initWithString:@"警告"];
    [StringAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
    [StringAttr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
    [alertController setValue:StringAttr forKey:@"attributedTitle"];
    
    //Delete
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"刪除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSMutableAttributedString *delectstring = [[NSMutableAttributedString alloc]initWithString:@"刪除文章"];
        [delectstring addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, delectstring.length)];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@""
                                              message:@"一經刪除便無法復原"
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alertController setValue:delectstring forKey:@"attributedTitle"];
        
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       [self deleteMemo:messageArray[indexPath.row][@"memo_id"]];
                                       [messageArray removeObjectAtIndex:indexPath.row];
                                       
//                                       [self.collectionView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UIContentSizeCategorySmall];
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
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size;
    if (tag == 0) {
        size = CGSizeMake(self.view.bounds.size.width/2-1 , self.view.bounds.size.width/2-5);
    }else{

//        size = CGSizeMake(self.view.bounds.size.width , self.view.bounds.size.height/4);
        size = CGSizeMake(self.view.bounds.size.width , 148);
    }
    
    return size;
}


#pragma mark - gesture

-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    if (pinchGestureRecognizer.scale > 1.5) {
        tag = 0;
        [self.collectionView reloadData];
    }else if(pinchGestureRecognizer.scale< 0.8){
        tag = 1;
        [self.collectionView reloadData];
    }
}

@end
