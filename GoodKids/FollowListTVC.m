//
//  FollowListTVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "FollowListTVC.h"
#import "SWRevealViewController.h"
#import "FollowContentCVC.h"
#import "API.h"
#import "UIImageView+AFNetworking.h"
#import "Searcher.h"
#import "FollowListCell.h"
#import "JDFPeekabooCoordinator.h"
@interface FollowListTVC ()
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;

@end

@implementation FollowListTVC
{
    NSMutableArray *FollowBandList;
    NSString *UserName;
    NSString *boardID;
    Searcher *searcher;
}

#pragma mark - SQL Method
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
        
        //輸出response
        NSLog(@"response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}



-(void)showFollowBand{
    
    //啟動一個hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //設定hud顯示文字
    [hud setLabelText:@"connecting"];
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"showFollow", @"cmd",UserName,@"account", nil];
    //產生控制request物件
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:hostRootURL];
    //accpt text/html
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //POST
    [manager POST:@"management.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //request成功之後要做的事
        //輸出response
        FollowBandList= (NSMutableArray *)responseObject[@"api"];
        searcher = [[Searcher alloc] searchWithArr:FollowBandList searchBar:self.searchBar tableview:self.tableView predicateString:@"board_name contains[c] %@"];
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"response: %@", responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

#pragma mark--Main

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;//self為何可以呼叫revealViewController?
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //scroll screen to hide toolBar & navigatinBar
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
    
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSDictionary *user=[userDefaults objectForKey:@"userInformation"];
    NSLog(@"%@",user);
    UserName=user[@"account"];
    FollowBandList = [NSMutableArray new];
    
//    [self showFollowBand];
}

-(void)viewWillAppear:(BOOL)animated{
    _searchBar.text = @"";
    [self showFollowBand];
    [self.scrollCoordinator disable];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.scrollCoordinator enable];
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
    FollowListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowListCell" forIndexPath:indexPath];
    
    cell.nameLabel.text= [searcher searchArr][indexPath.row][@"board_name"];
    cell.introLabel.text=[searcher searchArr][indexPath.row][@"intro"];
    
        [cell.Btn addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!([[searcher searchArr][indexPath.row][@"picture"]isKindOfClass:[NSNull class]])){
        cell.imageV.image=[UIImage imageNamed:@"loadCircle"];
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", ServerApiURL,[searcher searchArr][indexPath.row][@"picture"]];
        NSLog(@"imgUrl: %@", imgUrl);
        [cell.imageV setImageWithURL:[NSURL URLWithString:imgUrl]];
    }else{
        cell.imageV.image=[UIImage imageNamed:@"loadCircle"];
    }
    
    
        // Configure the cell...
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  100;
}

-(void)pressBtn:(UIButton *)button{
    //    NSLog(@"test sucess");
    //獲得Cell：button的上一層是UITableViewCell
    FollowListCell *cell = (FollowListCell *)button.superview.superview;
    //然后使用indexPathForCell方法，就得到indexPath了~
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //  NSLog(@"%ld",(long)indexPath.row);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否取消訂閱" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
  
    //Ok
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        boardID=[searcher searchArr][indexPath.row][@"board_id"];
        NSLog(@"%@",boardID);
        [self clickTounFollow:boardID];
        [[searcher searchArr] removeObjectAtIndex:indexPath.row];
        [[searcher orginArr] removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        
    }];
    //Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    FollowListCell *cell = (FollowListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithRed:0.999 green:0.935 blue:0.322 alpha:1.000] ForCell:cell];  //highlight colour
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reset Colour.
    FollowListCell *cell = (FollowListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithRed:0.653 green:0.931 blue:0.948 alpha:1.000] ForCell:cell]; //normal color
    
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

 #pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    FollowContentCVC *cvc=segue.destinationViewController;
    NSIndexPath *indexPath=self.tableView.indexPathForSelectedRow;
    cvc.reveiceboardID=[searcher searchArr][indexPath.row][@"board_id"];
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


@end
