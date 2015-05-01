//
//  TodayViewController.m
//  GoodKids Widget
//
//  Created by Su Shih Wen on 2015/5/1.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>{
    NSString *account;
    NSUserDefaults *defaults;
    NSArray *listKey;
    NSMutableDictionary *list;
}
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation TodayViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [list objectForKey:listKey[indexPath.row]][@"subject"];
    cell.textLabel.textColor = [UIColor lightTextColor];
    cell.detailTextLabel.text = [list objectForKey:listKey[indexPath.row]][@"content"];
    cell.detailTextLabel.textColor = [UIColor lightTextColor];
    
    
    return cell;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateAccount];
}

- (void)updateAccount {
    account = [defaults stringForKey:@"account"];
    list = [[defaults dictionaryForKey:account] mutableCopy];
    listKey = [list allKeys];
    [self.tableview reloadData];
    self.preferredContentSize = self.tableview.contentSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tw.com.mit.TodayExtensionSharingDefaults"];
    [self updateAccount];
    self.tableview.estimatedRowHeight = 50.0;
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.preferredContentSize = self.tableview.contentSize;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableview addGestureRecognizer:swipeRight];
}

- (void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.tableview];
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:location];
    [list removeObjectForKey:listKey[indexPath.row]];
    [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [defaults setObject:list forKey:account];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 10.0;
    return margins;
}

@end
