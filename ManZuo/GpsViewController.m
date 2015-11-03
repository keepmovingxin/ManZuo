//
//  GpsViewController.m
//  ManZuo
//
//  Created by admin on 14-3-5.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "GpsViewController.h"
#import "DownloadManager.h"
#import "CONST.h"

@interface GpsViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@end

@implementation GpsViewController
{
    NSMutableArray *_dataArray;
    UITableView *_tableView;
    DownloadManager *_dmg;
    UISearchBar *_searchBar;
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
    [self.view addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.showsCancelButton = YES;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"城市名";
    _tableView.tableHeaderView = _searchBar;
    
    [self loadDataWithURL:kCityListURL];
}

#pragma mark - Data
-(void)loadDataWithURL:(NSString *)url
{
    if ([[DownloadManager sharedDownloadManager] haveNet])
    {
        [self showHUDView];
        _dmg = [DownloadManager sharedDownloadManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdate:) name:url object:nil];
        [_dmg addDownLoadWithURL:url andType:cCityList];
    }
}

-(void)dataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    NSArray *citys = [_dmg loadDataWithUrl:not.name];
    [_dataArray addObjectsFromArray:citys];
    [_tableView reloadData];
    
}

#pragma mark - UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self.view endEditing:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //搜索
    [self.view endEditing:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSString *key = searchBar.text;
    for (int i = 0;i<[_dataArray count];i++)
    {
        NSString *cityName = [[_dataArray objectAtIndex:i] name];
        NSRange range = [key rangeOfString:cityName];
        if (range.location != NSNotFound || [cityName hasPrefix:key] || [cityName hasSuffix:key] || [cityName isEqualToString:key]) {
            [newArray addObject:[_dataArray objectAtIndex:i]];
        }
    }
    if (newArray.count == 0) {
        NSLog(@"没有结果");
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有结果" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [al show];
    } else {
        [_dataArray removeAllObjects];
        [_dataArray addObjectsFromArray:newArray];
        [_tableView reloadData];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    cell.textLabel.text = [[_dataArray objectAtIndex:indexPath.row] name];
    return cell;
}

#pragma mark - UITableView Delegate
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    City *city = [_dataArray objectAtIndex:indexPath.row];
    _block(city);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
