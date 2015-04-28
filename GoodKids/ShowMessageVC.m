//
//  ShowMessageVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "ShowMessageVC.h"
#import "EditMessageVC.h"
#import "UIImageView+AFNetworking.h"
#import "API.h"
@interface ShowMessageVC ()<EditMessageVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UILabel *titletext;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ShowMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentText setEditable:NO];
    self.titletext.text =_receiveDic[@"subject"];
    _timeText.text=_receiveDic[@"date_time"];
    _contentText.text=_receiveDic[@"content"];
    NSLog(@"%@",_receiveDic[@"picture"]);
    if (!(_receiveDic[@"picture"] ==nil)){
//    _imageView.image=_receiveDic[@"picture"];
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ServerApiURL,_receiveDic[@"picture"]];
    [_imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressEditAction:(id)sender {
    EditMessageVC *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"customView"];
    vc.receiveEditDic=_receiveDic;
    vc.Delegate=self;
    vc.flag=2;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)EditMessageVC:(EditMessageVC *)EditMessageVC messageDic:(NSDictionary *)message{
    
    _receiveDic=message;
    self.title=_receiveDic[@"title"];
    _timeText.text=_receiveDic[@"date"];
    _contentText.text=_receiveDic[@"content"];
    
    
    if (!(_receiveDic[@"picture"] ==nil)){
        _imageView.image=_receiveDic[@"picture"];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
