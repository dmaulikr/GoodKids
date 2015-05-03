//
//  SearchTVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "SearchTVC.h"
#import "SWRevealViewController.h"
#import "API.h"
#import "Searcher.h"
#import "MyCell.h"
#import "UIImageView+AFNetworking.h"
#import "JDFPeekabooCoordinator.h"
@interface SearchTVC ()
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;
@end

@implementation SearchTVC
{
    NSMutableArray *bandArray;
    NSInteger *buttonflag;
    NSMutableArray *test;
    NSString *UserName;
    Searcher *searcher;
    NSMutableArray *numberArray;
}


-(NSString *)getNowTime{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *nowTime=[dateFormatter stringFromDate:now];
    return nowTime;
}

#pragma mark - SQL Method

-(void)showUnfollow{
    //啟動一個hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //設定hud顯示文字
    [hud setLabelText:@"connecting"];
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"showunfollow", @"cmd",UserName,@"account", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事

        bandArray =[[NSMutableArray arrayWithArray:responseObject[@"api"]] mutableCopy];
        searcher = [[Searcher alloc] searchWithArr:bandArray searchBar:self.searchBar tableview:self.tableView predicateString:@"board_name contains[c] %@"];
        
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //輸出response
        NSLog(@"response: %@", responseObject[@"api"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}


-(void)clickToFollow:(NSString *)boardID boardname:(NSString *)boardName{
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"follow", @"cmd",UserName,@"account",boardID,@"board_id",boardName,@"boardName",[self getNowTime],@"leftTime", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        [self showUnfollow];
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

-(void)clickTounFollow:(NSString *)boardID{
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"unFollow", @"cmd",UserName,@"account",boardID,@"board_id",nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        [self showUnfollow];
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

#pragma mark - Main

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *blueColour = [UIColor colorWithRed:0.248 green:0.753 blue:0.857 alpha:1.000];
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBar.barTintColor = blueColour; //改變Bar顏色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //改變Bar Item的顏色
    self.tabBarController.tabBar.barTintColor = blueColour;
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    self.scrollCoordinator = [[JDFPeekabooCoordinator alloc] init];
    self.scrollCoordinator.scrollView = self.tableView;
    self.scrollCoordinator.topView = self.navigationController.navigationBar;
    self.scrollCoordinator.bottomView = self.tabBarController.tabBar;
    self.scrollCoordinator.containingView = self.tabBarController.view;
    self.scrollCoordinator.topViewMinimisedHeight = 20.0f;
    
    SWRevealViewController *revealViewController = self.revealViewController;//self為何可以呼叫revealViewController?
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    bandArray = [NSMutableArray new];
    numberArray=[NSMutableArray new];
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSDictionary *user=[userDefaults objectForKey:@"userInformation"];
    NSLog(@"%@",user);
    UserName=user[@"account"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showUnfollow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [[searcher searchArr]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    // Configure the cell...

    cell.flag = [[searcher searchArr][indexPath.row][@"user_follow"] integerValue];
    cell.nameLabel.text= [searcher searchArr][indexPath.row][@"board_name"];
    cell.introLabel.text=[searcher searchArr][indexPath.row][@"intro"];
    cell.numberLabel.text=[searcher searchArr][indexPath.row][@"board_count"];
    
    
    //設定按鈕
        UIImage *accessoryImg;
        CGRect imgFrame;
    
        if (cell.flag==0) {
            accessoryImg = [UIImage imageNamed:@"follow"];
            imgFrame= CGRectMake(0, 0, accessoryImg.size.width, accessoryImg.size.height);
        }else{
            accessoryImg= [UIImage imageNamed:@"unfollow"];
            imgFrame = CGRectMake(0, 0, accessoryImg.size.width, accessoryImg.size.height);
        }
    
        [cell.Btn setFrame:imgFrame];
        [cell.Btn setBackgroundImage:accessoryImg forState:UIControlStateNormal];
        [cell.Btn setBackgroundColor:[UIColor clearColor]];
        [cell.Btn addTarget:self action:@selector(pressAccessoryBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (!([[searcher searchArr][indexPath.row][@"picture"]isKindOfClass:[NSNull class]])){
        cell.imageV.image=[UIImage imageNamed:@"loadCircle"];
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", ServerApiURL,[searcher searchArr][indexPath.row][@"picture"]];
        NSLog(@"imgUrl: %@", imgUrl);
        [cell.imageV setImageWithURL:[NSURL URLWithString:imgUrl]];
    }else{
        cell.imageV.image=[UIImage imageNamed:@"loadCircle"];
    }

    
    return cell;
}

-(void)pressAccessoryBtn:(UIButton *)button{
    //    NSLog(@"test sucess");
    //獲得Cell：button的上一層是UITableViewCell
    MyCell *cell = (MyCell *)button.superview.superview;
    //然后使用indexPathForCell方法，就得到indexPath了~
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *ID=[searcher searchArr][indexPath.row][@"board_id"];
    NSString *name=[searcher searchArr][indexPath.row][@"board_name"];
    if (cell.flag==1) {
        [self clickTounFollow:ID];
        NSLog(@"unFollow");
       
         NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:searcher.orginArr[indexPath.row]];
        dic[@"user_follow"]=@"0";
        [searcher.searchArr removeObjectAtIndex:indexPath.row];
        [searcher.searchArr  insertObject:dic atIndex:indexPath.row];
        [searcher.orginArr removeObjectAtIndex:indexPath.row];
        [searcher.orginArr  insertObject:dic atIndex:indexPath.row];
        
//        searcher.orginArr[indexPath.row][@"user_follow"]=@"0";
    }else{
        [self clickToFollow:ID boardname:name];
        NSLog(@"Follow");
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:searcher.orginArr[indexPath.row]];
        dic[@"user_follow"]=@"1";
        [searcher.searchArr removeObjectAtIndex:indexPath.row];
        [searcher.searchArr  insertObject:dic atIndex:indexPath.row];
        [searcher.orginArr removeObjectAtIndex:indexPath.row];
        [searcher.orginArr  insertObject:dic atIndex:indexPath.row];
//        [searcher searchArr][indexPath.row][@"user_follow"]=@"1";
    }
      NSLog(@"%ld",(long)indexPath.row);
      [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  100;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    MyCell *cell = (MyCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithRed:0.999 green:0.935 blue:0.322 alpha:1.000] ForCell:cell];  //highlight colour
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reset Colour.
    MyCell *cell = (MyCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithRed:0.653 green:0.931 blue:0.948 alpha:1.000] ForCell:cell]; //normal color
    
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
