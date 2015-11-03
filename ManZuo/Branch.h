//
//  Branch.h
//  ManZuo
//
//  Created by admin on 14-3-5.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromotionItem.h"

@interface Branch : NSObject

@property (nonatomic) int branchId;
@property (nonatomic,copy) NSString *branchName;
@property (nonatomic,copy) NSString *branchaddress;
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;
@property (nonatomic,copy) NSString *dist;
@property (nonatomic,strong) PromotionItem *promotion;

@end
