//
//  AnimationTool.h
//  UINavigationAnimation切换动画
//
//  Created by qianfeng on 14-1-3.
//  Copyright (c) 2014年 lgx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AnimationTool : NSObject

// 创建CATransition动画的类方法
+(CATransition *)addAnimationWithType:(NSString *)type andSubtype:(NSString *)subtype andDuration:(CGFloat)duration andTimingFunction:(NSString *)functionName;
+(CATransition *)addAnimationCubeWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration;
+(CATransition *)addAnimationSuckEffectWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration;
+(CATransition *)addAnimationRippleEffectWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration;
+(CATransition *)addAnimationOglFlipWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration;
+(CATransition *)addAnimationPageCurlWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration;
+(CATransition *)addAnimationPageUnCurlWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration;

@end
