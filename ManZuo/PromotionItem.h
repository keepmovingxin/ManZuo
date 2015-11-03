//
//  promotionItem.h
//  ManZuo
//
//  Created by student on 14-3-4.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PromotionItem : NSObject
/*
 <promotion>
    <id>56623</id>
    <surl>...</surl>
    <durl>...</durl>
    <wsdimg>...</wsdimg>
    <name>...</name>
    <multipagetitle>...</multipagetitle>
    <price>2409.0</price>
    <priceoff>28.0</priceoff>
    <currentdealcount>5048</currentdealcount>
    <starttime>2012-08-15 00:00:01</starttime>
    <endtime>2014-06-27 23:59:59</endtime>
    <sevenrefundallowed>1</sevenrefundallowed>
    <expirerefundallowed>1</expirerefundallowed>
    <district>北京等</district>
    <type2>4</type2>
    <hassub>0</hassub>
    <flag>0</flag>
 </promotion>
 */

@property (nonatomic) int proId;
@property (nonatomic,copy) NSString *surl;
@property (nonatomic,copy) NSString *durl;
@property (nonatomic,copy) NSString *imgUrl;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *multiPageTitle;
@property (nonatomic,copy) NSString *oldPrice;
@property (nonatomic,copy) NSString *currentPrice;
@property (nonatomic,copy) NSString *currentDealCount;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic) int sevenrefundallowed;
@property (nonatomic) int expirerefundallowed;
@property (nonatomic,copy) NSString *district;
@property (nonatomic) int type;
@property (nonatomic) int type2;
@property (nonatomic) int hassub;
@property (nonatomic) int flag;
@property (nonatomic) int bflag;
@property (nonatomic,copy) NSString *dealendTime;
@property (nonatomic,copy) NSString *promotionurl;

@property (nonatomic,copy) NSString *intro;
@property (nonatomic,copy) NSString *fineprint;
@property (nonatomic,copy) NSString *sideimgUrl;
@property (nonatomic,copy) NSString *smallimgUrl;
@property (nonatomic,copy) NSString *wsdimgUrl;
@property (nonatomic,copy) NSString *wsmimgUrl;
@property (nonatomic,copy) NSString *wmnimgUrl;
@property (nonatomic,copy) NSString *wcmimgUrl;
@property (nonatomic,copy) NSString *descurl;

@end
