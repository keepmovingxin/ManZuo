//
//  ScrollPageView.h
//  ScrollView轮播控件
//
//  Created by qianfeng on 14-1-11.
//  Copyright (c) 2014年 lgx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollPageViewDelegate <NSObject>
-(void)didClickImageView:(int)index;
@end

@interface ScrollPageView : UIView<UIScrollViewDelegate>
{
    NSArray *_imageArray;
    BOOL _autoScroll;
    UIPageControl *_pageControl;
    UIImageView *_fristImageView;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSArray *imageArray;
@property (nonatomic, assign) id<ScrollPageViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray autoScroll:(BOOL)autoScroll;

@end
