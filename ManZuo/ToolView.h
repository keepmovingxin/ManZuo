//
//  ToolView.h
//  ManZuo
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolView;
@protocol ToolViewDelegate <NSObject>
-(void)toolView:(ToolView *)toolView didBtnClick:(UIButton *)btn;
@end

@interface ToolView : UIView

@property (nonatomic,weak) __weak id<ToolViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *bayBtn;
- (IBAction)bayAction:(id)sender;

@end
