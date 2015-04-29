//
//  AdminListCell.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/28.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "AdminListCell.h"

@implementation AdminListCell

- (void)awakeFromNib {
    // Initialization code
    UIColor *borderColor = [UIColor whiteColor];
    [self.imageV.layer setBorderColor:borderColor.CGColor];
    [self.imageV.layer setBorderWidth:10.0];
    self.imageV.layer.cornerRadius = self.imageV.frame.size.width / 2;
    self.imageV.clipsToBounds = YES;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
