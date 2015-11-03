//
//  UISearchBar+UITextField.m
//  ManZuo
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "UISearchBar+UITextField.h"

@implementation UISearchBar (UITextField)
-(UITextField*)textField
{
    UITextField *textField = nil ;
    for ( UIView *subView in self.subviews) {
        for (UIView *view in subView.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                textField = (UITextField*)view;
            }
        }

    }
    return textField;
}
@end
