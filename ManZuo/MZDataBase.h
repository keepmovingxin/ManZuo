//
//  MZDataBase.h
//  ManZuo
//
//  Created by admin on 14-3-13.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "PromotionItem.h"

@interface MZDataBase : NSObject

+(MZDataBase *)sharedMZDataBase;
-(BOOL)createDataBase;
-(BOOL)createPromotionTable;
-(BOOL)insertAnPromotionWith:(PromotionItem *)proItem;
-(BOOL)deleteAllPromotions;
-(PromotionItem *)selectPromotionWithId:(int)proId;

@end
