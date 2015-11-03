//
//  SearchViewController.m
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "SearchViewController.h"
#import "DownloadManager.h"
#import "CONST.h"
#import "UISearchBar+UITextField.h"
#import "CustomCell.h"
#import "PromotionItem.h"
#import "UIImageView+WebCache.h"
#import "ProDetailViewController.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@end

@implementation SearchViewController
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UISearchBar *_searchBar;
    UISearchDisplayController *_sdc;
    UIButton *_selectBtn;
    DownloadManager *_dmg;
    NSMutableArray *_resultArray;
    BOOL _isSearch;
    NSMutableArray *_historyKeywords;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isSearch = NO;
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"citycode"];
    code = code.length>0?code:@"beijing";
    [self loadDataWithURL:[NSString stringWithFormat:kHotKeyURL,code] andType:cHotKey];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isSearch = NO;
    _dataArray = [[NSMutableArray alloc] init];
    _resultArray = [[NSMutableArray alloc] init];
    NSArray *hisKW = [[NSUserDefaults standardUserDefaults] objectForKey:@"historykeywords"];
    _historyKeywords = [[NSMutableArray alloc] initWithArray:hisKW];
    if (_historyKeywords.count==0) {
        _historyKeywords  = [[NSMutableArray alloc] init];
    }

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"产品名/商圈/商家 关键字";
    _searchBar.backgroundImage = [UIImage imageNamed:@"searchField_bg.png"];
    UITextField *textField = [_searchBar textField];
    textField.background = [UIImage imageNamed:@"search_long.png"];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    _tableView.tableHeaderView = _searchBar;
}

#pragma mark - Data
-(void)loadDataWithURL:(NSString *)url andType:(int)type
{
    if ([[DownloadManager sharedDownloadManager] haveNet])
    {
        [self showHUDView];
        _dmg = [DownloadManager sharedDownloadManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdate:) name:url object:nil];
        [_dmg addDownLoadWithURL:url andType:type];
    }
}

-(void)dataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    NSArray *dataArray = [_dmg loadDataWithUrl:not.name];
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:dataArray];
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:not.name object:nil];
}

#pragma mark - UISeachBar Delegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //搜索
    [self showHUDView];
    NSString *url = [NSString stringWithFormat:kSeachURL,@"北京",0,searchBar.text];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchDataUpdate:) name:url object:nil];
    [_dmg addDownLoadWithURL:url andType:cSearch];
    [_historyKeywords addObject:searchBar.text];
    [[NSUserDefaults standardUserDefaults] setValue:_historyKeywords forKey:@"historykeywords"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view endEditing:YES];
}

-(void)searchDataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    _isSearch = YES;
    NSArray *resultArray = [_dmg loadDataWithUrl:not.name];
    [_resultArray addObjectsFromArray:resultArray];
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:[resultArray objectAtIndex:2]];
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:not.name object:nil];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _isSearch = NO;
    [self.view endEditing:YES];
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
    if (_isSearch)
    {
        static NSString *cellName = @"customCell";
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        PromotionItem *pro = [_dataArray objectAtIndex:indexPath.row];
        [cell.pImageView setImageWithURL:[NSURL URLWithString:pro.wsdimgUrl]];
        cell.nameLabel.text = pro.multiPageTitle;
        cell.priceLabel.text = [NSString stringWithFormat:@"¥%@",pro.currentPrice];
        cell.oldPriceLabel.text = [NSString stringWithFormat:@"¥%@",pro.oldPrice];
        cell.countLabel.text = [NSString stringWithFormat:@"%@人",pro.currentDealCount];
        cell.placeLabel.text = pro.district;
        cell.typeImageView.hidden = (pro.hassub == -1)?YES:NO;
        
        return cell;
    } else
    {
        static NSString *cellName = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        }
        cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
        return cell;
    }
    return nil;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isSearch) {
        return 30.0f;
    }
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSearch) {
        return 100.0f;
    }
    return 44.0f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"共找到%@条和“%@”相关的团购信息",[_resultArray objectAtIndex:0],[_resultArray objectAtIndex:1]];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_isSearch) {
        UIView *shView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        shView.backgroundColor = [UIColor clearColor];
        shView.userInteractionEnabled = YES;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"search_left_bg.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"search_left_bg_press.png"] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:@"search_left_bg_selected.png"] forState:UIControlStateSelected];
        btn.tag = 101;
        btn.frame = CGRectMake(0, 0, 160, 40);
        [btn setTitle:@"热词搜索" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:0.29f green:0.62f blue:0.79f alpha:1.00f] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shView addSubview:btn];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.backgroundColor = [UIColor clearColor];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"search_right_bg.png"] forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"search_right_bg_press.png"] forState:UIControlStateHighlighted];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"search_right_bg_selected.png"] forState:UIControlStateSelected];
        btn1.tag = 102;
        btn1.frame = CGRectMake(160, 0, 160, 40);
        [btn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor colorWithRed:0.29f green:0.62f blue:0.79f alpha:1.00f] forState:UIControlStateSelected];
        [btn1 setTitle:@"历史搜索" forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shView addSubview:btn1];
        
        NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectbtn"];
        BOOL select = [title isEqualToString:@"热词搜索"]?YES:NO;
        // 选中第一个
        _selectBtn = select?btn:btn1;
        [_selectBtn setSelected:YES];
        return shView;
    } else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        label.backgroundColor = [UIColor colorWithRed:0.76f green:0.79f blue:0.81f alpha:1.00f];
        label.font = [UIFont systemFontOfSize:16.0f];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        return label;
    }
    return nil;
}

-(void)btnClick:(UIButton *)btn
{
    if (_selectBtn)
    {
        [_selectBtn setSelected:NO];
    }
    _selectBtn = btn;
    [[NSUserDefaults standardUserDefaults] setValue:_selectBtn.currentTitle forKey:@"selectbtn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [btn setSelected:!btn.selected];
    if (btn.tag == 101)
    {
        NSLog(@"热词搜索");
        _isSearch = NO;
        NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"citycode"];
        code = code.length>0?code:@"beijing";
        [self loadDataWithURL:[NSString stringWithFormat:kHotKeyURL,code] andType:cHotKey];
    } else if (btn.tag == 102)
    {
        NSLog(@"历史搜索");
        _isSearch = NO;
        NSArray *hisKW = [[NSUserDefaults standardUserDefaults] objectForKey:@"historykeywords"];
        [_dataArray removeAllObjects];
        [_dataArray addObject:@"清空搜索记录"];
        [_dataArray addObjectsFromArray:hisKW];
        [_tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    if (!_isSearch)
    {
        NSString *title = [_dataArray objectAtIndex:indexPath.row];
        if ([title isEqualToString:@"清空搜索记录"])
        {
            [_historyKeywords removeAllObjects];
            [[NSUserDefaults standardUserDefaults] setValue:_historyKeywords forKey:@"historykeywords"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_tableView reloadData];
        } else
        {
            NSString *url = [NSString stringWithFormat:kSeachURL,@"北京",0,[_dataArray objectAtIndex:indexPath.row]];
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self showHUDView];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchDataUpdate:) name:url object:nil];
            [_dmg addDownLoadWithURL:url andType:cSearch];
            [_historyKeywords addObject:[_dataArray objectAtIndex:indexPath.row]];
            [[NSUserDefaults standardUserDefaults] setValue:_historyKeywords forKey:@"historykeywords"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } else
    {
        // 跳转到下一页
        PromotionItem *pro = [_dataArray objectAtIndex:indexPath.row];
        // 没有列表，直接进入详情页
        ProDetailViewController *pdvc = [[ProDetailViewController alloc] init];
        pdvc.proItem = pro;
        pdvc.isBackBtn = YES;
        [self.navigationController pushViewController:pdvc animated:YES];
        NSLog(@"pro:%@",pro.durl);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
