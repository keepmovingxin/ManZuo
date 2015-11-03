//
//  CustomAnnotationView.m
//  ManZuo
//
//  Created by admin on 14-3-6.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomAnnotation.h"

@implementation CustomAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsLayout];
    }
    return self;
}

//复写调用的初始化方法
-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setNeedsLayout];
    }
    return self;
}

//布局视图
-(void)layoutSubviews {
    [super layoutSubviews];
    CustomAnnotation *customAnnotation = self.annotation;
    Branch *branch = nil;
    if ([customAnnotation isKindOfClass:[CustomAnnotation class]])
    {
        branch = customAnnotation.branch;
    }
//    branch.promotion.type2 美食1 电影2 休闲娱乐3 生活服务4 酒店6
    NSString *imageName = [NSString stringWithFormat:@"pin_type%d.png",branch.promotion.type2];
    self.image = [UIImage imageNamed:imageName];
}

@end
