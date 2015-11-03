//
//  DetailView.h
//  ManZuo
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailView;
@protocol DetailViewDelegate <NSObject>
-(void)detailView:(DetailView *)detailView didBtnClick:(UIButton *)btn;
@end

@interface DetailView : UIView

@property (nonatomic,weak) __weak id<DetailViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *proImageView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UIButton *dayBtn;
@property (strong, nonatomic) IBOutlet UIButton *refunBtn;
@property (strong, nonatomic) IBOutlet UIWebView *actWebView;

- (IBAction)buttonAction:(id)sender;

@end
