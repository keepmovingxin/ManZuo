//
//  DownloadManager.m
//  DownloadS
//
//  Created by student on 14-2-20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "DownloadManager.h"
#import "Download.h"
#import "CONST.h"
#import "GDataXMLNode.h"
#import "PromotionItem.h"
#import "ActivityItem.h"
#import "City.h"
#import "Branch.h"
#import "Reachability.h"
#import "MZDataBase.h"

@implementation DownloadManager
{
    // 用来保存所有正在下载的任务
    NSMutableDictionary *_taskDict;
    // 保存所有下载结果
    NSMutableDictionary *_resultDict;
}

- (id)init
{
    self = [super init];
    if (self) {
        _taskDict = [[NSMutableDictionary alloc] init];
        _resultDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

static DownloadManager *_sharedDownloadManager;
+(DownloadManager *)sharedDownloadManager
{
    if (!_sharedDownloadManager) {
        _sharedDownloadManager = [[[self class] alloc] init];
    }
    return _sharedDownloadManager;
}

- (BOOL)haveNet
{
    if (![[Reachability reachabilityForInternetConnection] isReachableViaWWAN] && ![[Reachability reachabilityForInternetConnection] isReachableViaWiFi])
    {
        return NO;
    }
    else
        return YES;
}

-(void)addDownLoadWithURL:(NSString *)url andType:(int)type
{
    // 判断要下载的东西是否已经正在下载了(下载任务已经存在下载任务字典中)
    Download *download = [_taskDict objectForKey:url];

    if (!download) {
        NSLog(@"创建新的下载任务,去下载!");
        // 去下载
        Download *newdl = [[Download alloc] init];
        newdl.delegate = self;
        newdl.downloadURL = url;
        newdl.type = type;
        [newdl downloadData];
        // 将下载任务存入字典_taskDict
        [_taskDict setObject:newdl forKey:url];
    } else {
        NSLog(@"下载任务已存在,无需下载");
    }
    
}

#pragma mark - Download Delegate
-(void)downloadFinishWithClass:(id)download
{
    NSLog(@"回调方法downloadFinishWithClass执行~");
    Download *dl = download;
    // 解析数据
    if (dl.type == cProductList)
    {
        // 解析列表
        [self praseProsListWithClass:dl];
    }
    else if (dl.type == cProDetailHasSub)
    {
        // 解析详情(带SubList)
        [self praseDetailHasSubWithClass:dl];
    }
    else if (dl.type == cProDetail)
    {
        // 解析详情
        [self praseDetailWithClass:dl];
    }
    else if (dl.type == cActivity)
    {
        // 解析活动
        [self prasecActivitysWithClass:dl];
    }
    else if (dl.type == cCityList)
    {
        // 解析城市列表
        [self prasecCityListWithClass:dl];
    }
    else if (dl.type == cActivityDetail)
    {
        // 解析活动详情列表
        [self praseActivityDetailWithClass:dl];
    }
    else if (dl.type == cBranchList)
    {
        // 解析周边列表
        [self praseBranchListWithClass:dl];
    }
    else if (dl.type == cHotKey)
    {
        [self praseHotKeysWithClass:dl];
    } else if (dl.type == cPreKey)
    {
        [self prasePreKeysWithClass:dl];
    } else if (dl.type == cSearch)
    {
        [self praseSearchWithClass:dl];
    }
    // 从下载任务字典中去掉当前下载任务
    [_taskDict removeObjectForKey:dl.downloadURL];
}

-(NSArray *)loadDataWithUrl:(NSString *)url
{
    return [_resultDict objectForKey:url];
}

-(void)saveDataWithData:(NSMutableArray *)dataArray andURL:(NSString *)url
{
    // 将数据保存到数据字典中
    [_resultDict setObject:dataArray forKey:url];
    
    // 数据保存完成时发送通知,通知界面取数据 object -> notification.name = url
    [[NSNotificationCenter defaultCenter] postNotificationName:url object:nil];
}

// 解析列表方法
-(void)praseProsListWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *proListElement = [document nodesForXPath:@"/response/list/promotion" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    MZDataBase *mzDataBase = [MZDataBase sharedMZDataBase];
    for (GDataXMLElement *pro in proListElement)
    {
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId  = [[[pro.children objectAtIndex:0] stringValue] intValue];
        proItem.surl = [[pro.children objectAtIndex:1] stringValue];
        proItem.durl = [[pro.children objectAtIndex:2] stringValue];
        proItem.imgUrl = [[pro.children objectAtIndex:3] stringValue];
        proItem.name = [[pro.children objectAtIndex:4] stringValue];
        proItem.multiPageTitle = [[pro.children objectAtIndex:5] stringValue];
        proItem.oldPrice = [[pro.children objectAtIndex:6] stringValue];
        proItem.currentPrice = [[pro.children objectAtIndex:7] stringValue];
        proItem.currentDealCount = [[pro.children objectAtIndex:8] stringValue];
        proItem.startTime = [[pro.children objectAtIndex:9] stringValue];
        proItem.endTime = [[pro.children objectAtIndex:10] stringValue];
        proItem.sevenrefundallowed = [[[pro.children objectAtIndex:11] stringValue] intValue];
        proItem.expirerefundallowed = [[[pro.children objectAtIndex:12] stringValue] intValue];
        proItem.district = [[pro.children objectAtIndex:13] stringValue];
        proItem.type2 = [[[pro.children objectAtIndex:14] stringValue] intValue];
        proItem.hassub = [[[pro.children objectAtIndex:15] stringValue] intValue];
        proItem.flag = [[[pro.children objectAtIndex:16] stringValue] intValue];
        // 插入数据库
        [mzDataBase insertAnPromotionWith:proItem];
        [dataArray addObject:proItem];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

// 解析详情方法(带SubList)
-(void)praseDetailHasSubWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *proListElement = [document nodesForXPath:@"/response/promotion" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *pro in proListElement)
    {
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId  = [[[pro.children objectAtIndex:0] stringValue] intValue];
        proItem.name = [[pro.children objectAtIndex:1] stringValue];
        proItem.oldPrice = [[pro.children objectAtIndex:2] stringValue];
        proItem.intro = [[pro.children objectAtIndex:3] stringValue];
        proItem.currentPrice = [[pro.children objectAtIndex:4] stringValue];
        proItem.startTime = [[pro.children objectAtIndex:5] stringValue];
        proItem.endTime = [[pro.children objectAtIndex:6] stringValue];
        proItem.fineprint = [[pro.children objectAtIndex:7] stringValue];
        proItem.sideimgUrl = [[pro.children objectAtIndex:9] stringValue];
        proItem.smallimgUrl = [[pro.children objectAtIndex:10] stringValue];
        proItem.wsdimgUrl = [[pro.children objectAtIndex:11] stringValue];
        proItem.wsmimgUrl = [[pro.children objectAtIndex:12] stringValue];
        proItem.wmnimgUrl = [[pro.children objectAtIndex:13] stringValue];
        proItem.wcmimgUrl = [[pro.children objectAtIndex:14] stringValue];
        proItem.currentDealCount = [[pro.children objectAtIndex:17] stringValue];
        proItem.flag = [[[pro.children objectAtIndex:20] stringValue] intValue];
        proItem.bflag = [[[pro.children objectAtIndex:21] stringValue] intValue];
        proItem.descurl = [[pro.children objectAtIndex:22] stringValue];
        proItem.type = [[[pro.children objectAtIndex:23] stringValue] intValue];
        proItem.type2 = [[[pro.children objectAtIndex:24] stringValue] intValue];
        proItem.district = [[pro.children objectAtIndex:26] stringValue];
        proItem.dealendTime = [[pro.children objectAtIndex:29] stringValue];
        proItem.promotionurl = [[pro.children objectAtIndex:32] stringValue];
        proItem.multiPageTitle = [[pro.children objectAtIndex:36] stringValue];
        proItem.hassub = [[[pro.children objectAtIndex:40] stringValue] intValue];
        proItem.sevenrefundallowed = [[[pro.children objectAtIndex:46] stringValue] intValue];
        proItem.expirerefundallowed = [[[pro.children objectAtIndex:47] stringValue] intValue];
        
        [dataArray addObject:proItem];
    }
    NSArray *subListElement = [document nodesForXPath:@"/response/promotion/sublist/subpromotion" error:nil];
    for (GDataXMLElement *pro in subListElement)
    {
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId  = [[[pro.children objectAtIndex:0] stringValue] intValue];
        proItem.intro = [[pro.children objectAtIndex:1] stringValue];
        proItem.name = [[pro.children objectAtIndex:2] stringValue];
        proItem.oldPrice = [[pro.children objectAtIndex:3] stringValue];
        proItem.currentPrice = [[pro.children objectAtIndex:4] stringValue];
        proItem.startTime = [[pro.children objectAtIndex:5] stringValue];
        proItem.endTime = [[pro.children objectAtIndex:6] stringValue];
        proItem.descurl = [[pro.children objectAtIndex:9] stringValue];
        proItem.currentDealCount = [[pro.children objectAtIndex:11] stringValue];
        proItem.flag = [[[pro.children objectAtIndex:13] stringValue] intValue];
        proItem.type = [[[pro.children objectAtIndex:14] stringValue] intValue];
        proItem.promotionurl = [[pro.children objectAtIndex:20] stringValue];
        proItem.sevenrefundallowed = [[[pro.children objectAtIndex:24] stringValue] intValue];
        proItem.expirerefundallowed = [[[pro.children objectAtIndex:25] stringValue] intValue];
        proItem.multiPageTitle = [[pro.children objectAtIndex:29] stringValue];
        proItem.wsdimgUrl = [[pro.children objectAtIndex:30] stringValue];
        proItem.wsmimgUrl = [[pro.children objectAtIndex:31] stringValue];
        proItem.wmnimgUrl = [[pro.children objectAtIndex:32] stringValue];
        proItem.wcmimgUrl = [[pro.children objectAtIndex:34] stringValue];
        proItem.fineprint = [[pro.children objectAtIndex:35] stringValue];
        
        [dataArray addObject:proItem];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

// 解析详情方法
-(void)praseDetailWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *proListElement = [document nodesForXPath:@"/response/promotion" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *pro in proListElement)
    {
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId  = [[[pro.children objectAtIndex:0] stringValue] intValue];
        proItem.name = [[pro.children objectAtIndex:1] stringValue];
        proItem.oldPrice = [[pro.children objectAtIndex:2] stringValue];
        proItem.intro = [[pro.children objectAtIndex:3] stringValue];
        proItem.currentPrice = [[pro.children objectAtIndex:4] stringValue];
        proItem.startTime = [[pro.children objectAtIndex:5] stringValue];
        proItem.endTime = [[pro.children objectAtIndex:6] stringValue];
        proItem.fineprint = [[pro.children objectAtIndex:7] stringValue];
        proItem.sideimgUrl = [[pro.children objectAtIndex:9] stringValue];
        proItem.smallimgUrl = [[pro.children objectAtIndex:10] stringValue];
        proItem.wsdimgUrl = [[pro.children objectAtIndex:11] stringValue];
        proItem.wsmimgUrl = [[pro.children objectAtIndex:12] stringValue];
        proItem.wmnimgUrl = [[pro.children objectAtIndex:13] stringValue];
        proItem.wcmimgUrl = [[pro.children objectAtIndex:14] stringValue];
        proItem.currentDealCount = [[pro.children objectAtIndex:17] stringValue];
        proItem.flag = [[[pro.children objectAtIndex:20] stringValue] intValue];
        proItem.bflag = [[[pro.children objectAtIndex:21] stringValue] intValue];
        proItem.descurl = [[pro.children objectAtIndex:22] stringValue];
        proItem.type = [[[pro.children objectAtIndex:23] stringValue] intValue];
        proItem.type2 = [[[pro.children objectAtIndex:24] stringValue] intValue];
        proItem.district = [[pro.children objectAtIndex:26] stringValue];
        proItem.dealendTime = [[pro.children objectAtIndex:29] stringValue];
        proItem.promotionurl = [[pro.children objectAtIndex:32] stringValue];
        proItem.multiPageTitle = [[pro.children objectAtIndex:36] stringValue];
        proItem.hassub = [[[pro.children objectAtIndex:40] stringValue] intValue];
        proItem.sevenrefundallowed = [[[pro.children objectAtIndex:46] stringValue] intValue];
        proItem.expirerefundallowed = [[[pro.children objectAtIndex:47] stringValue] intValue];
        
        [dataArray addObject:proItem];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

-(void)prasecActivitysWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *activitysElement = [document nodesForXPath:@"/home/alist/activity" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *activity in activitysElement)
    {
        ActivityItem *actItem = [[ActivityItem alloc] init];
        actItem.actId  = [[[activity.children objectAtIndex:0] stringValue] intValue];
        actItem.actType = [[[activity.children objectAtIndex:1] stringValue] intValue];
        actItem.actName = [[activity.children objectAtIndex:2] stringValue];
        actItem.itarget = [[[activity.children objectAtIndex:3] stringValue] intValue];
        actItem.imgUrl = [[activity.children objectAtIndex:4] stringValue];
        actItem.durl = [[activity.children objectAtIndex:5] stringValue];
        [dataArray addObject:actItem];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

-(void)prasecCityListWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *citysELement = [document nodesForXPath:@"/response/list/city" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *cityEl in citysELement)
    {
        City *city = [[City alloc] init];
        city.name  = [[cityEl.children objectAtIndex:0] stringValue];
        city.code = [[cityEl.children objectAtIndex:1] stringValue];

        [dataArray addObject:city];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

/*
 <promotion>
 <id>82161</id>
 <name>米娜造型超值美发烫染套餐</name>
 <price>1192.0</price>
 <intro>
 【17店通用】仅98元！享价值1192元米娜造型超值美发烫染套餐！欧莱雅烫前护理，欧莱雅陶瓷烫/欧莱雅染发2选1，欧莱雅烫染后护理，总监精剪，欧莱雅丝泉护理发膜！另送100元代金券，自兑换之日起半年有效！另有其他套餐可选！
 </intro>
 <priceoff>98.0</priceoff>
 <starttime>2013-03-01 00:00:00</starttime>
 <endtime>2014-09-30 23:59:59</endtime>
 <fineprint>
 <![CDATA[
 •有效期至2014-10-03<br> •请提前2天预约<br> •每张满座券限1人使用<br> •本券不限购买数量<br> •本券不与店内其他优惠活动同享<br>
 ]]>
 </fineprint>
 <highlights/>
 <sideimg>http://p0.manzuo.com/8/82161/30000051_w_more.jpg</sideimg>
 <smallimg>http://p0.manzuo.com/8/82161/30000051_w_side.jpg</smallimg>
 <wsdimg>http://p0.manzuo.com/8/82161/30000051_w_more.jpg</wsdimg>
 <wsmimg>http://p0.manzuo.com/8/82161/30000051_w_side.jpg</wsmimg>
 <wmnimg>http://p0.manzuo.com/8/82161/30000051_w_main.jpg</wmnimg>
 <wcmimg>http://p0.manzuo.com/8/82161/30000051_w_main.jpg</wcmimg>
 <needdelivery>0</needdelivery>
 <extralabel/>
 <currentdealcount>159</currentdealcount>
 <allowsplit>0</allowsplit>
 <retailer>
 <id>34627</id>
 <name>米娜造型</name>
 <siteurl/>
 <tel/>
 <address/>
 <latitude/>
 <longitude/>
 <branchlist>
 <branch>
 <id>49710</id>
 <name>米娜造型（亮马桥旗舰店）</name>
 <siteurl/>
 <tel>010-65942353</tel>
 <address>麦子店街龙宝大厦一层36号</address>
 <latitude>39.948071</latitude>
 <longitude>116.468391</longitude>
 </branch>
 <branch>
 <id>49712</id>
 <name>米娜造型（动物园总店）</name>
 <siteurl/>
 <tel>13121279570;010-68514898</tel>
 <address>三里河路甲34号</address>
 <latitude>39.937774</latitude>
 <longitude>116.363885</longitude>
 </branch>
 <branch>
 <id>49713</id>
 <name>米娜造型（丽都店）</name>
 <siteurl/>
 <tel>010-84572707</tel>
 <address>芳园西路高家园1区6号楼1楼底商</address>
 <latitude>39.979534</latitude>
 <longitude>116.487242</longitude>
 </branch>
 <branch>
 <id>49714</id>
 <name>米娜造型（大兴黄村店）</name>
 <siteurl/>
 <tel>010-69227258</tel>
 <address>清源路黄村公园附近（阿涛剪艺）</address>
 <latitude>39.741528</latitude>
 <longitude>116.438156</longitude>
 </branch>
 <branch>
 <id>49715</id>
 <name>米娜造型（广安门店）</name>
 <siteurl/>
 <tel>010-83526232</tel>
 <address>广安门内南线阁街39-2号</address>
 <latitude>39.885148</latitude>
 <longitude>116.353425</longitude>
 </branch>
 <branch>
 <id>49716</id>
 <name>米娜造型（望京店）</name>
 <siteurl/>
 <tel>010-84714292</tel>
 <address>望京望花路16号底商</address>
 <latitude>39.987275</latitude>
 <longitude>116.470195</longitude>
 </branch>
 <branch>
 <id>49717</id>
 <name>米娜造型（小马厂店）</name>
 <siteurl/>
 <tel>010-56028319</tel>
 <address>小马厂西毫逸景小区11号楼101号底商</address>
 <latitude>39.912289</latitude>
 <longitude>116.365867</longitude>
 </branch>
 <branch>
 <id>49718</id>
 <name>米娜造型（万源店）</name>
 <siteurl/>
 <tel>010-68758889;010-88531188</tel>
 <address>万源南里18栋一层</address>
 <latitude>39.797996</latitude>
 <longitude>116.424418</longitude>
 </branch>
 <branch>
 <id>49719</id>
 <name>米娜造型（东高地店）</name>
 <siteurl/>
 <tel>010-67953688;010-67953288</tel>
 <address>东高地商场后左侧</address>
 <latitude>39.808204</latitude>
 <longitude>116.421489</longitude>
 </branch>
 <branch>
 <id>49720</id>
 <name>米娜造型（交大东路店）</name>
 <siteurl/>
 <tel>010-62217651</tel>
 <address>交通大学路28号北京文化局东侧100米</address>
 <latitude>39.948997</latitude>
 <longitude>116.344924</longitude>
 </branch>
 <branch>
 <id>49721</id>
 <name>米娜造型（小南庄店）</name>
 <siteurl/>
 <tel>010-52433747</tel>
 <address>万柳东路怡秀园七号楼底商</address>
 <latitude>39.966653</latitude>
 <longitude>116.302174</longitude>
 </branch>
 <branch>
 <id>49722</id>
 <name>米娜造型（石景山店）</name>
 <siteurl/>
 <tel>010-68867385</tel>
 <address>杨庄中区21号楼（2交通队向西100米）</address>
 <latitude>39.905656</latitude>
 <longitude>116.222874</longitude>
 </branch>
 <branch>
 <id>49723</id>
 <name>米娜造型（天通苑店 ）</name>
 <siteurl/>
 <tel>010-64113182</tel>
 <address>天通苑西一区东门20米路北（名尚殿堂）</address>
 <latitude>40.064655</latitude>
 <longitude>116.410319</longitude>
 </branch>
 <branch>
 <id>49724</id>
 <name>米娜造型（旧宫庑殿店）</name>
 <siteurl/>
 <tel>010-87971788</tel>
 <address>旧宫庑殿路35-9号底商</address>
 <latitude>39.722082</latitude>
 <longitude>116.345281</longitude>
 </branch>
 <branch>
 <id>49725</id>
 <name>米娜造型（林校路店）</name>
 <siteurl/>
 <tel>010-60221588</tel>
 <address>黄村林校路环岛东侧路南</address>
 <latitude>39.90403</latitude>
 <longitude>116.407525</longitude>
 </branch>
 <branch>
 <id>49726</id>
 <name>米娜造型（丰体店）</name>
 <siteurl/>
 <tel>15010007579;010-51450012</tel>
 <address>卢沟桥路丰体时代1号楼底商（物美大卖场向东200米）</address>
 <latitude>39.867722</latitude>
 <longitude>116.270187</longitude>
 </branch>
 <branch>
 <id>49727</id>
 <name>米娜造型（东四店）</name>
 <siteurl/>
 <tel>18201094063</tel>
 <address>朝阳门内大街东单明珠192号</address>
 <latitude>39.90403</latitude>
 <longitude>116.407525</longitude>
 </branch>
 </branchlist>
 </retailer>
 <flag>0</flag>
 <bflag>191</bflag>
 <descurl>http://m.manzuo.com/promotions/desc/82161</descurl>
 <type>2</type>
 <type2>4</type2>
 <cateloc>48,48</cateloc>
 <district>北京</district>
 <extracharge>0</extracharge>
 <extrafreecount>0</extrafreecount>
 <dealendtime>2014-10-03 23:59:59.0</dealendtime>
 <perdeallimit>999</perdeallimit>
 <lowerlimit>1</lowerlimit>
 <promotionurl>http://www.manzuo.com/beijing/30000051</promotionurl>
 <extrachargelabel/>
 <dealsuccessnum>1</dealsuccessnum>
 <allowrefund>0</allowrefund>
 <multipagetitle>【17店通用】米娜造型超值美发烫染套餐！另有其他套餐可选！</multipagetitle>
 <isvirtualidcode>0</isvirtualidcode>
 <lotteryaward>-1</lotteryaward>
 <positioncity/>
 <hassub>-1</hassub>
 <combinepromotion/>
 <displayshortname>超值烫染</displayshortname>
 <restrictlevel>0</restrictlevel>
 <closetime>2013-02-16 00:00:09</closetime>
 <retailerid>34627</retailerid>
 <sevenrefundallowed>1</sevenrefundallowed>
 <expirerefundallowed>0</expirerefundallowed>
 <extradefault/>
 <durl>http://mp.manzuo.com/china/prm/8/82161.xml</durl>
 <surl>
 http://mps.manzuo.com/mps/pdstt?id=82161&pg=0&f=act
 </surl>
 </promotion>
 */
-(void)praseActivityDetailWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *proListElement = [document nodesForXPath:@"/response/list/promotion" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *pro in proListElement)
    {
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId  = [[[pro.children objectAtIndex:0] stringValue] intValue];
        proItem.name = [[pro.children objectAtIndex:1] stringValue];
        proItem.oldPrice = [[pro.children objectAtIndex:2] stringValue];
        proItem.intro = [[pro.children objectAtIndex:3] stringValue];
        proItem.currentPrice = [[pro.children objectAtIndex:4] stringValue];
        proItem.startTime = [[pro.children objectAtIndex:5] stringValue];
        proItem.endTime = [[pro.children objectAtIndex:6] stringValue];
        proItem.fineprint = [[pro.children objectAtIndex:7] stringValue];
        proItem.sideimgUrl = [[pro.children objectAtIndex:9] stringValue];
        proItem.smallimgUrl = [[pro.children objectAtIndex:10] stringValue];
        proItem.wsdimgUrl = [[pro.children objectAtIndex:11] stringValue];
        proItem.wsmimgUrl = [[pro.children objectAtIndex:12] stringValue];
        proItem.wmnimgUrl = [[pro.children objectAtIndex:13] stringValue];
        proItem.wcmimgUrl = [[pro.children objectAtIndex:14] stringValue];
        proItem.currentDealCount = [[pro.children objectAtIndex:17] stringValue];
        proItem.district = [[pro.children objectAtIndex:26] stringValue];
        proItem.multiPageTitle = [[pro.children objectAtIndex:36] stringValue];
        proItem.surl = [[pro.children lastObject] stringValue];
        proItem.durl = [[pro.children objectAtIndex:49] stringValue];
        proItem.sevenrefundallowed = [[[pro.children objectAtIndex:46] stringValue] intValue];
        proItem.expirerefundallowed = [[[pro.children objectAtIndex:47] stringValue] intValue];
//        proItem.type2 = [[[pro.children objectAtIndex:14] stringValue] intValue];
//        proItem.hassub = [[[pro.children objectAtIndex:15] stringValue] intValue];
//        proItem.flag = [[[pro.children objectAtIndex:16] stringValue] intValue];
        
        [dataArray addObject:proItem];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

-(void)praseBranchListWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *braListElement = [document nodesForXPath:@"/response/branch" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *branch in braListElement) {
        Branch *braItem = [[Branch alloc] init];
        braItem.branchId = [[[branch.children objectAtIndex:0] stringValue] intValue];
        braItem.branchName = [[branch.children objectAtIndex:1] stringValue];
        braItem.branchaddress = [[branch.children objectAtIndex:2] stringValue];
        braItem.latitude = [[branch.children objectAtIndex:3] stringValue];
        braItem.longitude = [[branch.children objectAtIndex:4] stringValue];
        braItem.dist = [[branch.children objectAtIndex:5] stringValue];
        GDataXMLElement *promotionEl = (GDataXMLElement *)[branch.children objectAtIndex:6];
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId = [[[promotionEl.children objectAtIndex:0] stringValue] intValue];
        proItem.surl = [[promotionEl.children objectAtIndex:1] stringValue];
        proItem.durl = [[promotionEl.children objectAtIndex:2] stringValue];
        proItem.wsdimgUrl = [[promotionEl.children objectAtIndex:3] stringValue];
        proItem.name = [[promotionEl.children objectAtIndex:4] stringValue];
        proItem.multiPageTitle = [[promotionEl.children objectAtIndex:5] stringValue];
        proItem.oldPrice = [[promotionEl.children objectAtIndex:6] stringValue];
        proItem.currentPrice = [[promotionEl.children objectAtIndex:7] stringValue];
        proItem.currentDealCount = [[promotionEl.children objectAtIndex:8] stringValue];
        proItem.startTime = [[promotionEl.children objectAtIndex:9] stringValue];
        proItem.endTime = [[promotionEl.children objectAtIndex:10] stringValue];
        proItem.sevenrefundallowed = [[[promotionEl.children objectAtIndex:11] stringValue] intValue];
        proItem.expirerefundallowed = [[[promotionEl.children objectAtIndex:12] stringValue] intValue];
        proItem.district = [[promotionEl.children objectAtIndex:13] stringValue];
        proItem.type2 = [[[promotionEl.children objectAtIndex:14] stringValue] intValue];
        proItem.hassub = [[[promotionEl.children objectAtIndex:15] stringValue] intValue];
        proItem.flag = [[[promotionEl.children objectAtIndex:16] stringValue] intValue];
        braItem.promotion = proItem;
        
        [dataArray addObject:braItem];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

// 解析热词搜索
-(void)praseHotKeysWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *hotkeyElement = [document nodesForXPath:@"/response/hotkeys" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    GDataXMLElement *hotkeyEl = [hotkeyElement lastObject];
    NSString *hotkeyStr = [[hotkeyEl.children objectAtIndex:0] stringValue];
    NSArray *hotkeys = [hotkeyStr componentsSeparatedByString:@","];
    for (NSString *hotkey in hotkeys) {
        [dataArray addObject:hotkey];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

// 解析用户输入搜索词
-(void)prasePreKeysWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *wlistElement = [document nodesForXPath:@"/response/wlist" error:nil];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    GDataXMLElement *wlistEl = [wlistElement lastObject];
    NSString *wlistStr = [[wlistEl.children objectAtIndex:0] stringValue];
    NSArray *wlists = [wlistStr componentsSeparatedByString:@","];
    for (NSString *wlist in wlists) {
        [dataArray addObject:wlist];
    }
    [self saveDataWithData:dataArray andURL:download.downloadURL];
}

-(void)praseSearchWithClass:(Download *)download
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:download.resultData options:0 error:nil];
    NSArray *proListElement = [document nodesForXPath:@"/response/promotion" error:nil];
    NSArray *totalElement = [document nodesForXPath:@"/response/total" error:nil];
    NSArray *keywordElement = [document nodesForXPath:@"/response/keyword" error:nil];
    NSString *total = [[totalElement lastObject] stringValue];
    NSString *keyword = [[keywordElement lastObject] stringValue];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    [resultArray addObject:total];
    [resultArray addObject:keyword];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *pro in proListElement)
    {
        PromotionItem *proItem = [[PromotionItem alloc] init];
        proItem.proId  = [[[pro.children objectAtIndex:0] stringValue] intValue];
        proItem.surl = [[pro.children objectAtIndex:1] stringValue];
        proItem.durl = [[pro.children objectAtIndex:2] stringValue];
        proItem.name = [[pro.children objectAtIndex:3] stringValue];
        proItem.multiPageTitle = [[pro.children objectAtIndex:4] stringValue];
        proItem.wsdimgUrl = [[pro.children objectAtIndex:5] stringValue];
        proItem.currentDealCount = [[pro.children objectAtIndex:6] stringValue];
        proItem.oldPrice = [[pro.children objectAtIndex:7] stringValue];
        proItem.currentPrice = [[pro.children objectAtIndex:8] stringValue];
        proItem.startTime = [[pro.children objectAtIndex:9] stringValue];
        proItem.endTime = [[pro.children objectAtIndex:10] stringValue];
        proItem.flag = [[[pro.children objectAtIndex:11] stringValue] intValue];
        proItem.district = [[pro.children objectAtIndex:12] stringValue];
        proItem.sevenrefundallowed = [[[pro.children objectAtIndex:14] stringValue] intValue];
        proItem.expirerefundallowed = [[[pro.children objectAtIndex:15] stringValue] intValue];
        
        [dataArray addObject:proItem];
    }
    [resultArray addObject:dataArray];
    [self saveDataWithData:resultArray andURL:download.downloadURL];
}

@end
