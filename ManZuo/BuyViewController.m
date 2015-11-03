//
//  BuyViewController.m
//  ManZuo
//
//  Created by admin on 14-3-9.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "BuyViewController.h"

@interface BuyViewController ()

@end

@implementation BuyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"提交订单";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture.png"]];
    _scrollView.frame = CGRectMake(0, 64, 320, 480-64);
    [_scrollView setContentSize:CGSizeMake(320, 310)];
    _scrollView.delaysContentTouches = NO;
    _titleLabel.text = _proItem.name;
    _priceLabel.text = [NSString stringWithFormat:@"¥%@",_proItem.currentPrice];
    _totalPrice.text = [NSString stringWithFormat:@"¥%@",_proItem.currentPrice];
    _countField.keyboardType = UIKeyboardTypeNumberPad;
    _nameField.text = @"";
    _phoneField.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UITextField *)getFristResponder
{
    if (_countField.isFirstResponder) {
        return _countField;
    } else if (_nameField.isFirstResponder) {
        return _nameField;
    } else if (_phoneField.isFirstResponder) {
        return _phoneField;
    }
    return nil;
}

-(void)keyboardShow
{
    [_scrollView setContentSize:CGSizeMake(320, 310+256)];
    [_scrollView setContentOffset:CGPointMake(0, [self getFristResponder].center.y-30) animated:YES];
}

-(void)keyboardHide
{
    [_scrollView setContentSize:CGSizeMake(320, 310)];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)numChange:(id)sender {
    UIButton *numBtn = (UIButton *)sender;
    int count = [_countField.text intValue];
    if (numBtn.tag == 101)
    {
        if (count>1) {
            count--;
        }
    } else if (numBtn.tag == 102)
    {
        if (count<100) {
            count++;
        }
    }
    _countField.text = [NSString stringWithFormat:@"%d",count];
    float total = count*[_proItem.currentPrice floatValue];
    _totalPrice.text = [NSString stringWithFormat:@"¥%0.1f",total];
}

- (IBAction)buyAction:(id)sender {
    [self.view endEditing:YES];
    // 去支付宝支付
    
}
@end
