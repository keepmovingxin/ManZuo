//
//  ProDetailViewController.m
//  ManZuo
//
//  Created by admin on 14-3-6.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "ProDetailViewController.h"
#import "DownloadManager.h"
#import "CONST.h"
#import "DetailView.h"
#import "ToolView.h"
#import "UIImageView+WebCache.h"
#import "BuyViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "MBProgressHUD.h"
#import "ProductViewController.h"

@interface ProDetailViewController ()<DetailViewDelegate,ToolViewDelegate,UIActionSheetDelegate>

@end

@implementation ProDetailViewController
{
    DownloadManager *_dmg;
    DetailView *_detailView;
    ToolView *_toolView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"商品介绍";
        self.hidesBottomBarWhenPushed = YES;
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture.png"]];
    if (!(_proItem.durl == nil)) {
        // 下载网络数据
        [self loadDataWithURL:_proItem.durl];
    }
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64-44)];
    scrollView.delaysContentTouches = NO;
    _detailView = [[DetailView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64-44)];
    _detailView.backgroundColor = [UIColor clearColor];
    _detailView.delegate = self;
    [scrollView addSubview:_detailView];
    scrollView.contentSize = CGSizeMake(320, _detailView.frame.size.height);
    [self.view addSubview:scrollView];
    _toolView  = [[ToolView alloc] initWithFrame:CGRectZero];
    _toolView.frame = CGRectMake(0, 480-64-44, 320, 44);
    _toolView.delegate = self;
    _toolView.clipsToBounds = NO;
    [self.view addSubview:_toolView];
    [_detailView.proImageView setImageWithURL:[NSURL URLWithString:_proItem.wsdimgUrl] placeholderImage:[UIImage imageNamed:@"img_bg.png"]];
    _detailView.priceLabel.adjustsFontSizeToFitWidth = YES;
    _detailView.priceLabel.text = [NSString stringWithFormat:@"¥%@",_proItem.currentPrice];
    _detailView.oldPriceLabel.text = [NSString stringWithFormat:@"¥%@",_proItem.oldPrice];
    _detailView.countLabel.text = [NSString stringWithFormat:@"%@人购买",_proItem.currentDealCount];
    _detailView.descLabel.numberOfLines = 2;
    _detailView.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _detailView.descLabel.text = _proItem.intro;
    [_detailView.actWebView loadHTMLString:_proItem.fineprint baseURL:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
}

-(void)updateTime:(NSTimer *)timer
{
    _toolView.timeLabel.text = [self getTimeWithString:_proItem.endTime];
}

#pragma mark - Data
-(void)loadDataWithURL:(NSString *)url
{
    if (url.length == 0)
    {
        [self dataUpdate:nil];
    } else
    {
        if ([[DownloadManager sharedDownloadManager] haveNet])
        {
            [self showHUDView];
            _dmg = [DownloadManager sharedDownloadManager];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdate:) name:url object:nil];
            [_dmg addDownLoadWithURL:url andType:cProDetail];
        }
    }
}

-(void)dataUpdate:(NSNotification *)not
{
    [self hideHUDView];
    NSArray *dataArray = [_dmg loadDataWithUrl:not.name];
    PromotionItem *pro = [dataArray lastObject];
    _proItem = pro;
    [_detailView.proImageView setImageWithURL:[NSURL URLWithString:pro.wsdimgUrl] placeholderImage:[UIImage imageNamed:@"img_bg.png"]];
    _detailView.priceLabel.text = [NSString stringWithFormat:@"¥%@",pro.currentPrice];
    _detailView.oldPriceLabel.text = [NSString stringWithFormat:@"¥%@",pro.oldPrice];
    _detailView.countLabel.text = [NSString stringWithFormat:@"%@人购买",pro.currentDealCount];
    _detailView.descLabel.numberOfLines = 2;
    _detailView.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _detailView.descLabel.text = pro.intro;
    [_detailView.actWebView loadHTMLString:pro.fineprint baseURL:nil];
    _toolView.timeLabel.text = [self getTimeWithString:pro.endTime];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:not.name object:nil];
}

#pragma mark - DetailView Delegate
-(void)detailView:(DetailView *)detailView didBtnClick:(UIButton *)btn
{
    ProductViewController *pvc = [[ProductViewController alloc] init];
    pvc.isBackBtn = YES;
    pvc.proItem = _proItem;
    if (btn.tag == 101)
    {
        //商户详情
        pvc.title = @"商户详情";
        pvc.type = BRACH_TYPE;
    } else if (btn.tag == 102)
    {
        //商品详情
        pvc.title = @"商品详情";
        pvc.type = PROMOTION_TYPE;
    }
    [self.navigationController pushViewController:pvc animated:YES];

    NSLog(@"%i",btn.tag);
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
