//
//  ViewController.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "AdminMainVC.h"
#import "SWRevealViewController.h"
#import "API.h"
#import "AdminMainTVC-2.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AddBandView.h"
@interface AdminMainVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AdminMainVC
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
    AdminMainTVC_2 *tvc=segue.destinationViewController;
    NSIndexPath *indexPath=self.tableView.indexPathForSelectedRow;
    tvc.reveiceboardID=bandArray[indexPath.row][@"board_id"];
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
