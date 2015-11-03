//
//  CustomTabBar.m
//  CustomTabBarController
//
//  Created by student on 14-2-11.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CustomTabBar.h"

@implementation CustomTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)createTabBarWithBackgroundImage:(NSString *)bgImageName
                    andButtonsImageName:(NSArray *)buttonsImageName
            andButtonsSelectedImageName:(NSArray *)buttonsSelectedImageName
                        andButtonsTitle:(NSArray *)buttonsTitle
                                 andSEL:(SEL)sel
                               andClass:(id)classObj
{
    // tabBar bg视图
    [self createBackgoroundImageWithImageName:bgImageName];
    // 循环创建item
    for (int i = 0; i<[buttonsImageName count]; i++) {
        [self createItemWithButtonImageName:[buttonsImageName objectAtIndex:i] andButtonSelectedImageName:[buttonsSelectedImageName objectAtIndex:i] andTitle:[buttonsTitle objectAtIndex:i] andSEL:sel andClass:classObj andIndex:i];
    }
}

- (void)createBackgoroundImageWithImageName:(NSString *)bgImageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgImageName]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.frame = self.bounds;
    [self addSubview:imageView];
}

- (void)createItemWithButtonImageName:(NSString *)buttonImageName
               andButtonSelectedImageName:(NSString *)buttonSelectedImageName
                                 andTitle:(NSString *)title
                                   andSEL:(SEL)sel
                                 andClass:(id)classObj
                                 andIndex:(int)index
{
    UIView *itemView = [[UIView alloc] init];
    itemView.frame = CGRectMake(index*self.bounds.size.width/4.0, 0, self.bounds.size.width/4.0, self.bounds.size.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((80-35)/2, 3, 40, 32);
    // 高光效果
//    button.showsTouchWhenHighlighted = YES;
    [button setBackgroundImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:buttonSelectedImageName] forState:UIControlStateSelected];
    [button addTarget:classObj action:sel forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    [itemView addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((80-35)/2, 36, 40, 12)];
    label.text = title;
    label.textColor = [UIColor colorWithRed:0.30f green:0.30f blue:0.30f alpha:1.00f];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont systemFontOfSize:10.0f]];
    [itemView addSubview:label];
    [self addSubview:itemView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
