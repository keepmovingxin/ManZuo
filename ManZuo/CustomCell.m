//
//  CustomCell.m
//  ManZuo
//
//  Created by student on 14-3-4.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 137, 90)];
        sImageView.image = [UIImage imageNamed:@"photo_bg.png"];
        [self.contentView addSubview:sImageView];
        _pImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 20, 110, 65)];
        [self.contentView addSubview:_pImageView];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 5, 160, 50)];
        _nameLabel.numberOfLines = 2;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.font = [UIFont systemFontOfSize:18.0f];
        [self.contentView addSubview:_nameLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 55, 70, 30)];
        _priceLabel.textColor = [UIColor colorWithRed:0.91f green:0.38f blue:0.15f alpha:1.00f];
        _priceLabel.adjustsFontSizeToFitWidth = YES;
        _priceLabel.font = [UIFont boldSystemFontOfSize:26.0f];
        [self.contentView addSubview:_priceLabel];
        
        _oldPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 55, 90, 30)];
        _oldPriceLabel.font = [UIFont systemFontOfSize:14.0f];
        _oldPriceLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_oldPriceLabel];
        _lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 70, 50, 1)];
        _lineLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_lineLabel];
        
        UIImageView *ico1 = [[UIImageView alloc] initWithFrame:CGRectMake(140, 85, 11, 11)];
        ico1.image = [UIImage imageNamed:@"ico_peoples.png"];
        [self.contentView addSubview:ico1];
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(151, 80, 70, 22)];
        _countLabel.font = [UIFont systemFontOfSize:13.0f];
        _countLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_countLabel];
        
        UIImageView *ico2 = [[UIImageView alloc] initWithFrame:CGRectMake(210, 85, 11, 11)];
        ico2.image = [UIImage imageNamed:@"ico_locs.png"];
        [self.contentView addSubview:ico2];
        _placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(221, 80, 70, 22)];
        _placeLabel.font = [UIFont systemFontOfSize:13.0f];
        _placeLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_placeLabel];
        
        // ribbon_combinat.png
        _typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320-44, 0, 34, 12)];
        _typeImageView.image = [UIImage imageNamed:@"ribbon_combinat.png"];
        [self.contentView addSubview:_typeImageView];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
