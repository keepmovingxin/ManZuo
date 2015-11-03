//
//  LoginViewController.m
//  ManZuo
//
//  Created by admin on 14-3-8.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    UITextField *_accField;
    UITextField *_pswField;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(id)initWithType:(int)type
{
    self = [super init];
    if (self) {
        _type = type;
        self.title = (_type==LOGIN_TYPE)?@"登录":@"注册";
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
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 50, 30);
    btn1.tag = 102;
    btn1.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rect.png"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rect_pressed.png"] forState:UIControlStateHighlighted];
    NSString *title = (_type==LOGIN_TYPE)?@"注册":@"登录";
    [btn1 setTitle:title forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)btnClick:(UIButton *)btn
{
    if (btn.tag == 101) {
        // 取消
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else if (btn.tag == 102)
    {
        if (_type==LOGIN_TYPE) {
            // 切换到注册
            LoginViewController *rvc = [[LoginViewController alloc] initWithType:REGISTER_TYPE];
            UINavigationController *rnav = [[UINavigationController alloc] initWithRootViewController:rvc];
            rvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:rnav animated:YES completion:^{
                
            }];
        } else if (_type==REGISTER_TYPE) {
            // 切换到登录
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

-(void)initSubViews
{
    //cell_up.png
    _accField = [[UITextField alloc] initWithFrame:CGRectMake(9, 10, 302, 47)];
    _accField.background = [UIImage imageNamed:@"cell_up.png"];
    UILabel *accLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 47)];
    NSString *text = (_type==LOGIN_TYPE)?@" 账号:":@" 邮箱:";
    accLabel.text = text;
    accLabel.font = [UIFont systemFontOfSize:20.0f];
    _accField.leftView = accLabel;
    _accField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_accField];
    _pswField = [[UITextField alloc] initWithFrame:CGRectMake(9, 57, 302, 47)];
    _pswField.background = [UIImage imageNamed:@"cell_up.png"];
    UILabel *pswLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 47)];
    pswLabel.text = @" 密码:";
    pswLabel.font = [UIFont systemFontOfSize:20.0f];
    _pswField.leftView = pswLabel;
    _pswField.leftViewMode = UITextFieldViewModeAlways;
    _pswField.secureTextEntry = YES;
    [self.view addSubview:_pswField];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(9, 130, 302, 47);
    btn.tag = 201;
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btn setBackgroundImage:[UIImage imageNamed:@"submit_btn.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"submit_btn_press.png"] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:self.title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    if (_type==LOGIN_TYPE) {
        UIButton *sinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sinaBtn.frame = CGRectMake(9, 200, 302, 47);
        sinaBtn.tag = 202;
        sinaBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [sinaBtn setBackgroundImage:[UIImage imageNamed:@"cell_up.png"] forState:UIControlStateNormal];
        [sinaBtn setBackgroundImage:[UIImage imageNamed:@"cell_pressed.png"] forState:UIControlStateHighlighted];
        [sinaBtn setImage:[UIImage imageNamed:@"sina_weibo_login.png"] forState:UIControlStateNormal];
        sinaBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [sinaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sinaBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        sinaBtn.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
        [sinaBtn setTitle:@"新浪微博登录" forState:UIControlStateNormal];
        [sinaBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sinaBtn];
    }
}

-(void)buttonClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    if (btn.tag == 201) {
        // 登录|注册操作
        if (_type == LOGIN_TYPE) {
            NSLog(@"登录name:%@,psw:%@",_accField.text,_pswField.text);
        } else if (_type == REGISTER_TYPE) {
            // 先判断邮箱
            NSLog(@"注册name:%@,psw:%@",_accField.text,_pswField.text);
        }
    } else if (btn.tag == 202) {
        // 新浪微博登录
        NSLog(@"新浪微博登录");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.98f alpha:1.00f];
    [self initNavigationItem];
    [self initSubViews];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
