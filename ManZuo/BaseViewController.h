//
//  BaseViewController.h
//  ManZuo
//
//  Created by student on 14-3-3.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic) BOOL isBackBtn;

-(void)showHUDView;
-(void)hideHUDView;

@end
