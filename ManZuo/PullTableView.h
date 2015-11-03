//
//  PullTableView.h
//  XianMianApp
//
//  Created by admin on 14-2-22.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULTCELL 1
#define PROTECTCELL 2

@class PullTableView;
@protocol PullTableViewPullDelegate <NSObject>
@optional
// 下拉刷新开始
-(void)didPullDown:(PullTableView *)tableView;
// 上拉加载
-(void)didPullUp:(PullTableView *)tableView;
// 选中cell
- (void)tableView:(PullTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
// 将要显示cell
-(void)tableView:(PullTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
// 将要显示headerView
-(void)tableView:(PullTableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
// 头视图左边按钮被点击
-(void)didLeftBtnClicked:(UIButton *)btn;
// 头视图右边按钮被点击
-(void)didRightBtnClicked:(UIButton *)btn;
@end

@interface PullTableView : UITableView<UITableViewDelegate>
{
    UIRefreshControl *_refreshControl;
    UIButton *_moreButton;
    // 头视图选中的按钮
    UIButton *_selectBtn;
}

@property (nonatomic,weak) __weak id<PullTableViewPullDelegate> pullDelegate;
// 根据type确定cell的高度
@property (nonatomic)int type;
// 是否还有下一页(更多)
@property (nonatomic,assign) BOOL isMore;
@property (nonatomic,assign) BOOL showHeaderView;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) UIButton *moreButton;
@property (nonatomic,strong) UIButton *selectBtn;
// 下拉刷新结束
-(void)loadPullDownDataFinish;
// 上拉加载结束
-(void)loadPullUpDataFinish;

@end
