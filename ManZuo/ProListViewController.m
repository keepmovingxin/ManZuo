//
//  ProListViewController.m
//  ManZuo
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "ProListViewController.h"
#import "DownloadManager.h"
#import "CONST.h"
#import "CustomCell.h"
#import "PromotionItem.h"
#import "UIImageView+WebCache.h"
#import "ProDetailViewController.h"

@interface ProListViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ProListViewController
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    DownloadManager *_dmg;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_dataArray = [[NSMutableArray alloc] init];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    [self.view addSubview:_tableView];
    // 下载网络数据
    [self loadDataWithURL:_url];
}

#pragma mark - Data
-(void)loadDataWithURL:(NSString *)url
{
    if ([[DownloadManager sharedDownloadManager] haveNet])
    {
        [self showHUDView];
        _dmg = [DownloadManager sharedDownloadManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdate:) name:url object:nil];
        [_dmg addDownLoadWithURL:url andType:cProDetailHasSub];
    }
}

-(void)dataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    NSArray *dataArray = [_dmg loadDataWithUrl:not.name];
    [_dataArray addObjectsFromArray:dataArray];
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:not.name object:nil];
}

#pragma mark - UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    PromotionItem *pro = [_dataArray objectAtIndex:indexPath.row];
    [cell.pImageView setImageWithURL:[NSURL URLWithString:pro.smallimgUrl]];
    cell.nameLabel.text = pro.intro;
    cell.priceLabel.text = [NSString stringWithFormat:@"¥%@",pro.currentPrice];
    cell.oldPriceLabel.text = [NSString stringWithFormat:@"¥%@",pro.oldPrice];
    cell.countLabel.text = [NSString stringWithFormat:@"%@人",pro.currentDealCount];
    cell.placeLabel.text = pro.district;
    
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PromotionItem *pro = [_dataArray objectAtIndex:indexPath.row];
    ProDetailViewController *pdvc = [[ProDetailViewController alloc] init];
    pdvc.proItem = pro;
    pdvc.isBackBtn = YES;
    [self.navigationController pushViewController:pdvc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
