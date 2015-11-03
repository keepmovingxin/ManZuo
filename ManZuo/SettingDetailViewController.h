//
//  SettingDetailViewController.h
//  ManZuo
//
//  Created by admin on 14-3-8.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BaseViewController.h"

#define ABOUT_TYPE 1
#define FEEDBACK_TYPE 2
#define APP_TYPE 3

@interface SettingDetailViewController : BaseViewController

@property (nonatomic) int type;

-(id)initWithType:(int)type;

@end
