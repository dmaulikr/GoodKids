//
//  FollowListCell.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/28.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "FollowListCell.h"

@implementation FollowListCell

- (void)awakeFromNib {
    // Initialization code
    UIColor *borderColor = [UIColor whiteColor];
    [self.imageV.layer setBorderColor:borderColor.CGColor];
    [self.imageV.layer setBorderWidth:3.0];
    self.imageV.layer.cornerRadius = self.imageV.frame.size.width / 2;
    self.imageV.clipsToBounds = YES;
    
    
    //設定按鈕
    
    UIImage *accessoryImg= [UIImage imageNamed:@"unfollow"];
    CGRect imgFrame = CGRectMake(0, 0, accessoryImg.size.width, accessoryImg.size.height);
    
    
    [self.Btn setFrame:imgFrame];
    [self.Btn setBackgroundImage:accessoryImg forState:UIControlStateNormal];
    [self.Btn setBackgroundColor:[UIColor clearColor]];
    
    self.image1.layer.cornerRadius = self.image1.frame.size.width / 2;
    self.image1.clipsToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
