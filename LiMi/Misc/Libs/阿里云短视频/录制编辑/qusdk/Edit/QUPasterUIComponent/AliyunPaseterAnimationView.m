//
//  AliyunPaseterAnimationView.m
//  qusdk
//
//  Created by Vienta on 2017/5/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPaseterAnimationView.h"


@interface AliyunPaseterAnimationView ()

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) CAKeyframeAnimation *keyframeAnimation;
@property (nonatomic, assign) CGFloat textBeginTime;
@property (nonatomic, assign) CGFloat textDuration;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, strong) NSTimer *displayTimer;
@property (nonatomic, strong) NSMutableArray *imagePaths;

@end

@implementation AliyunPaseterAnimationView

static int displayIndex = 0;

- (NSMutableArray *)images {
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}

- (NSMutableArray *)imagePaths {
    if (!_imagePaths) {
        _imagePaths = [[NSMutableArray alloc] init];
    }
    return _imagePaths;
}

- (CAKeyframeAnimation *)keyframeAnimation {
    if (!_keyframeAnimation) {
        _keyframeAnimation = [CAKeyframeAnimation animation];
    }
    return _keyframeAnimation;
}

- (void)setupImages:(NSArray *)imagePaths duration:(CGFloat)duration {
    [self.imagePaths removeAllObjects];
    [self.imagePaths addObjectsFromArray:imagePaths];
    self.duration = duration;
}

- (void)setupImages:(NSArray *)imagePaths duration:(CGFloat)duration textBeginTime:(CGFloat)beginTime textDuration:(CGFloat)textDuration {
    [self setupImages:imagePaths duration:duration];
    self.textBeginTime = beginTime;
    self.textDuration = textDuration;
}

- (void)updateImages:(NSArray *)imagePaths duration:(CGFloat)duration {
    [self.images removeAllObjects];
    [self setupImages:imagePaths duration:duration];
}

- (void)run {
    NSTimeInterval interval = self.duration / self.imagePaths.count;
    
    [self.displayTimer invalidate];
    self.displayTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(playFrame) userInfo:nil repeats:YES];
    [self.displayTimer fire];
}

- (void)playFrame {
    int picIdx = displayIndex % self.imagePaths.count;
    UIImage *image = [UIImage imageWithContentsOfFile:[self.imagePaths objectAtIndex:picIdx]];
    
    self.image = image;
    displayIndex++;
    
    CGFloat time = picIdx * (self.duration / self.imagePaths.count);
    if (time >= self.textBeginTime && time <= self.textBeginTime + self.textDuration) {
        if (self.textAppearanceBlock) {
            self.textAppearanceBlock(YES);
        }
    } else {
        if (self.textAppearanceBlock) {
            self.textAppearanceBlock(NO);
        }
    }
}

- (void)stop {
    self.animationImages = nil;
    [self.images removeAllObjects];
    [self.displayTimer invalidate];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self stop];
}

@end
