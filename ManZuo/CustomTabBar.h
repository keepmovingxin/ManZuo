//
//  CustomTabBar.h
//  CustomTabBarController
//
//  Created by student on 14-2-11.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBar : UIView

- (void)createTabBarWithBackgroundImage:(NSString *)bgImageName
                    andButtonsImageName:(NSArray *)buttonsImageName
                    andButtonsSelectedImageName:(NSArray *)buttonsSelectedImageName
                    andButtonsTitle:(NSArray *)buttonsTitle
                    andSEL:(SEL)sel
                    andClass:(id)classObj;
@end
