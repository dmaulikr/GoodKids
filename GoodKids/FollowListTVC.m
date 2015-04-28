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
#import "Searcher.h"
#import "JDFPeekabooCoordinator.h"
@interface FollowListTVC ()
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;

@end

@implementation FollowListTVC
{
    NSMutableArray *FollowBandList;
    NSString *UserName;
    
    Searcher *searcher;
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
    
    //Navigation Bar
    SWRevealViewController *revealViewController = self.revealViewController;//self為何可以呼叫revealViewController?
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowListCell" forIndexPath:indexPath];
    cell.textLabel.text=[searcher searchArr][indexPath.row][@"board_name"];
    // Configure the cell...
    
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    FollowContentCVC *cvc=segue.destinationViewController;
    NSIndexPath *indexPath=self.tableView.indexPathForSelectedRow;
    NSLog(@"%ld",[[searcher searchArr][indexPath.row][@"board_id"] integerValue]);
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
