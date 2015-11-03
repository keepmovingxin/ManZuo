//
//  BaseViewController.m
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
{
    MBProgressHUD *_hudView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showHUDView
{
    if (!_hudView)
    {
        _hudView = [[MBProgressHUD alloc] initWithView:self.view];
        _hudView.labelText = @"加载中...";
        _hudView.mode = MBProgressHUDModeIndeterminate;
        [self.view addSubview:_hudView];
        [_hudView show:YES];
        [self.view bringSubviewToFront:_hudView];
    }
}

-(void)hideHUDView
{
    if(_hudView)
    {
        _hudView.removeFromSuperViewOnHide = YES;
        [_hudView hide:YES];
        _hudView = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bar.png"] forBarMetrics:UIBarMetricsDefault];
    if (self.navigationItem.title.length > 0)
    {
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        titleView.textColor = [UIColor whiteColor];
        titleView.font = [UIFont boldSystemFontOfSize:22.0f];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.text = self.navigationItem.title;
        titleView.layer.shadowRadius = 2.0f;
        titleView.layer.shadowColor = [UIColor blackColor].CGColor;
        titleView.lineBreakMode = NSLineBreakByClipping;
        titleView.adjustsFontSizeToFitWidth = YES;
        self.navigationItem.titleView = titleView;
    }
    if (_isBackBtn)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50, 30);
        btn.tag = 101;
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_short.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_short_pressed.png"] forState:UIControlStateHighlighted];
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [btn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
}

-(void)goBack:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
