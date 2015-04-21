//
//  ShowMessageVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "ShowMessageVC.h"
#import "EditMessageVC.h"
@interface ShowMessageVC ()<EditMessageVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ShowMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=_receiveDic[@"title"];
    _timeText.text=_receiveDic[@"date"];
    _contentText.text=_receiveDic[@"content"];
    NSLog(@"%@",_receiveDic[@"image"]);
    if (!(_receiveDic[@"image"] ==nil)){
    _imageView.image=_receiveDic[@"image"];

    }
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
    
    
    if (!(_receiveDic[@"image"] ==nil)){
        _imageView.image=_receiveDic[@"image"];
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
