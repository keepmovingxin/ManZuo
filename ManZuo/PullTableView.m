//
//  PullTableView.m
//  XianMianApp
//
//  Created by admin on 14-2-22.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "PullTableView.h"

@implementation PullTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isMore = YES;
        [self initSubViews];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.isMore = YES;
        [self initSubViews];
    }
    return self;
}

-(void)awakeFromNib
{
    [self initSubViews];
}

-(void)initSubViews
{
    self.delegate = self;
    // iOS6刷新控件
    _refreshControl = [[UIRefreshControl alloc] init];
    // 设置RefreshControl上的显示文本
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    _refreshControl.attributedTitle = title;
    // 设置RefreshControl的颜色
    _refreshControl.tintColor = [UIColor lightGrayColor];
    // 设置监听RefreshControl刷新状态
    [_refreshControl addTarget:self action:@selector(pullDown) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_refreshControl];
    
    // 上拉加载更多按钮
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreButton.backgroundColor = [UIColor clearColor];
    _moreButton.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_moreButton setBackgroundImage:[UIImage imageNamed:@"loadmore.png"] forState:UIControlStateNormal];
    [_moreButton setTitle:@"上拉显示更多..." forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(loadMoreAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(100, 10, 20, 20);
    activityView.tag = 101;
    [activityView stopAnimating];
    [_moreButton addSubview:activityView];
    
    self.tableFooterView = _moreButton;
}

#pragma mark - UIRefreshControl Action 下拉
// 下拉刷新开始
-(void)pullDown
{
    if ([_pullDelegate respondsToSelector:@selector(didPullDown:)]) {
        [_pullDelegate didPullDown:self];
    }
}

// 下拉刷新结束
-(void)loadPullDownDataFinish
{
    // RefreshControl结束刷新
    [_refreshControl endRefreshing];
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy年MM月dd日 hh:mm:ss"];
    NSString *locationTime = [dateformatter stringFromDate:senddate];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"上一次刷新时间：%@",locationTime]];
    _refreshControl.attributedTitle = title;
}

#pragma mark - moreBtn Action 上拉
-(void)loadMoreAction
{
    if ([_pullDelegate respondsToSelector:@selector(didPullUp:)]) {
        [_pullDelegate didPullUp:self];
        
        [self startLoadMore];
    }
}

// 开始加载提示
- (void)startLoadMore {
    [_moreButton setTitle:@"正在加载..." forState:UIControlStateNormal];
    // 加载中禁用moreButton
    _moreButton.enabled = NO;
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[_moreButton viewWithTag:101];
    [activityView startAnimating];
}

-(void)loadPullUpDataFinish
{
    [self stopLoadMore];
}

// 停止加载提示
- (void)stopLoadMore
{
    [_moreButton setTitle:@"上拉显示更多..." forState:UIControlStateNormal];
    // 加载完启用moreButton
    _moreButton.enabled = YES;
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[_moreButton viewWithTag:101];
    [activityView stopAnimating];
    if (!self.isMore) {
        [_moreButton setTitle:@"没有更多了" forState:UIControlStateNormal];
        _moreButton.enabled = NO;
    }
}

#pragma mark - UITableView Delegate
// 选中cell
- (void)tableView:(PullTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_pullDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    {
        [_pullDelegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

// 将要显示cell
-(void)tableView:(PullTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_pullDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
    {
        [_pullDelegate tableView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([_pullDelegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)])
    {
        [_pullDelegate tableView:self willDisplayHeaderView:view forSection:section];
    }
}
//  返回cell高度
-(CGFloat)tableView:(PullTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_type == DEFAULTCELL)
    {
        return 100.0f;
    } else if (_type == PROTECTCELL)
    {
        return 200.0f;
    }
    return 44.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_showHeaderView)
    {
        UIView *shView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        shView.backgroundColor = [UIColor clearColor];
        shView.userInteractionEnabled = YES;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"leftDrop_bg.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"leftDrop_bg_press.png"] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:@"leftDrop_bg_selected.png"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"leftDrop_bg_disable.png"] forState:UIControlStateDisabled];
        btn.tag = 101;
        btn.frame = CGRectMake(0, 0, 160, 40);
        [btn setTitle:@"全部" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"all.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shView addSubview:btn];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.backgroundColor = [UIColor clearColor];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"rightDrop_bg.png"] forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"rightDrop_bg_press.png"] forState:UIControlStateHighlighted];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"rightDrop_bg_selected.png"] forState:UIControlStateSelected];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"rightDrop_bg_disable.png"] forState:UIControlStateDisabled];
        btn1.tag = 102;
        btn1.frame = CGRectMake(160, 0, 160, 40);
        [btn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        int st = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sorttype"] intValue];
        NSString *title = nil;
        if (st == 0 || st == -1)
        {
            title = @"人气最高";
        } else if (st == 2)
        {
            title = @"价格最低";
        } else if (st == -3)
        {
            title = @"最新发布";
        } else if (st == 4)
        {
            title = @"折扣最低";
        }
        [btn1 setTitle:title forState:UIControlStateNormal];
        [btn1 setImage:[UIImage imageNamed:@"sort.png"] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shView addSubview:btn1];
        
        return shView;
    }
    return nil;
}

-(void)btnClick:(UIButton *)btn
{
    if (_selectBtn)
    {
        [_selectBtn setSelected:NO];
    }
    _selectBtn = btn;
    [btn setSelected:!btn.selected];
    if (btn.tag == 101)
    {
        if ([_pullDelegate respondsToSelector:@selector(didLeftBtnClicked:)])
        {
            // 左边按钮 分类
            [_pullDelegate didLeftBtnClicked:btn];
        }
    } else if (btn.tag == 102)
    {
        if ([_pullDelegate respondsToSelector:@selector(didRightBtnClicked:)])
        {
            // 右边按钮 排序
            [_pullDelegate didRightBtnClicked:btn];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_showHeaderView)
    {
        return 40.0f;
    }
    return 0.0f;
}

#pragma mark - UIScrollView Delegate
// 手指停止拖拽时调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.isMore) {
        return;
    }
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    // 当刚好滑至底部时，offset和contentHeight的差值是scrollView的高度
    float sub = contentHeight - offset;
    // 如果向上拉大于50，调用代理刷新方法
    if (scrollView.frame.size.height - sub>50) {
        [self startLoadMore];
        if ([_pullDelegate respondsToSelector:@selector(didPullUp:)]) {
            // 调用事件代理协议方法,上拉刷新
            [_pullDelegate didPullUp:self];
        }
    }
    
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
