//
//  NearByViewController.m
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "NearByViewController.h"
#import "DownloadManager.h"
#import "PullTableView.h"
#import "CONST.h"
#import "CustomCell.h"
#import "Branch.h"
#import "PromotionItem.h"
#import "UIImageView+WebCache.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomAnnotationView.h"
#import "CustomAnnotation.h"
#import "CateCell.h"
#import "ProDetailViewController.h"
#import "ProListViewController.h"

@interface NearByViewController ()<UITableViewDataSource,UITableViewDelegate,PullTableViewPullDelegate,MKMapViewDelegate,CLLocationManagerDelegate>

@end

@implementation NearByViewController
{
    PullTableView *_tableView;
    NSMutableArray *_dataArray;
    DownloadManager *_dmg;
    MKMapView *_mapView;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _coordinate;
    UIView *_shadowView;
    NSMutableArray *_cateArray;
    NSArray *_subCateArray;
    UITableView *_cateSubTableView;
    NSUserDefaults *_userDefaults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)initNavigationItem
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 50, 30);
    btn.tag = 101;
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_rect.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_rect_pressed.png"] forState:UIControlStateHighlighted];
    [btn setTitle:@"筛选" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 50, 30);
    btn1.tag = 102;
    btn1.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rect.png"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rect_pressed.png"] forState:UIControlStateHighlighted];
    [btn1 setTitle:@"列表" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigationItem];
    _dataArray = [[NSMutableArray alloc] init];
    // 初始化分类数据
    NSString *path = [NSString stringWithFormat:@"%@/NearByCategory.plist",[[NSBundle mainBundle] resourcePath]];
    _cateArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    // 开启定位
    [self startLocation];
    // 显示tableView
    [self showTableView];
    UIButton *localBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localBtn.frame = CGRectMake(270, 320, 41, 41);
    [localBtn setBackgroundImage:[UIImage imageNamed:@"map_loc.png"] forState:UIControlStateNormal];
    localBtn.tag = 201;
    [localBtn addTarget:self action:@selector(mapBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localBtn];
    // 是否是首次进入
    NSInteger homeCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"visitnearcount"];
    [[NSUserDefaults standardUserDefaults] setInteger:homeCount forKey:@"visitnearcount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (homeCount == 0)
    {
        // 首次进入，加入引导视图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
        imageView.image = [UIImage imageNamed:@"guideNear.png"];
        imageView.userInteractionEnabled = YES;
        [self.tabBarController.view addSubview:imageView];
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapAction:)];
        imageTap.numberOfTapsRequired = 1;
        imageTap.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:imageTap];
        homeCount ++;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:homeCount forKey:@"visitnearcount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)imageTapAction:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    [imageView removeFromSuperview];
    imageView = nil;
}

-(void)startLocation
{
    if ([CLLocationManager locationServicesEnabled])
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        [_locationManager setDelegate:self];
        // 开启定位
        [_locationManager startUpdatingLocation];
    } else
    {
        [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,@"1,2,3,4,6",0,@"40.034392",@"116.344664"]];
    }
}

#pragma mark - CLLocationManager Delegate
// 定位成功
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    _coordinate = [[locations objectAtIndex:0] coordinate];
	MKCoordinateSpan span = {0.05,0.05};
    //设置显示区域
    [_mapView setRegion:MKCoordinateRegionMake(_coordinate, span) animated:YES];
    NSString *lon = [NSString stringWithFormat:@"%f",_coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",_coordinate.latitude];
    // 下载网络数据
    [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,@"1,2,3,4,6",0,lat,lon]];
}

#pragma mark - MKAnnotationView delegate
//创建annotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *identify = @"CustomAnnotationView";
    CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identify];
    if(annotationView == nil)
    {
        annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identify];
    }
    // 显示详细信息
    annotationView.canShowCallout = YES;
    return annotationView;
}

//AnnotationView添加到mapView后调用,实现放大弹出动画效果
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *annotationView in views) {
        CGAffineTransform tranform = annotationView.transform;
        annotationView.transform = CGAffineTransformScale(tranform, 0.7, 0.7);
        annotationView.alpha = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            //动画1 0.7-1.2
            annotationView.transform = CGAffineTransformScale(tranform, 1.2, 1.2);
            annotationView.alpha = 1;
        } completion:^(BOOL finished) {
            //动画2 1.2-1.0
            annotationView.transform = CGAffineTransformIdentity;
        }];
        
    }
}

//选中AnnotationView后，push到详情
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    CustomAnnotation *customAnnotation = view.annotation;
    // 如果是自己的位置则不调到下一级
    if ([customAnnotation isKindOfClass:[MKUserLocation class]]) {
        return ;
    }
    Branch *bra = nil;
    if ([customAnnotation isKindOfClass:[CustomAnnotation class]]) {
        bra = customAnnotation.branch;
    }
    // 跳转到下一页
    PromotionItem *pro = bra.promotion;
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
        plvc.title = bra.branchName;
        [self.navigationController pushViewController:plvc animated:YES];
    }
    NSLog(@"pro:%@",pro.durl);
}

#pragma mark - UI
-(void)showTableView
{
    if (!_tableView)
    {
        _tableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
        _tableView.type = DEFAULTCELL;
        _tableView.dataSource = self;
        _tableView.pullDelegate = self;
        _tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
        [self.view addSubview:_tableView];
    }
}

-(void)hideTableView
{
    if (_tableView)
    {
        [_tableView removeFromSuperview];
        _tableView = nil;
    }
}

-(void)showMapView
{
    if (!_mapView)
    {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64)];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        _mapView.delegate = self;
        [self.view addSubview:_mapView];
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        moreBtn.frame = CGRectMake(111, 320, 97, 41);
        [moreBtn setBackgroundImage:[UIImage imageNamed:@"map_more.png"] forState:UIControlStateNormal];
        [moreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        moreBtn.tag = 202;
        [moreBtn addTarget:self action:@selector(mapBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_mapView addSubview:moreBtn];
        // 把定位按钮显示出来
        [self.view bringSubviewToFront:[self.view viewWithTag:201]];
        // 设置中心点经纬度
        CLLocationCoordinate2D center;
        center.latitude = 40.029997;
        center.longitude = 116.346653;
        // 设置精度
        MKCoordinateSpan span;
        span.latitudeDelta = 0.05;
        span.longitudeDelta = 0.05;
        // 设置区域
        MKCoordinateRegion region;
        region.center = _coordinate;
        region.span = span;
        [_mapView setRegion:region animated:YES];
        for (int i=0;i<_dataArray.count;i++) {
            Branch *branch = [_dataArray objectAtIndex:i];
            // 创建Annotation对象，添加到地图上去
            CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithBranch:branch];
            // 延时调用addAnnotation方法，实现一个一个弹出动画效果
            [_mapView performSelector:@selector(addAnnotation:) withObject:customAnnotation afterDelay:i*0.05];
        }
    }
}

-(void)hideMapView
{
    if (_mapView)
    {
        [_mapView removeFromSuperview];
        _mapView = nil;
    }
}

-(void)showShadowView
{
    if (!_shadowView)
    {
        CGRect rect = self.view.bounds;
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

#pragma mark - Data
-(void)loadDataWithURL:(NSString *)url
{
    if ([[DownloadManager sharedDownloadManager] haveNet])
    {
        [self showHUDView];
        _dmg = [DownloadManager sharedDownloadManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdate:) name:url object:nil];
        [_dmg addDownLoadWithURL:url andType:cBranchList];
    }
}

-(void)dataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    NSArray *dataArray = [_dmg loadDataWithUrl:not.name];
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    if (_dataArray.count>0)
    {
        for (int i = 0;i <[dataArray count];i++)
        {
            Branch *bra = [dataArray objectAtIndex:i];
            for (int j = 0;j<[_dataArray count];j++)
            {
                Branch *oldBra = [_dataArray objectAtIndex:j];
                if (bra.branchId != oldBra.branchId)
                {
                    [_dataArray addObject:bra];
                    [newData addObject:bra];
                    break;
                }
            }
        }
    } else
    {
        [_dataArray addObjectsFromArray:dataArray];
    }

    if (_tableView)
    {
        [_tableView reloadData];
    } else if (_mapView)
    {
        for (int i=0;i<newData.count;i++) {
            Branch *branch = [newData objectAtIndex:i];
            // 创建Annotation对象，添加到地图上去
            CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithBranch:branch];
            // 延时调用addAnnotation方法，实现一个一个弹出动画效果
            [_mapView performSelector:@selector(addAnnotation:) withObject:customAnnotation afterDelay:i*0.05];
        }
    }
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


#pragma mark - Actions
-(void)mapBtnClick:(UIButton *)btn
{
    if (btn.tag == 201)
    {
        // 定位
        [self startLocation];
    } else if (btn.tag == 202)
    {
        // 显示更多
        [self didPullUp:_tableView];
    }
}

-(void)btnClick:(UIButton *)btn
{
    if (btn.tag == 101)
    {
        // 筛选
        [btn setSelected:!btn.selected];
        [UIView animateWithDuration:0.35f animations:^{
            _tableView.contentOffset = CGPointMake(0, 0);
            [self showShadowView];
            if(_shadowView.subviews.count > 0)
            {
                [_shadowView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            UITableView *cateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 240) style:UITableViewStylePlain];
            cateTableView.delegate = self;
            cateTableView.dataSource = self;
            cateTableView.tag = 1002;
            [_shadowView addSubview:cateTableView];
        }];
    } else if (btn.tag == 102)
    {
        // 列表/地图切换
        NSString *title = [[btn currentTitle]isEqualToString:@"地图"]?@"列表":@"地图";
        [btn setTitle:title forState:UIControlStateNormal];
        if ([btn.currentTitle isEqualToString:@"地图"])
        {
            [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    		} completion:NULL];
            [self showMapView];
            [self hideTableView];
        }
        if ([btn.currentTitle isEqualToString:@"列表"])
        {
            [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    		} completion:NULL];
            [self showTableView];
            [self hideMapView];
        }
    }
}

#pragma mark - UITableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1002) // cate
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
        static NSString *cellName = @"cell";
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil) {
            cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
        }
        Branch *bra = [_dataArray objectAtIndex:indexPath.row];
        PromotionItem *pro = bra.promotion;
        [cell.pImageView setImageWithURL:[NSURL URLWithString:pro.wsdimgUrl]];
        cell.nameLabel.text = pro.multiPageTitle;
        cell.priceLabel.text = [NSString stringWithFormat:@"¥%@",pro.currentPrice];
        cell.oldPriceLabel.text = [NSString stringWithFormat:@"¥%@",pro.oldPrice];
        cell.countLabel.text = [NSString stringWithFormat:@"%@人",pro.currentDealCount];
        cell.placeLabel.text = pro.district;
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
-(void)didPullDown:(PullTableView *)tableView
{
    // 下拉刷新
    [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,@"1,2,3,4,6",0,@"40.034392",@"116.344664"]];
    // 如果是下拉刷新,删除数据源中数据
    [_dataArray removeAllObjects];
}

-(void)didPullUp:(PullTableView *)tableView
{
    // 上拉刷新
    [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,@"1,2,3,4,6",_dataArray.count+15,@"40.034392",@"116.344664"]];
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
        Branch *bra = [_dataArray objectAtIndex:indexPath.row];
        PromotionItem *pro = bra.promotion;
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
            plvc.title = bra.branchName;
            [self.navigationController pushViewController:plvc animated:YES];
        }
        NSLog(@"pro:%@",pro.durl);
    } else if (tableView.tag == 1002)
    {
        if (indexPath.row == 0)
        {
            NSString *pt = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"pt"];
            NSString *lon = [NSString stringWithFormat:@"%f",_coordinate.longitude];
            NSString *lat = [NSString stringWithFormat:@"%f",_coordinate.latitude];
            // 下载网络数据
            [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,pt,0,lat,lon]];
            [_dataArray removeAllObjects];
            [self hideShadowView];
        } else
        {
            CGFloat height = 40*[[[_cateArray objectAtIndex:indexPath.row] objectForKey:@"items"] count];
            height = height>320?320:height;
            _subCateArray = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"items"];
            if (!_cateSubTableView && _subCateArray.count > 0)
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
                    NSString *pt = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"pt"];
                    NSString *lon = [NSString stringWithFormat:@"%f",_coordinate.longitude];
                    NSString *lat = [NSString stringWithFormat:@"%f",_coordinate.latitude];
                    // 下载网络数据
                    [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,pt,0,lat,lon]];
                    [_dataArray removeAllObjects];
                    [self hideShadowView];
                }
                
            }
        }
        
    } else if (tableView.tag == 1003)
    {
        NSString *pt = [[_cateArray objectAtIndex:indexPath.row] objectForKey:@"pt"];
        NSString *lon = [NSString stringWithFormat:@"%f",_coordinate.longitude];
        NSString *lat = [NSString stringWithFormat:@"%f",_coordinate.latitude];
        // 下载网络数据
        [self loadDataWithURL:[NSString stringWithFormat:kBranchListURL,pt,0,lat,lon]];
        [_dataArray removeAllObjects];
        [self hideShadowView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
