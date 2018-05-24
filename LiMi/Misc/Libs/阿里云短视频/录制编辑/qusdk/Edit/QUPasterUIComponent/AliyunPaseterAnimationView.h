//
//  AliyunPaseterAnimationView.h
//  qusdk
//
//  Created by Vienta on 2017/5/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//
// 动图序列帧播放
#import <UIKit/UIKit.h>

@interface AliyunPaseterAnimationView : UIImageView


@property (nonatomic, copy) void (^textAppearanceBlock)(BOOL isAppear);

- (void)setupImages:(NSArray *)imagePaths duration:(CGFloat)duration;

- (void)setupImages:(NSArray *)imagePaths duration:(CGFloat)duration textBeginTime:(CGFloat)beginTime textDuration:(CGFloat)textDuration;

- (void)updateImages:(NSArray *)imagePaths duration:(CGFloat)duration;

- (void)run;

- (void)stop;



@end
