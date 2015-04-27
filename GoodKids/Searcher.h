//
//  Searcher.h
//  SearchBarTest
//
//  Created by Su Shih Wen on 2015/4/25.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Searcher : NSObject<UISearchBarDelegate>{
    //NSMutableArray *orginArr;
    UITableView *tableview;
    NSString *preStr;
}

@property (readonly, retain) NSMutableArray *searchArr;
@property (strong, nonatomic) NSMutableArray *orginArr;

- (id) searchWithArr:(NSMutableArray*)originArray searchBar:(UISearchBar*) searchbar tableview:(UITableView*)tableView predicateString:(NSString*)predicateStr;

@end
