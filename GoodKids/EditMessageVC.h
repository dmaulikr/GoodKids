//
//  EditMessageVC.h
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditMessageVC;
@protocol EditMessageVCDelegate <NSObject>
-(void) EditMessageVC:(EditMessageVC *)EditMessageVC messageDic:(NSDictionary *)message;
@end
@interface EditMessageVC : UIViewController
@property (assign,nonatomic) NSInteger flag;//1.新增  2.修改
@property (nonatomic,strong) NSMutableDictionary *messageDic;
@property (strong,nonatomic) id<EditMessageVCDelegate> Delegate;
@property (strong,nonatomic) NSDictionary *receiveEditDic;
@property (strong,nonatomic) NSString *reveiceboardID;
@end



