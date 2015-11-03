//
//  AppUtil.h
//  AppUtilDemo
//
//  Created by qianfeng on 13-12-29.
//  Copyright (c) 2013年 lgx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject
//取得caches目录
+ (NSString *)getCachesPath;
//取得App目录
+ (NSString *)getAppPath;
@end
