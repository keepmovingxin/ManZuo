//
//  ProductViewController.m
//  ManZuo
//
//  Created by admin on 14-3-11.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "ProductViewController.h"
#import "ToolView.h"
#import "BuyViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "MBProgressHUD.h"

@interface ProductViewController ()<ToolViewDelegate>

@end

@implementation ProductViewController
{
    ToolView *_toolView;
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
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 50, 30);
    btn1.tag = 102;
    btn1.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rect.png"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rect_pressed.png"] forState:UIControlStateHighlighted];
    [btn1 setTitle:@"分享" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(bbiClick:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)bbiClick:(UIButton *)btn
{
    // Share SDK
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:_proItem.intro
                                       defaultContent:_proItem.multiPageTitle
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:_proItem.name
                                                  url:_proItem.promotionurl
                                          description:_proItem.district
                                            mediaType:SSPublishContentMediaTypeNews];
    // 显示分享sheet内容
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                                    hud.labelText = @"分享成功";
                                    hud.mode = MBProgressHUDModeText;
                                    [self.view addSubview:hud];
                                    [hud show:YES];
                                    [hud hide:YES afterDelay:1.0f];
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    NSLog(@"分享");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigationItem];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-49-64)];
    if (_type == PROMOTION_TYPE) {
        [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_proItem.descurl]]];
    } else if (_type == BRACH_TYPE) {
        [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_proItem.promotionurl]]];
    }
    [self.view addSubview:webView];
    _toolView  = [[ToolView alloc] initWithFrame:CGRectZero];
    _toolView.frame = CGRectMake(0, 480-64-44, 320, 44);
    _toolView.delegate = self;
    _toolView.clipsToBounds = NO;
    [self.view addSubview:_toolView];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
}

-(void)updateTime:(NSTimer *)timer
{
    _toolView.timeLabel.text = [self getTimeWithString:_proItem.endTime];
}

#pragma mark - ToolView Delegate
-(void)toolView:(ToolView *)toolView didBtnClick:(UIButton *)btn
{
    // 跳转到购买界面
    BuyViewController *bvc = [[BuyViewController alloc] init];
    bvc.isBackBtn = YES;
    bvc.proItem = _proItem;
    [self.navigationController pushViewController:bvc animated:YES];
}

-(NSString *)getTimeWithString:(NSString *)expireDatetime
{
    //    ex = 2014-02-19 22:44:19.0
    //    date = str:1970-01-01 01:07:38 +0000
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localZone];
    //en_US 默认 zh_CN 中国
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.0"];
    NSDate *mDate = [dateFormatter dateFromString:expireDatetime];
    NSDate *curDate = [NSDate date];
    NSTimeInterval va = [mDate timeIntervalSinceDate:curDate];
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:va];
    NSString *str = [lastDate description];
    NSArray *arr = [str componentsSeparatedByString:@" "];
    NSString *dayStr = arr[0];
    NSArray *dayArray = [dayStr componentsSeparatedByString:@"-"];
    int days = ([[dayArray objectAtIndex:1] intValue]-1)*30+[[dayArray objectAtIndex:2] intValue];
    NSString *hourStr = arr[1];
    NSArray *hourArray = [hourStr componentsSeparatedByString:@":"];
    NSString *hours = [NSString stringWithFormat:@"%d时%d分%d秒",[hourArray[0] intValue],[hourArray[1] intValue],[hourArray[2] intValue]];
    NSString *lastStr=[NSString stringWithFormat:@"%d天 %@",days,hours];
    
    return lastStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
