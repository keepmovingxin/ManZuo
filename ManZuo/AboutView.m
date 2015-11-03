//
//  AboutView.m
//  ManZuo
//
//  Created by admin on 14-3-8.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "AboutView.h"

@implementation AboutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"AboutView" owner:self options:nil] lastObject];
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

- (IBAction)checkAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(aboutView:didChackBtnClick:)]) {
        [_delegate aboutView:self didChackBtnClick:sender];
    }
}
@end
