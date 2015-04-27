//
//  Searcher.m
//  SearchBarTest
//
//  Created by Su Shih Wen on 2015/4/25.
//  Copyright (c) 2015年 Su Shih Wen. All rights reserved.
//

#import "Searcher.h"

@implementation Searcher

@synthesize orginArr;

- (id) searchWithArr:(NSMutableArray *)originArray searchBar:(UISearchBar *)searchbar tableview:(UITableView *)tableView predicateString:(NSString *)predicateStr{
    
    orginArr = [originArray mutableCopy];
    _searchArr = [orginArr mutableCopy];
    tableview = tableView;
    preStr = [predicateStr copy];
    searchbar.delegate = self;
    
    return self;
}

#pragma mark - UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    //NSLog(@"開始編輯");
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"按下Cancel");
    searchBar.text = nil;
    [searchBar setShowsCancelButton:NO animated:YES];
    [tableview reloadData];
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"按下Search");
    [searchBar resignFirstResponder];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //NSLog(@"結束編輯");
    NSString *filter = searchBar.text;
    if (filter.length == 0) {
        _searchArr = [[NSMutableArray alloc]initWithArray:orginArr];
        [tableview reloadData];
        [searchBar resignFirstResponder];
    }else if(filter.length >0){
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:orginArr];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:preStr,filter];
        
        [_searchArr removeAllObjects];
        _searchArr = [NSMutableArray arrayWithArray:[tempArray filteredArrayUsingPredicate:predicate]];
        NSLog(@"searchArr:%@", _searchArr);
        [tableview reloadData];
        
        [searchBar resignFirstResponder];}
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //NSLog(@"文字改變");
    NSString *filter = searchText;
    if (filter.length == 0) {
        _searchArr = [[NSMutableArray alloc]initWithArray:orginArr];
        [tableview reloadData];
        [searchBar resignFirstResponder];
    }else if(filter.length >0){
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:orginArr];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:preStr,filter];
        
        [_searchArr removeAllObjects];
        _searchArr = [NSMutableArray arrayWithArray:[tempArray filteredArrayUsingPredicate:predicate]];
        
        [tableview reloadData];
        
        [searchBar resignFirstResponder];}
}

@end
