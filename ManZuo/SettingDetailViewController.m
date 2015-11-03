//
//  SettingDetailViewController.m
//  ManZuo
//
//  Created by admin on 14-3-8.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "SettingDetailViewController.h"
#import "AboutView.h"
#import "MBProgressHUD.h"

@interface SettingDetailViewController ()<AboutViewDelegate>

@end

@implementation SettingDetailViewController
{
    UITextView *_ideaView;
    UITextField *_phoneField;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isBackBtn = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isBackBtn = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(id)initWithType:(int)type
{
    self = [super init];
    if (self) {
        _type = type;
        self.isBackBtn = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_ideaView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture.png"]];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, 320, 120)];
    bgImageView.image = [UIImage imageNamed:@"listback_main.png"];
    [self.view addSubview:bgImageView];
    if (_type == ABOUT_TYPE) {
        AboutView *aboutView = [[AboutView alloc] initWithFrame:CGRectZero];
        aboutView.delegate = self;
        [self.view addSubview:aboutView];
    } else if (_type == FEEDBACK_TYPE) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50, 30);
        btn.tag = 102;
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_rect.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_rect_pressed.png"] forState:UIControlStateHighlighted];
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(bbiClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 22)];
        label.text = @"您的意见和建议";
        [self.view addSubview:label];
        _ideaView = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 300, 100)];
        _ideaView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"share.png"]];
        [self.view addSubview:_ideaView];
        UILabel *pLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 135, 300, 22)];
        pLabel.text = @"您的联系方式（选填）";
        [self.view addSubview:pLabel];
        _phoneField = [[UITextField alloc] initWithFrame:CGRectMake(10, 160, 300, 35)];
        _phoneField.backgroundColor = [UIColor clearColor];
        _phoneField.background = [UIImage imageNamed:@"share.png"];
        [self.view addSubview:_phoneField];
    } else if (_type == APP_TYPE) {
        
    }
}

-(void)bbiClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    if (_ideaView.text.length > 0) {
        NSLog(@"发送-意见:%@,联系:%@",_ideaView.text,_phoneField.text);
    } else {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.labelText = @"意见和建议不能为空";
        hud.mode = MBProgressHUDModeText;
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:1.0f];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - AboutView Delegate
-(void)aboutView:(AboutView *)aboutView didChackBtnClick:(UIButton *)btn
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"已经是最新版本";
    hud.mode = MBProgressHUDModeText;
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1.0f];
    NSLog(@"检查版本更新");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
