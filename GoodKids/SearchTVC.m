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
@interface SearchTVC ()

@end

@implementation SearchTVC
{
    NSMutableArray *bandArray;
    NSInteger *buttonflag;
    NSMutableArray *test;
}

#pragma mark - SQL Method

-(void)showUnfollow{
    NSString *UserName =@"oktenokis@yahoo.com.tw";
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
//        NSMutableArray *data= [NSMutableArray new];
//        data=responseObject[@"api"][@"showunfollow"];
//        [data removeLastObject];
        bandArray =responseObject[@"api"];
        [self.tableView reloadData];
        //輸出response
        NSLog(@"response: %@", responseObject[@"api"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}


-(void)ckeckToFollow:(NSString *)boardID boardname:(NSString *)boardName{
    NSString *UserName =@"oktenokis@yahoo.com.tw";
    //設定伺服器的根目錄
    NSURL *hostRootURL = [NSURL URLWithString: ServerApiURL];
    //設定post內容
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"follow", @"cmd",UserName,@"account",boardID,@"board_id",boardName,@"boardName", nil];
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

#pragma mark - Main

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;//self為何可以呼叫revealViewController?
    if (revealViewController) {
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
//    NSArray *TestArray1=@[@"0",@"1",@"0"];
//    test = [NSMutableArray new];
//    test = [[NSMutableArray alloc] initWithArray:TestArray1];
    
//    NSArray *TestArray=@[@"1",@"2",@"3"];
    bandArray = [NSMutableArray new];
//    bandArray = [[NSMutableArray alloc] initWithArray:TestArray];
    
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
    return bandArray.count-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTVCCELL" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.tag = 0;
    cell.accessoryView = [self addCustAccessoryBtn:cell.tag];
    cell.textLabel.text= bandArray[indexPath.row][@"board_name"];
    
    return cell;
}


#pragma mark - Custom Button and Method
-(UIButton *)addCustAccessoryBtn:(NSInteger)flag{
    UIImage *accessoryImg;
    CGRect imgFrame;
    UIButton *custAccessoryBtn;
    if (flag==1) {
        accessoryImg = [UIImage imageNamed:@"settings-25"];
        imgFrame= CGRectMake(0, 0, accessoryImg.size.width, accessoryImg.size.height);
    }else{
        accessoryImg= [UIImage imageNamed:@"home-24"];
        imgFrame = CGRectMake(0, 0, accessoryImg.size.width, accessoryImg.size.height);
    }
    custAccessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [custAccessoryBtn setFrame:imgFrame];
    [custAccessoryBtn setBackgroundImage:accessoryImg forState:UIControlStateNormal];
    [custAccessoryBtn setBackgroundColor:[UIColor clearColor]];
    if (flag==1) {
        [custAccessoryBtn addTarget:self action:@selector(pressAccessoryBtn:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [custAccessoryBtn addTarget:self action:@selector(pressAccessoryBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return custAccessoryBtn;
}


-(void)pressAccessoryBtn:(UIButton *)button{
    //    NSLog(@"test sucess");
    //獲得Cell：button的上一層是UITableViewCell
    UITableViewCell *cell = (UITableViewCell *)button.superview;
    //然后使用indexPathForCell方法，就得到indexPath了~
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *ID=bandArray[indexPath.row][@"board_id"];
    NSString *name=bandArray[indexPath.row][@"board_name"];
    if (cell.tag==1) {
        NSLog(@"unFollow");
        cell.tag=0;
    }else{
        [self ckeckToFollow:ID boardname:name];
        NSLog(@"Follow");
        cell.tag=1;
    }
      NSLog(@"%ld",(long)indexPath.row);
    [self.tableView reloadData];
    
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
