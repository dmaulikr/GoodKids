//
//  FollowMessageVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/30.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "FollowMessageVC.h"
#import "UIImageView+AFNetworking.h"
#import "API.h"
@interface FollowMessageVC ()
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UILabel *titletext;
@property (weak, nonatomic) IBOutlet UITextView *contentText;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation FollowMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.contentText setEditable:NO];
    self.titletext.text =_receiveDic[@"subject"];
    _timeText.text=_receiveDic[@"date_time"];
    _contentText.text=_receiveDic[@"content"];
    NSLog(@"%@",_receiveDic[@"picture"]);
    
    if (!(_receiveDic[@"picture"] ==nil)){
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",ServerApiURL,_receiveDic[@"picture"]];
        [_imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Rectangle"]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordBtnAction:(id)sender {
    [self saveInUserDefaltsWithDictionary];
}

- (void)saveInUserDefaltsWithDictionary{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tw.com.mit.TodayExtensionSharingDefaults"];
    NSString *account = [sharedDefaults objectForKey:@"account"];
    NSMutableDictionary *list;
    list = [NSMutableDictionary new];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_receiveDic[@"memo_id"],@"memo_id", _receiveDic[@"subject"], @"subject", _receiveDic[@"content"], @"content", nil];
    if ([sharedDefaults dictionaryForKey:account]) {
        list = [[sharedDefaults dictionaryForKey:account] mutableCopy];
        if (!list[_receiveDic[@"memo_id"]]) {
            [list setObject:dict forKey:_receiveDic[@"memo_id"]];
            [self alertWithTitle:@"新增成功!" message:@"成功加入Today widget"];
        }else{
            [self alertWithTitle:@"此文章已在您的Today widget中" message:nil];
        }
    }else{
        [list setObject:dict forKey:_receiveDic[@"memo_id"]];
        [self alertWithTitle:@"新增成功!" message:@"成功加入Today widget"];
    }
    [sharedDefaults setObject:list forKey:account];
    [sharedDefaults synchronize];
    NSLog(@"testXD:%@", [sharedDefaults objectForKey:account]);
}

#pragma mark - UIAlerViewController:alert

- (void) alertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
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

@end
