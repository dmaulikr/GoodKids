//
//  ShareUtility.h
//  GoodKids
//
//  Created by Su Shih Wen on 2015/4/21.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShareUtility : NSObject

- (instancetype)initWithTitle:(NSString *)Title content:(NSString *)content photo:(UIImage *)photo;
- (void)start;

@end
