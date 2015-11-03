//
//  GpsViewController.h
//  ManZuo
//
//  Created by admin on 14-3-5.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BaseViewController.h"
#import "City.h"

typedef void(^SelectedBlock)(City *city);
@interface GpsViewController : BaseViewController

@property (nonatomic,strong) SelectedBlock block;

@end
