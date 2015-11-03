//
//  SettingViewController.m
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"
#import "SettingDetailViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@end

@implementation SettingViewController
{
    UITableView *_tableView;
    NSArray *_dataArray;
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
    NSString *path = [NSString stringWithFormat:@"%@/Setting.plist",[[NSBundle mainBundle] resourcePath]];
	_dataArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49-20) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataArray objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.textLabel.text = @"";
        NSArray *titles = [[[_dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] componentsSeparatedByString:@","];
        for (int i = 0; i<[titles count]; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.cornerRadius = 5.0f;
            btn.layer.masksToBounds = YES;
            btn.frame = CGRectMake(12.5+102.5*i, 5, 90, 50);
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:0.30f green:0.62f blue:0.85f alpha:1.00f] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            btn.tag = 1000+i;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
        }
    } else
    {
        for (UIView *view in cell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                [view removeFromSuperview];
            }
        }
        cell.textLabel.text = [[_dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"账户信息";
    } else if (section == 1)
    {
        return @"设置";
    } else if (section == 2)
    {
        return @"软件信息";
    }
    return nil;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        return 60.0f;
    }
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else
    {
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 302, 44)];
        bgView.image = [UIImage imageNamed:@"cell_up.png"];
            cell.backgroundView = bgView;
        UIImageView *sbgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 302, 44)];
        sbgView.image = [UIImage imageNamed:@"cell_pressed.png"];
        cell.selectedBackgroundView = sbgView;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        NSLog(@"登录|注册");
        LoginViewController *lvc = [[LoginViewController alloc] initWithType:LOGIN_TYPE];
        UINavigationController *lnav = [[UINavigationController alloc] initWithRootViewController:lvc];
        [self presentViewController:lnav animated:YES completion:^{
            
        }];
    } else if (indexPath.section == 1)
    {
        SettingDetailViewController *sdvc = [[SettingDetailViewController alloc] init];
        if (indexPath.row == 0)
        {
            NSLog(@"收货地址");
            sdvc.title = @"收货地址";
            [self.navigationController pushViewController:sdvc animated:YES];
        } else if (indexPath.row == 1)
        {
            NSLog(@"同步设置");
            sdvc.title = @"同步设置";
            [self.navigationController pushViewController:sdvc animated:YES];
        } else if (indexPath.row == 2)
        {
            NSLog(@"系统设置");
            sdvc.title = @"系统设置";
            [self.navigationController pushViewController:sdvc animated:YES];
        }
    } else if (indexPath.section == 2)
    {
        SettingDetailViewController *sdvc = [[SettingDetailViewController alloc] init];
        if (indexPath.row == 0)
        {
            NSLog(@"喜欢满座");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/man-zuo-tuan-gou-you-xiang/id460351323?mt=8"]];
        } else if (indexPath.row == 1)
        {
            NSLog(@"关于满座");
            sdvc.type = ABOUT_TYPE;
            sdvc.title = @"关于满座";
            [self.navigationController pushViewController:sdvc animated:YES];
        } else if (indexPath.row == 2)
        {
            NSLog(@"意见反馈");
            sdvc.type = FEEDBACK_TYPE;
            sdvc.title = @"意见反馈";
            [self.navigationController pushViewController:sdvc animated:YES];
        } else if (indexPath.row == 3)
        {
            NSLog(@"满座客服");
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"呼叫4006-858-666" otherButtonTitles:@"客服在线时间：每日9:00-19:00", nil];
            [sheet showInView:self.tabBarController.view];
        } else if (indexPath.row == 4)
        {
            NSLog(@"应用推荐");
            sdvc.type = APP_TYPE;
            sdvc.title = @"应用推荐";
            [self.navigationController pushViewController:sdvc animated:YES];
        }
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"呼叫4006-858-666");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt:400685866"]];
    } else if (buttonIndex == 1)
    {
        NSLog(@"客服在线时间：每日9:00-19:00");
    } else if (buttonIndex == 1)
    {
        NSLog(@"取消");
    }
}

#pragma mark - UIButton Action
-(void)btnClick:(UIButton *)btn
{
    LoginViewController *lvc = [[LoginViewController alloc] initWithType:LOGIN_TYPE];
    UINavigationController *lnav = [[UINavigationController alloc] initWithRootViewController:lvc];
    if (btn.tag == 1000)
    {
        //订单
        NSLog(@"订单");
    } else if (btn.tag == 1001)
    {
        //满座券
        NSLog(@"满座券");
    } else if (btn.tag == 1002)
    {
        //折扣券
        NSLog(@"折扣券");
    }
    [self presentViewController:lnav animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
