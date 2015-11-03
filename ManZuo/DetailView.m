//
//  DetailView.m
//  ManZuo
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "DetailView.h"

@implementation DetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:self options:nil] lastObject];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)buttonAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(detailView:didBtnClick:)]) {
        [_delegate detailView:self didBtnClick:sender];
    }
}
@end
