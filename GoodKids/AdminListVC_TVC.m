//
//  ViewController.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "AdminListVC_TVC.h"
#import "SWRevealViewController.h"
#import "API.h"
#import "AdminContentVC_CVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AddBandView.h"
#import "AdminListCell.h"
#import "UIImageView+AFNetworking.h"
#import "JDFPeekabooCoordinator.h"

@interface AdminListVC_TVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;

@end

@implementation AdminListVC_TVC
{
    NSMutableArray *bandArray;
    NSMutableArray *originbandListArr;
    NSString *boardID;
    NSString *UserName;
    AddBandView *vc;
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
        [self.tableView reloadData];
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
    [self.tableView reloadData];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdminList) name:@"reLoadList" object:nil ];
    
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
    [self showAdminList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    vc = [[AddBandView alloc] initWithvc:self name:UserName];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - buttonAction
- (IBAction)addBandAction:(id)sender {
    vc.flag=1;
    [self.view addSubview:vc];
    [vc showView];
    
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
    AdminListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdminListCell" forIndexPath:indexPath];
    
    
    
    if (!([bandArray[indexPath.row][@"picture"]isKindOfClass:[NSNull class]])){
        cell.imageV.image=[UIImage imageNamed:@"save-26"];
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", ServerApiURL,bandArray[indexPath.row][@"picture"]];
        NSLog(@"imgUrl: %@", imgUrl);
        [cell.imageV setImageWithURL:[NSURL URLWithString:imgUrl]];
    }
    
    cell.nameLabel.text= bandArray[indexPath.row][@"board_name"];
    cell.introLabel.text= bandArray[indexPath.row][@"intro"];
    
    
    cell.accessoryView = [self addCustAccessoryBtn];
    
    return cell;
}
#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  100;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    AdminListCell *cell = (AdminListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithRed:0.999 green:0.935 blue:0.322 alpha:1.000] ForCell:cell];  //highlight colour
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reset Colour.
    AdminListCell *cell = (AdminListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithRed:0.653 green:0.931 blue:0.948 alpha:1.000] ForCell:cell]; //normal color
    
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}
#pragma mark - Custom Button and Method
-(UIButton *)addCustAccessoryBtn{
    UIImage *accessoryImg = [UIImage imageNamed:@"settings-75"];
    CGRect imgFrame = CGRectMake(0, 0, 35, 35);
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
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
                                       boardID=bandArray[indexPath.row][@"board_id"];
                                       NSLog(@"%@",boardID);
                                       [self deleteBand];
                                       [bandArray removeObjectAtIndex:indexPath.row];
                                       [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                       
                                       
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
        NSDictionary *dic=bandArray[indexPath.row];
        
        vc.flag=2;
        [self.view addSubview:vc];
        [vc showView];
        [vc setOldValue:dic];
            }];
    //Cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"關閉" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:renameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AdminContentVC_CVC *cvc=segue.destinationViewController;
    NSIndexPath *indexPath=self.tableView.indexPathForSelectedRow;
    cvc.reveiceboardID=bandArray[indexPath.row][@"board_id"];
    cvc.reveiceboardName=bandArray[indexPath.row][@"board_name"];
}

#pragma mark - UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    NSLog(@"開始編輯");
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"按下Cancel");
    searchBar.text = nil;
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"按下Search");
    [searchBar resignFirstResponder];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"結束編輯");
    NSString *filter = searchBar.text;
    if (filter.length == 0) {
        bandArray = [[NSMutableArray alloc]initWithArray:originbandListArr];
        [self.tableView reloadData];
        [searchBar resignFirstResponder];
    }else if(filter.length >0){
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:originbandListArr];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"board_name contains[c] %@",filter];
        
        [bandArray removeAllObjects];
        bandArray = [NSMutableArray arrayWithArray:[tempArray filteredArrayUsingPredicate:predicate]];
        
        [self.tableView reloadData];
        
        [searchBar resignFirstResponder];}
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"文字改變");
    NSString *filter = searchText;
    if (filter.length == 0) {
        bandArray = [[NSMutableArray alloc]initWithArray:originbandListArr];
        [self.tableView reloadData];
        [searchBar resignFirstResponder];
    }else if(filter.length >0){
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:originbandListArr];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"board_name contains[c] %@",filter];
        
        [bandArray removeAllObjects];
        bandArray = [NSMutableArray arrayWithArray:[tempArray filteredArrayUsingPredicate:predicate]];
        
        [self.tableView reloadData];
        
        [searchBar resignFirstResponder];}
}
@end
