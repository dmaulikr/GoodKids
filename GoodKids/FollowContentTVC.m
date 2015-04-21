//
//  FollowContentTVC.m
//  GoodKids
//
//  Created by 詹鎮豪 on 2015/4/15.
//  Copyright (c) 2015年 SuperNova. All rights reserved.
//

#import "FollowContentTVC.h"

@interface FollowContentTVC ()

@end

@implementation FollowContentTVC
{
    NSMutableArray *informationArray;
    NSDictionary *informationDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=_receiveTitle;
    informationArray =[NSMutableArray new];
    informationDic =[NSDictionary new];
    
    informationDic=@{@"title":@"連假首日塞 台北到蘇澳開了3小時",
                     @"content":@"清明連假首日上午國道局部大塞車，主要集中在中部及北部南下路段。高公局預估，午後國道還會有一波壅塞車潮。有不少民眾一大早6時許從台北出發走國5，到了9時30分還沒到蘇花公路，光是從蘇澳交流道到蘇花口就塞了1個多小時，無奈之只能在車上靜靜等候。坪林行控中心呼籲，國道5號今明兩天，從上午7時到中午12時，會在南港系統、石碇和坪林南下匝道入口處，實施高乘載管制。另外，5日和6日，則從下午3時到晚間8時，在國道5號北上，包含蘇澳、羅東、宜蘭和頭城匝道入口處，實施高乘載，敬請用路人配合。交通部高速公路局預估下午1時到晚上7時，易塞車路段為：國道1號南下楊梅至湖口、南下台中系統至大雅、南下彰化系統至埔鹽系統，國道3號北上木柵至南港系統。國5上午7時至中午12時因實施高乘載管制，車流量雖大，還不至於太壅塞。高公局說，午後國5高乘載管制解除，車流量會增加，也可能會出現塞車。"};
    [informationArray addObject:informationDic];
    informationDic=@{@"title":@"賓士駛200公里 載米麵送花蓮",
                     @"content":@"200公里送愛心！台北市內湖區的劉姓薑母鴨業者，在2日清晨2時收攤打烊後，與員工合力將300公斤白米、151包麵條及62包米粉搬進賓士車內，連夜開著賓士南下至花蓮縣鳳林警察分局送愛。員警看到賓士車送愛也嘖嘖稱奇，然而低調堅決不受訪的薑母鴨店老闆透過警方表示，「行善就對了!哪裡管他是什麼車。」昨日中午時分，花蓮縣鳳林警察分局突然駛近一輛嶄新的賓士轎車，原來是在台北開設薑母鴨店的劉姓老闆，奔波200公里送愛心，將賓士充當「貨車」也讓員警留下深刻記憶。對於為何要特地駕車開200公里送愛至花蓮，徐姓員工表示，老闆年輕時曾在鳳林鎮工作，受到許多人照顧，他也把花蓮當作第2個故鄉；如今自己有點成就，想回饋地方。老闆在出發先前還將物資拿到廟中祈福，盼望收到的人都能受庇佑，平安順利。徐姓員工表示，他一路和老闆兩人流輪駕車，沿途盡全力趕路，僅為了安全在蘇花公路上「小瞇」一下，從晚上開到白天，終於抵達鳳林，看見記憶中曾工作的地方，也讓老闆感慨萬千，盼望自己的小小善行能夠拋磚引玉，吸引更多的善心人士投入做愛心。鳳林警察分局組長葉貴和表示，以往愛心物資都是透過宅配或托運，少有人親自開車運送，會盡快將米麵分送給轄內弱勢家庭；員警們看到賓士車載滿愛心物資，都十分訝異，也佩服劉老闆的愛心和效率。"};
    [informationArray addObject:informationDic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return informationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text=informationArray[indexPath.row][@"title"];
    cell.detailTextLabel.text=informationArray[indexPath.row][@"content"];
    
    // Configure the cell...
    
    return cell;
}

//TODO:自動適高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *titleText = informationArray[indexPath.row][@"title"];
    NSString *contentText = informationArray[indexPath.row][@"content"];
    //根據文本內容字體計算高度，最大高度不超過1000
    CGSize titleSize = [titleText boundingRectWithSize:CGSizeMake(320, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;
    CGSize contentSize = [contentText boundingRectWithSize:CGSizeMake(320, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;
    
    return titleSize.height+contentSize.height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
