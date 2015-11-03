//
//  HomeViewController.m
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "HomeViewController.h"
#import "PullTableView.h"
#import "CustomCell.h"
#import "ScrollPageView.h"
#import "DownloadManager.h"
#import "CONST.h"
#import "PromotionItem.h"
#import "ActivityItem.h"
#import "UIImageView+WebCache.h"
#import "ActDetailViewController.h"
#import "GpsViewController.h"
#import "City.h"
#import "CateCell.h"
#import "ProDetailViewController.h"
#include "ProListViewController.h"
#import "MZDataBase.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,PullTableViewPullDelegate,ScrollPageViewDelegate,UIAlertViewDelegate>

@end

@implementation HomeViewController
{
    PullTableView *_tableView;
    NSMutableArray *_dataArray;
    NSMutableArray *_activityArray;
    ScrollPageView *_headerView;
    DownloadManager *_dmg;
    // 摇一摇
    UIView *_shakeView;
    // 阴影
    UIView *_shadowView;
    City *_currentCity;
    NSMutableArray *_sortArray;
    NSUserDefaults *_userDefaults;
    // 记录当前选中的btn
    UIButton *_selectTypeBtn;
    NSMutableArray *_cateArray;
    NSArray *_subCateArray;
    UITableView *_cateSubTableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initNavigationItems];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _dataArray = [[NSMutableArray alloc] init];
    _sortArray = [[NSMutableArray alloc] initWithObjects:
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"人气最高",@"title",
                   [NSNumber numberWithInt:-1],@"st", nil ],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"价格最低",@"title",
                   [NSNumber numberWithInt:2],@"st", nil ],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"最新发布",@"title",
                   [NSNumber numberWithInt:-3],@"st", nil ],
                  [NSDictionary dictionaryWithObjectsAndKeys:
                   @"折扣最低",@"title",
                   [NSNumber numberWithInt:4],@"st", nil ],nil];
    // 初始化分类数据
    NSString *path = [NSString stringWithFormat:@"%@/Category.plist",[[NSBundle mainBundle] resourcePath]];
    _cateArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    _activityArray = [[NSMutableArray alloc] init];
    _tableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
    _tableView.showHeaderView = YES;
    _tableView.type = DEFAULTCELL;
    _tableView.dataSource = self;
    _tableView.pullDelegate = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    [self.view addSubview:_tableView];

    _headerView = [[ScrollPageView alloc] initWithFrame:CGRectMake(0, 0, 320, 120) imageArray:nil autoScroll:NO];
    _headerView.delegate = self;
    _tableView.tableHeaderView = _headerView;
    
    NSString *cityCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"citycode"];
    NSString *code = cityCode.length>0?cityCode:@"beijing";
    NSString *cityName = [[NSUserDefaults standardUserDefaults] objectForKey:@"cityname"];
    NSString *name = cityName.length>0?cityName:@"北京";
    _currentCity = [[City alloc] init];
    _currentCity.code = code;
    _currentCity.name = name;
    
    // 是否是首次进入首页
    NSInteger homeCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"visithomecount"];
    [[NSUserDefaults standardUserDefaults] setInteger:homeCount forKey:@"visithomecount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (homeCount == 0)
    {
        // 首次进入，加入引导视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
        imageView.image = [UIImage imageNamed:@"guideHome.png"];
        imageView.userInteractionEnabled = YES;
        [self.tabBarController.view addSubview:imageView];
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapAction:)];
        imageTap.numberOfTapsRequired = 1;
        imageTap.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:imageTap];
        homeCount ++;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:homeCount forKey:@"visithomecount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[DownloadManager sharedDownloadManager] haveNet]) {
        // 下载网络数据
        // cc 城市 pt 类型 ffst 数量 mnt 每次多少条 st 排序 hs
        // @"http://mps.manzuo.com/mps/cate?sid=97042009&id=0&cc=%@&pt=%@&ffst=%d&mnt=15&st=%d&hs=1"
        [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,code,@"all",0,-1]];
        // 活动视图网络数据
        [_dmg addDownLoadWithURL:kActivityURL andType:cActivity];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actDataUpdate:) name:kActivityURL object:nil];
        // 有网络 将数据库中数据清空 更新数据
        [[MZDataBase sharedMZDataBase] deleteAllPromotions];
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"咦，您的手机网络还有有点问题，前往设置" delegate:self cancelButtonTitle:@"算了" otherButtonTitles:@"设置", nil];
        [alert show];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 算了 加载数据库中的数据
        NSArray *proIds = [_userDefaults objectForKey:@"homeProIds"];
        MZDataBase *mzDataBase = [MZDataBase sharedMZDataBase];
        for (NSNumber *proId in proIds)
        {
            [_dataArray addObject:[mzDataBase selectPromotionWithId:proId.intValue]];
        }
        [_tableView reloadData];
    } else if (buttonIndex == 1) {
        // 跳到设置
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=Restrictions"]];
        [self exitApplication];
    }
}

//------- 退出程序 -------//
- (void)exitApplication
{
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    // [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.view.window cache:NO];
    [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.view cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.view.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
    
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID compare:@"exitApplication"] == 0)
    {
        exit(0);
    }
}

-(void)imageTapAction:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    [imageView removeFromSuperview];
    imageView = nil;
}

-(void)initNavigationItems
{
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    titleView.image = [UIImage imageNamed:@"title_logo.png"];
    self.navigationItem.titleView = titleView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    btn.tag = 101;
    [btn setImage:[UIImage imageNamed:@"shake_btn.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 100, 30);
    btn1.tag = 102;
    btn1.titleLabel.textAlignment = NSTextAlignmentRight;
    btn1.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [btn1 setImage:[UIImage imageNamed:@"ico_drop.png"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"ico_drop_p.png"] forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"cityname"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"cityname"]:@"北京";
    [btn1 setTitle:title forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightItem, nil];
}

#pragma mark - Data
-(void)loadDataWithURL:(NSString *)url
{
    if ([[DownloadManager sharedDownloadManager] haveNet])
    {
        [self showHUDView];
        _dmg = [DownloadManager sharedDownloadManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdate:) name:url object:nil];
        [_dmg addDownLoadWithURL:url andType:cProductList];
    }
}

-(void)dataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    NSArray *dataArray = [_dmg loadDataWithUrl:not.name];
    [_dataArray addObjectsFromArray:dataArray];
    [_tableView reloadData];
    //将首页产品的Id保存到NSUserDefaults
    NSMutableArray *proIds = [[NSMutableArray alloc] init];
    for (PromotionItem *pro in _dataArray)
    {
        [proIds addObject:[NSNumber numberWithInt:pro.proId]];
    }
    [_userDefaults setObject:proIds forKey:@"homeProIds"];
    [_userDefaults synchronize];
    if ([_tableView respondsToSelector:@selector(loadPullDownDataFinish)]) {
        // 结束下拉刷新
        [_tableView performSelector:@selector(loadPullDownDataFinish) withObject:nil afterDelay:0.2f];
    }
    if ([_tableView respondsToSelector:@selector(loadPullUpDataFinish)]) {
        // 结束上拉加载
        [_tableView performSelector:@selector(loadPullUpDataFinish) withObject:nil afterDelay:0.2f];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:not.name object:nil];
}

-(void)actDataUpdate:(NSNotification *)not
{
    NSArray *actArray = [_dmg loadDataWithUrl:not.name];
    [_activityArray removeAllObjects];
    [_activityArray addObjectsFromArray:actArray];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (ActivityItem *item in actArray)
    {
        [images addObject:item.imgUrl];
    }
    [_headerView setImageArray:images];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:not.name object:nil];
}

#pragma mark - ScrollPageView Delegate
-(void)didClickImageView:(int)index
{
    // 活动详情
    if ([_activityArray count]>0)
    {
        ActivityItem *actItem = [_activityArray objectAtIndex:index];
        ActDetailViewController *advc = [[ActDetailViewController alloc] init];
        advc.url = actItem.durl;
        advc.isBackBtn = YES;
        advc.navigationItem.title = actItem.actName;
        [self.navigationController pushViewController:advc animated:YES];
        NSLog(@"act:%@",advc.url);
    }
}


-(void)btnClick:(UIButton *)btn
{
    if (btn.tag == 101)
    {
        // 摇一摇
        if (!_shakeView)
        {
            _shakeView = [[UIView alloc] initWithFrame:self.view.bounds];
            _shakeView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3];
            [self.view addSubview:_shakeView];
            UITapGestureRecognizer *shakeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideShakeView:)];
            [_shakeView addGestureRecognizer:shakeTap];
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 140)];
            bgView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            bgView.center = _shakeView.center;
            [_shakeView addSubview:bgView];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((280-85)/2, 10, 85, 65)];
            imageView.image = [UIImage imageNamed:@"shake.png"];
            [bgView addSubview:imageView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 280, 60)];
            label.text = @"满座 摇摇我\n 小贴士：摇的越用力，奖品越给力哦：）";
            label.numberOfLines = 2;
            label.font = [UIFont systemFontOfSize:14.0f];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            [bgView addSubview:label];
        }
    } else if (btn.tag == 102)
    {
        // 定位城市列表
        GpsViewController *gvc = [[GpsViewController alloc] init];
        gvc.isBackBtn = YES;
        gvc.title = @"选择城市";
        [gvc setBlock:^(City *city){
            _currentCity = city;
            // 把城市存入到userDefaults
            [[NSUserDefaults standardUserDefaults] setValue:city.name forKey:@"cityname"];
            [[NSUserDefaults standardUserDefaults] setValue:city.code forKey:@"citycode"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [btn setTitle:city.name forState:UIControlStateNormal];
            // 下载网络数据
//            [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,city.code,@"all",0,0]];
            [self didPullDown:_tableView];
            [UIView animateWithDuration:0.35f animations:^{
                _tableView.contentOffset = CGPointMake(0, 0);
            }];
        }];
        [self.navigationController pushViewController:gvc animated:YES];
    }
}

-(void)hideShakeView:(UITapGestureRecognizer *)tap
{
    if (_shakeView.subviews.count>0)
    {
        [_shakeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_shakeView removeFromSuperview];
        _shakeView = nil;
    }
}

#pragma mark - UITableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1001) // sort
    {
        return [_sortArray count];
    } else if (tableView.tag == 1002) // cate
    {
        return [_cateArray count];
    } else if (tableView.tag == 1003)
    {
        return [_subCateArray count];
    }
    return [_dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        static NSString *cellName = @"customCell";
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        if(_dataArray.count>0)
        {
            PromotionItem *pro = [_dataArray objectAtIndex:indexPath.row];
            [cell.pImageView setImageWithURL:[NSURL URLWithString:pro.imgUrl]];
            cell.nameLabel.text = pro.multiPageTitle;
            cell.priceLabel.text = [NSString stringWithFormat:@"¥%@",pro.currentPrice];
            cell.oldPriceLabel.text = [NSString stringWithFormat:@"¥%@",pro.oldPrice];
            cell.countLabel.text = [NSString stringWithFormat:@"%@人",pro.currentDealCount];
            cell.placeLabel.text = pro.district;
            cell.typeImageView.hidden = (pro.hassub == -1)?YES:NO;
        }
        return cell;
    } else if (tableView.tag == 1001)
    {
        static NSString *cellName = @"sortCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
        int st = [[_userDefaults objectForKey:@"sorttype"] intValue];
        if (st == 0 && indexPath.row == 0) // 默认选中0
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        if ([[[_sortArray objectAtIndex:indexPath.row] objectForKey:@"st"] intValue] == st)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.textLabel.text = [[_sortArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        return cell;
    }
    else if (tableView.tag == 1002)
    {
        static NSString *cellName = @"cateCell";
        CateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[CateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        cell.iconView.image = [UIImage imageNamed:[[_cateArray objectAtIndex:indexPath.row] objectForKey:@"icon"]];
        cell.titleLabel.text = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        return cell;
    }
    else if (tableView.tag == 1003)
    {
        static NSString *cellName = @"cateCell";
        CateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[CateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        cell.titleLabel.text = [[_subCateArray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - PullTableView Delegate
-(void)didLeftBtnClicked:(UIButton *)btn
{
    NSLog(@"左边按钮点击");
    _selectTypeBtn = btn;
    [btn setSelected:!btn.selected];
    [UIView animateWithDuration:0.35f animations:^{
        _tableView.contentOffset = CGPointMake(0, 140);
        [self showShadowView];
        if(_shadowView.subviews.count > 0)
        {
            [_shadowView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        UITableView *cateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 320) style:UITableViewStylePlain];
        cateTableView.delegate = self;
        cateTableView.dataSource = self;
        cateTableView.tag = 1002;
        [_shadowView addSubview:cateTableView];
    }];
}

-(void)didRightBtnClicked:(UIButton *)btn
{
    NSLog(@"右边按钮点击");
    _selectTypeBtn = btn;
    [btn setSelected:!btn.selected];
    [UIView animateWithDuration:0.35f animations:^{
        _tableView.contentOffset = CGPointMake(0, 140);
        [self showShadowView];
        if(_shadowView.subviews.count > 0)
        {
            [_shadowView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        UITableView *sortTableView = [[UITableView alloc] initWithFrame:CGRectMake(160, 0, 160, 160) style:UITableViewStylePlain];
        sortTableView.delegate = self;
        sortTableView.dataSource = self;
        sortTableView.tag = 1001;
        [_shadowView addSubview:sortTableView];
    }];
}

-(void)showShadowView
{
    if (!_shadowView)
    {
        CGRect rect = self.view.bounds;
        rect.origin.y += 40;
        rect.size.height -= 40;
        _shadowView = [[UIView alloc] initWithFrame:rect];
        _shadowView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3];
        [self.view addSubview:_shadowView];
    }
}

-(void)hideShadowView
{
    [UIView animateWithDuration:0.35f animations:^{
        if(_shadowView.subviews.count > 0)
        {
            [_shadowView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            for (int i = 0;i<[_shadowView.subviews count];i++)
            {
                UIView *view = [_shadowView.subviews objectAtIndex:i];
                view = nil;
            }
        }
        [_shadowView removeFromSuperview];
        _shadowView = nil;
    }];
}

-(void)didPullDown:(PullTableView *)tableView
{
    // 下拉刷新
    int st = [[_userDefaults objectForKey:@"sorttype"] intValue];
    [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,_currentCity.code,@"all",0,st]];
    [_dataArray removeAllObjects];
}

-(void)didPullUp:(PullTableView *)tableView
{
    // 上拉刷新
    int st = [[_userDefaults objectForKey:@"sorttype"] intValue];
    [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,_currentCity.code,@"all",_dataArray.count+15,st]];
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    if (tableView.tag == 1002) {
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"firstLabel_bg.png"]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstLabel_bg_selected.png"]];
        cell.selectedBackgroundView = imageView;
    }
    if (tableView.tag == 1003) {
        cell.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.00f];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag != 1002 ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (tableView == _tableView)
    {
        // 跳转到下一页
        PromotionItem *pro = [_dataArray objectAtIndex:indexPath.row];
        if (pro.hassub == -1)
        {
            // 没有列表，直接进入详情页
            ProDetailViewController *pdvc = [[ProDetailViewController alloc] init];
            pdvc.proItem = pro;
            pdvc.isBackBtn = YES;
            [self.navigationController pushViewController:pdvc animated:YES];
        } else if (pro.hassub == 0)
        {
            // 有子列表，进入列表页
            ProListViewController *plvc = [[ProListViewController alloc] init];
            plvc.url = pro.durl;
            plvc.isBackBtn = YES;
            plvc.navigationItem.title = pro.name;
            [self.navigationController pushViewController:plvc animated:YES];
        }
        NSLog(@"pro:%@",pro.durl);
    } else if (tableView.tag == 1001)
    {
        // 排序tableView
        _userDefaults = [NSUserDefaults standardUserDefaults];
        [_userDefaults setValue:[[_sortArray objectAtIndex:indexPath.row] objectForKey:@"st"] forKey:@"sorttype"];
        [_userDefaults synchronize];
        [_selectTypeBtn setTitle:[[_sortArray objectAtIndex:indexPath.row] objectForKey:@"title"] forState:UIControlStateNormal];
        [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,_currentCity.code,@"all",0,[[[_sortArray objectAtIndex:indexPath.row] objectForKey:@"st"] intValue]]];
        // 移除数据源中原有数据
        [_dataArray removeAllObjects];
        [self hideShadowView];
    } else if (tableView.tag == 1002)
    {
        // cateTableView
        if (indexPath.row == 0)
        {
            int st = [[_userDefaults objectForKey:@"sorttype"] intValue];
            NSString *pt = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"pt"];
            [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,_currentCity.code,pt,0,st]];
            [_dataArray removeAllObjects];
            [self hideShadowView];
        } else
        {
            CGFloat height = 40*[[[_cateArray objectAtIndex:indexPath.row] objectForKey:@"items"] count];
            height = height>320?320:height;
            _subCateArray = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"items"];
            if (!_cateSubTableView)
            {
                _cateSubTableView = [[UITableView alloc] initWithFrame:CGRectMake(160, 0, 160, height) style:UITableViewStylePlain];
                _cateSubTableView.delegate = self;
                _cateSubTableView.dataSource = self;
                _cateSubTableView.tag = 1003;
                [_shadowView addSubview:_cateSubTableView];
            } else
            {
                if (_subCateArray.count>0)
                {
                    [_shadowView addSubview:_cateSubTableView];
                    [_cateSubTableView reloadData];
                } else
                {
                    int st = [[_userDefaults objectForKey:@"sorttype"] intValue];
                    NSString *pt = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"pt"];
                    [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,_currentCity.code,pt,0,st]];
                    [_dataArray removeAllObjects];
                    [self hideShadowView];
                }
 
            }
        }
        
    } else if (tableView.tag == 1003)
    {
        int st = [[_userDefaults objectForKey:@"sorttype"] intValue];
        NSString *pt = [[_subCateArray objectAtIndex:indexPath.row] objectForKey:@"pt"];
        [self loadDataWithURL:[NSString stringWithFormat:kHomeURL,_currentCity.code,pt,0,st]];
        [_dataArray removeAllObjects];
        [self hideShadowView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
