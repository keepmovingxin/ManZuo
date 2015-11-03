//
//  MainViewController.m
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "NearByViewController.h"
#import "SearchViewController.h"
#import "SettingViewController.h"
#import "CustomTabBar.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    // 隐藏系统tabBar
//    [self.tabBar setHidden:YES];
//    NSArray *titles = [[NSArray alloc] initWithObjects:@"首页",@"周边",@"搜索",@"我的满座", nil];
//    NSArray *images = [[NSArray alloc] initWithObjects:
//                       @"main.png",@"around.png",
//                       @"search.png",@"myManzuo.png",nil];
//    NSArray *selectImages = [[NSArray alloc] initWithObjects:
//                             @"main.png",@"around.png",
//                             @"search.png",@"myManzuo.png",nil];
//    
//    CustomTabBar *ctb = [[CustomTabBar alloc] initWithFrame:CGRectMake(0, 480-49, 320, 49)];
//    [ctb createTabBarWithBackgroundImage:@"tabbar_bg.png" andButtonsImageName:images andButtonsSelectedImageName:selectImages andButtonsTitle:titles andSEL:@selector(btnClick:) andClass:self];
//    [self.view addSubview:ctb];
//    _tabBarView = ctb;
//    
//    // 设置默认选中选项卡
//    UIView *view = [ctb.subviews objectAtIndex:1];
//    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabBar_Slider.png"]];
//    UIButton *btn = (UIButton *)[view.subviews objectAtIndex:0];
//    [btn setSelected:YES];
//    UILabel *label = (UILabel *)[view.subviews objectAtIndex:1];
//    label.textColor = [UIColor colorWithRed:0.248f green:0.75f blue:1.00f alpha:1.00f];
    self.tabBar.barStyle = UIBarStyleBlack;
    self.tabBar.backgroundColor = [UIColor blackColor];
    // 初始化视图控制器
    [self initSubCtrls];
    
}

-(void)initSubCtrls
{
    HomeViewController *hvc = [[HomeViewController alloc] init];
    UINavigationController *hnav = [[UINavigationController alloc] initWithRootViewController:hvc];
    hvc.tabBarItem.image = [UIImage imageNamed:@"main.png"];
    hvc.tabBarItem.title = @"首页";
    NearByViewController *nbvc = [[NearByViewController alloc] init];
    UINavigationController *nbnav = [[UINavigationController alloc] initWithRootViewController:nbvc];
    nbvc.navigationItem.title = @"周边全部团购";
    nbvc.tabBarItem.image = [UIImage imageNamed:@"around.png"];
    nbvc.tabBarItem.title = @"周边";
    SearchViewController *svc = [[SearchViewController alloc] init];
    UINavigationController *snav = [[UINavigationController alloc] initWithRootViewController:svc];
    svc.navigationItem.title = @"团购搜索";
    svc.tabBarItem.image = [UIImage imageNamed:@"search.png"];
    svc.tabBarItem.title = @"搜索";
    SettingViewController *stvc = [[SettingViewController alloc] init];
    UINavigationController *stnav = [[UINavigationController alloc] initWithRootViewController:stvc];
    stvc.navigationItem.title = @"我的满座";
    stvc.tabBarItem.image = [UIImage imageNamed:@"myManzuo.png"];
    stvc.tabBarItem.title = @"我的满座";
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:hnav,nbnav,snav,stnav, nil];
    self.viewControllers = viewControllers;
}

//#pragma mark - tabbar btnClick
//-(void)btnClick:(UIButton *)btn
//{
//    // 将所有的btn和label的颜色都变成未选中
//    // 1.得到整个tabBarView
//    UIView *tabBarView = btn.superview.superview;
//    // 2.通过遍历得到所有的itemView
//    for (UIView *view in tabBarView.subviews) {
//        if (![view isKindOfClass:[UIImageView class]]) {
//            view.backgroundColor = [UIColor clearColor];
//            // 取得itemView上的btn
//            UIButton *btn = (UIButton *)[view.subviews objectAtIndex:0];
//            [btn setSelected:NO];
//            UILabel *label = (UILabel *)[view.subviews objectAtIndex:1];
//            label.textColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1.00f];
//        }
//    }
//    
//    // 设置点击的item的btn和label
//    [btn setSelected:!btn.selected];
//    UIView *itemView = [btn superview];
//    // 设置选中背景图
//    itemView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabBar_Slider.png"]];
//    UILabel *label = (UILabel *)[[itemView subviews] objectAtIndex:1];
//    if (btn.selected) {
//        label.textColor = [UIColor colorWithRed:0.248f green:0.75f blue:1.00f alpha:1.00f];
//    } else {
//        label.textColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1.00f];
//    }
//    
//    self.selectedViewController = [self.viewControllers objectAtIndex:btn.tag];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
