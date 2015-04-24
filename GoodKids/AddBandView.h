//
//  AddBandView.h
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/23.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBandView : UIView
@property (assign,nonatomic) NSInteger flag;//1.新增 2.修改

- (instancetype)initWithvc:(UIViewController *)vc name:(NSString *)name;
-(void)showView;
@end
