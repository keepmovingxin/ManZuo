//
//  MZDataBase.m
//  ManZuo
//
//  Created by admin on 14-3-13.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "MZDataBase.h"
#import "AppUtil.h"

@implementation MZDataBase
{
    FMDatabase *_dataBase;
}

static MZDataBase *_sharedMZDataBase;
+(MZDataBase *)sharedMZDataBase
{
    if (!_sharedMZDataBase) {
        _sharedMZDataBase = [[MZDataBase alloc] init];
    }
    return _sharedMZDataBase;
}

-(BOOL)createDataBase
{
    NSString *path = [NSString stringWithFormat:@"%@MZData.db",[AppUtil getCachesPath]];
    _dataBase = [[FMDatabase alloc] initWithPath:path];
    if ([_dataBase open])
    {
        return YES;
    } else
    {
        return NO;
    }
    [_dataBase close];
    NSLog(@"database path:%@",path);
}

-(BOOL)createPromotionTable
{
    if ([_dataBase open])
    {
        if ([_dataBase executeUpdate:@"create table Promotion (ProId integer primary key,ProImgUrl text,MultiPageTitle text,CurrentPrice text,OldPrice text,CurrentDealCount text,District text,Hassub integer)"])
        {
            [_dataBase close];
            return YES;
        } else
        {
            [_dataBase close];
            return NO;
        }
    } else
    {
        NSLog(@"数据库打开失败");
        [_dataBase close];
        return NO;
    }
}

-(BOOL)insertAnPromotionWith:(PromotionItem *)proItem
{
    if ([_dataBase open])
    {
        if ([_dataBase executeUpdate:@"insert into Promotion values(?,?,?,?,?,?,?,?)",
             [NSNumber numberWithInt:proItem.proId],
             proItem.imgUrl,
             proItem.multiPageTitle,
             proItem.currentPrice,
             proItem.oldPrice,
             proItem.currentDealCount,
             proItem.district,
             [NSNumber numberWithInt:proItem.hassub]])
        {
            NSLog(@"插入产品成功");
            [_dataBase close];
            return YES;
        } else
        {
            NSLog(@"插入产品失败");
            [_dataBase close];
            return NO;
        }
    } else
    {
        NSLog(@"打开数据库失败");
        [_dataBase close];
        return NO;
    }
}

-(BOOL)deleteAllPromotions
{
    if ([_dataBase open])
    {
        if ([_dataBase executeUpdate:@"delete from Promotion"])
        {
            NSLog(@"删除数据成功");
            [_dataBase close];
            return YES;
        } else
        {
            NSLog(@"删除数据失败");
            [_dataBase close];
            return NO;
        }
    } else
    {
        NSLog(@"打开数据库失败");
        [_dataBase close];
        return NO;
    }
    return NO;
}

//@"create table Promotion (ProId integer primary key,ProImgUrl text,MultiPageTitle text,CurrentPrice text,OldPrice text,CurrentDealCount text,District text,Hassub integer)"
-(PromotionItem *)selectPromotionWithId:(int)proId
{
    PromotionItem *proItem = [[PromotionItem alloc] init];
    if ([_dataBase open])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from Promotion where ProId = %d",proId];
        FMResultSet *set = [_dataBase executeQuery:sql];
        if (set)
        {
            while (set.next)
            {
                proItem.proId = [set intForColumn:@"ProId"];
                proItem.imgUrl = [set stringForColumn:@"ProImgUrl"];
                proItem.multiPageTitle = [set stringForColumn:@"MultiPageTitle"];
                proItem.currentPrice = [set stringForColumn:@"CurrentPrice"];
                proItem.oldPrice = [set stringForColumn:@"OldPrice"];
                proItem.currentDealCount = [set stringForColumn:@"CurrentDealCount"];
                proItem.district = [set stringForColumn:@"District"];
                proItem.hassub = [set intForColumn:@"Hassub"];
            }
        } else
        {
            NSLog(@"查询产品失败");
        }
    } else
    {
        NSLog(@"打开数据库失败");
    }
    [_dataBase close];
    return proItem;
}

@end
