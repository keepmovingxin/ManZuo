//
//  ScrollPageView.m
//  ScrollView轮播控件
//
//  Created by qianfeng on 14-1-11.
//  Copyright (c) 2014年 lgx. All rights reserved.
//

#import "ScrollPageView.h"
#import "UIImageView+WebCache.h"

@implementation ScrollPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray autoScroll:(BOOL)autoScroll {
     self = [self initWithFrame:frame];
    _imageArray = [imageArray retain];
    if (autoScroll) {
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoScroll:) userInfo:_scrollView repeats:YES];
    }
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    if (self) {
        // 添加ScrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        // 添加内容图片视图imageView
        for (int i = 0; i<[_imageArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0, w, h)];
            [imageView setImageWithURL:[NSURL URLWithString:[_imageArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"img_bg.png"]];
            imageView.tag = 100+i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
            [imageView addGestureRecognizer:tap];
            [tap release];
            [_scrollView addSubview:imageView];
            [imageView release];
        }
        // 在后面多加一页 实现循环滚动
        _fristImageView = [[UIImageView alloc] initWithFrame:CGRectMake([_imageArray count]*w, 0, w, h)];
        [_fristImageView setImageWithURL:[NSURL URLWithString:[_imageArray objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"img_bg.png"]];
        _fristImageView.tag = 1000;
        _fristImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_fristImageView addGestureRecognizer:tap];
        [tap release];
        [_scrollView addSubview:_fristImageView];
        [_fristImageView release];
        // 设置ScrollView属性 contentSize 加上最后多加的那一页
        _scrollView.contentSize = CGSizeMake(([_imageArray count]+1)*w, h);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        
        // 半透明视图
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, 20)];
        label.center = CGPointMake(w*0.5, h-10);
        label.backgroundColor = [UIColor colorWithRed:0.65f green:0.65f blue:0.65f alpha:0.65f];
        [self addSubview:label];
        [label release];
        // 添加PageControl
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.center = CGPointMake(w/2, h-10);
        pageControl.bounds = CGRectMake(0, 0, 150, 20);
        // 一共显示多少个圆点（多少页）
        pageControl.numberOfPages = [_imageArray count]; 
        // 设置非选中页的圆点颜色
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        // 设置选中页的圆点颜色
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        // 禁止默认的点击功能
        pageControl.enabled = NO;
        [self addSubview:pageControl];
        _pageControl = pageControl;
        // 将scrollView添加到视图
        [self insertSubview:_scrollView atIndex:0];
    }
    return self;
}

#pragma mark - actions
-(void)imgClick:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(didClickImageView:)]) {
        [_delegate didClickImageView:tap.view.tag%100];
    }
}

-(void)setImageArray:(NSArray *)imageArray
{
    if (_imageArray != imageArray) {
        [_imageArray release];
        _imageArray = [imageArray retain];
    }
    // 添加内容图片视图imageView
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    for (int i = 0; i<[_imageArray count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0, w, h)];
        [imageView setImageWithURL:[NSURL URLWithString:[_imageArray objectAtIndex:i]] placeholderImage:[UIImage imageNamed:@"img_bg.png"]];
        imageView.tag = 100+i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
        [imageView addGestureRecognizer:tap];
        [tap release];
        [_scrollView addSubview:imageView];
        [imageView release];
    }
    if (!(_imageArray.count == 0)) {
        _fristImageView = [[UIImageView alloc] initWithFrame:CGRectMake([_imageArray count]*w, 0, w, h)];
        [_fristImageView setImageWithURL:[NSURL URLWithString:[_imageArray objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"img_bg.png"]];
        _fristImageView.tag = 1000;
        _fristImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_fristImageView addGestureRecognizer:tap];
        [tap release];
        [_scrollView addSubview:_fristImageView];
        // 设置ScrollView属性 contentSize 加上最后多加的那一页
        _scrollView.contentSize = CGSizeMake(([_imageArray count]+1)*w, h);
        _pageControl.numberOfPages = _imageArray.count;
    }
}

// 定时器响应方法，实现自动滚动
-(void)autoScroll:(NSTimer *)timer {
    if (_imageArray.count>0)
    {
        CGPoint offset = _scrollView.contentOffset;
        CGFloat width = _scrollView.frame.size.width;
        // 设置偏移量到下一页
        offset.x += width;
        [_scrollView setContentOffset:offset animated:YES];
    }
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = _scrollView.frame.size.width;
    // 循环滚动
    if (_scrollView.contentOffset.x / width == [_imageArray count]) {
        // 当翻转到‘假’的第一页，设置偏移量到真实的第一页 不开启动画
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    // 根据偏移量计算页码
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    _pageControl.currentPage = page%[_imageArray count];
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
