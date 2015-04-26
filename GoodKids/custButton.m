//
//  custButton.m
//  GoodKids
//
//  Created by 羅祐昌 on 2015/4/25.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "custButton.h"

@implementation custButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    CGFloat width = 187;
    CGFloat height = 40;
    CGRect buttonFrame = self.frame;
    buttonFrame.size = CGSizeMake(width, height);
    [self setFrame:buttonFrame];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:20];
    
}

@end
