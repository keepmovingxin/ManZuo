//
//  AppUtil.m
//  AppUtilDemo
//
//  Created by qianfeng on 13-12-29.
//  Copyright (c) 2013年 lgx. All rights reserved.
//

#import "AppUtil.h"

@implementation AppUtil

+(NSString *)getCachesPath
{
    return [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
}

+ (NSString *)getAppPath
{
    return [NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] resourcePath]];
}

@end
