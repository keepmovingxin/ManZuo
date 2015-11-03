//
//  LoginViewController.h
//  ManZuo
//
//  Created by admin on 14-3-8.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BaseViewController.h"
#define LOGIN_TYPE 1
#define REGISTER_TYPE 2

@interface LoginViewController : BaseViewController

@property (nonatomic) int type;

-(id)initWithType:(int)type;

@end
