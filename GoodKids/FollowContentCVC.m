//
//  FollowContentCVC.m
//  GoodKids
//
//  Created by Su Shih Wen on 2015/4/23.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "FollowContentCVC.h"
#import "FollowContentCVCell.h"
#import "FollowMessageVC.h"
#import "API.h"
#import "UIImageView+AFNetworking.h"
#import "JDFPeekabooCoordinator.h"
@interface FollowContentCVC ()
@property (nonatomic, strong) JDFPeekabooCoordinator *scrollCoordinator;
@end

@implementation FollowContentCVC{
    NSMutableArray *FollowMessageArray;
    NSString *boardID;
    BOOL tag;
}

static NSString * const reuseIdentifier = @"followContentCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollCoordinator = [[JDFPeekabooCoordinator alloc] init];
    self.scrollCoordinator.scrollView = self.collectionView;
    self.scrollCoordinator.topView = self.navigationController.navigationBar;
    self.scrollCoordinator.bottomView = self.tabBarController.tabBar;
    self.scrollCoordinator.containingView = self.tabBarController.view;
    self.scrollCoordinator.topViewMinimisedHeight = 20.0f;
    
    FollowMessageArray =[NSMutableArray new];

    tag = 1;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.scrollCoordinator enable];
    boardID=_reveiceboardID;
    [self showMemo];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scrollCoordinator disable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMemo{
    //啟動一個hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //設定hud顯示文字
    [hud setLabelText:@"Loading"];
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
        FollowMessageArray =[NSMutableArray arrayWithArray:responseObject[@"api"]];
        [self.collectionView reloadData];
        //輸出response
        NSLog(@"response: %@", responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //request失敗之後要做的事
        NSLog(@"request error: %@", error);
        ;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return FollowMessageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FollowContentCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    cell.titleLabel.text = FollowMessageArray[indexPath.row][@"subject"];
    cell.contentLabel.text = FollowMessageArray[indexPath.row][@"content"];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ServerApiURL,FollowMessageArray[indexPath.row][@"picture"]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    FollowMessageVC *vc= [segue destinationViewController];
    NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
    NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
    vc.receiveDic=FollowMessageArray[indexPath.row];
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

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
