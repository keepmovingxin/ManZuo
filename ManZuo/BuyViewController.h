//
//  BuyViewController.h
//  ManZuo
//
//  Created by admin on 14-3-9.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BaseViewController.h"
#include "PromotionItem.h"

@interface BuyViewController : BaseViewController

@property (nonatomic,strong) PromotionItem *proItem;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutlet UITextField *countField;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
- (IBAction)numChange:(id)sender;
- (IBAction)buyAction:(id)sender;

@end
