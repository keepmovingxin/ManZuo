//
//  CateCell.m
//  ManZuo
//
//  Created by admin on 14-3-6.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CateCell.h"

@implementation CateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7.5, 20, 25)];
        [self.contentView addSubview:_iconView];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 100, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_titleLabel];
        _inderView  = [[UIImageView alloc] initWithFrame:CGRectMake(140, 15, 6, 10)];
        _inderView.image = [UIImage imageNamed:@"drop_arrow.png"];
        [self.contentView addSubview:_inderView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
