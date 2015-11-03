//
//  AboutView.h
//  ManZuo
//
//  Created by admin on 14-3-8.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutView;
@protocol AboutViewDelegate <NSObject>
-(void)aboutView:(AboutView *)aboutView didChackBtnClick:(UIButton *)btn;
@end

@interface AboutView : UIView
@property (nonatomic,weak) __weak id<AboutViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *vBtn;
- (IBAction)checkAction:(id)sender;

@end
