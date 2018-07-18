//
//  UIButton+Swizzling.m
//  UIButtonDemo
//
//  Created by dev.liufeng on 2018/6/1.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "UIButton+Swizzling.h"
#import <objc/runtime.h>

@implementation UIButton (Swizzling)
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Load excuted");
        Method m1 = class_getInstanceMethod([self class], @selector(swizzling_pointInside:withEvent:));
        Method m2 = class_getInstanceMethod([self class], @selector(pointInside:withEvent:));
        method_exchangeImplementations(m1, m2);
    });
}


- (BOOL)swizzling_pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [super pointInside:point withEvent:event];
}

//static inline void swizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector){
//    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
//    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
//
//    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//    if (success) {
//        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}
@end
