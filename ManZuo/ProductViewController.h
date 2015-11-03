//
//  ProductViewController.h
//  ManZuo
//
//  Created by admin on 14-3-11.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BaseViewController.h"
#import "PromotionItem.h"

#define PROMOTION_TYPE 0
#define BRACH_TYPE 1

@interface ProductViewController : BaseViewController

@property (nonatomic,strong) PromotionItem *proItem;
@property (nonatomic) int type;

@end
