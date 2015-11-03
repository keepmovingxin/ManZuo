//
//  AnimationTool.m
//  UINavigationAnimation切换动画
//  CATransition动画
//  Created by qianfeng on 14-1-3.
//  Copyright (c) 2014年 lgx. All rights reserved.
//

#import "AnimationTool.h"

@implementation AnimationTool

/*
 私有动画API:
 cube(立方体)、suckEffect(收缩)、oglFlip(上下翻转)、
 rippleEffect(滴水)、pageCurl(向上翻一页)、pageUnCurl(向下翻一页)
 */

+(CATransition *)addAnimationWithType:(NSString *)type andSubtype:(NSString *)subtype andDuration:(CGFloat)duration andTimingFunction:(NSString *)functionName {
    // 获得CATransition的实例
    CATransition *animation = [CATransition animation];
    // 设置动画类型
    animation.type = type;
    // 设置动画的subtype(动画方向)
    animation.subtype = subtype;
    // 设置动画时长
    animation.duration = duration;
    // 设置动画效果(即动画模式)
    /*
    kCAMediaTimingFunctionDefault 
    kCAMediaTimingFunctionEaseIn 
    kCAMediaTimingFunctionEaseInEaseOut 
    kCAMediaTimingFunctionEaseOut 
    kCAMediaTimingFunctionLinear 
    */
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:functionName]];
    return animation;
}

//  cube(立方体)
+(CATransition *)addAnimationCubeWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration {
   return [self addAnimationWithType:@"cube" andSubtype:subtype andDuration:duration andTimingFunction:kCAMediaTimingFunctionLinear];
}

//  suckEffect(收缩)
+(CATransition *)addAnimationSuckEffectWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration {
    return [self addAnimationWithType:@"suckEffect" andSubtype:subtype andDuration:duration andTimingFunction:kCAMediaTimingFunctionLinear];
}

// rippleEffect(滴水)
+(CATransition *)addAnimationRippleEffectWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration {
    return [self addAnimationWithType:@"rippleEffect" andSubtype:subtype andDuration:duration andTimingFunction:kCAMediaTimingFunctionLinear];
}

// oglFlip(上下翻转)
+(CATransition *)addAnimationOglFlipWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration {
    return [self addAnimationWithType:@"oglFlip" andSubtype:subtype andDuration:duration andTimingFunction:kCAMediaTimingFunctionLinear];
}

// pageCurl(向上翻一页)
+(CATransition *)addAnimationPageCurlWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration {
    return [self addAnimationWithType:@"pageCurl" andSubtype:subtype andDuration:duration andTimingFunction:kCAMediaTimingFunctionLinear];
}

// pageUnCurl(向下翻一页)
+(CATransition *)addAnimationPageUnCurlWithSubtype:(NSString *)subtype andDuration:(CGFloat)duration {
    return [self addAnimationWithType:@"pageUnCurl" andSubtype:subtype andDuration:duration andTimingFunction:kCAMediaTimingFunctionLinear];
}
@end
