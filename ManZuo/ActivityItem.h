//
//  ActivityItem.h
//  ManZuo
//
//  Created by student on 14-3-4.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityItem : NSObject

@property (nonatomic) int actId;
@property (nonatomic) int actType;
@property (nonatomic,copy) NSString *actName;
@property (nonatomic) int itarget;
@property (nonatomic,copy) NSString *imgUrl;
@property (nonatomic,copy) NSString *durl;

@end
