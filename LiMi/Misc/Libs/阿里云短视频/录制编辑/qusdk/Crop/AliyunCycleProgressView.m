//
//  AliyunCycleProgressView.m
//
//  Created by TripleL on 17/5/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCycleProgressView.h"

#define ProgressWidth 3
#define Radius self.frame.size.width / 2

@interface AliyunCycleProgressView ()
{
    
    CAShapeLayer *arcLayer;
    UILabel *label;
    NSTimer *progressTimer;
}
@property (nonatomic,assign)CGFloat i;

@end

@implementation AliyunCycleProgressView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setHidden:YES];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHidden:YES];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    int radius = rect.size.height / 2 - 5;
    int x = rect.origin.x + rect.size.width / 2;
    int y = rect.origin.y + rect.size.height / 2;
    
    // 底层色
    CGContextRef ctx1 = UIGraphicsGetCurrentContext();
    [self.progressBackgroundColor set];
    CGContextSetLineWidth(ctx1, 3);
    CGContextSetLineCap(ctx1, 1);
    CGFloat to1 = - M_PI * 0.5 + M_PI * 2 + 0.05;
    CGContextAddArc(ctx1, x, y, radius, - M_PI * 0.5, to1, 1);
    CGContextStrokePath(ctx1);
    
    // 上层色
    CGContextRef ctx2 = UIGraphicsGetCurrentContext();
    [self.progressColor set];
    CGContextSetLineWidth(ctx2, 3);
    CGContextSetLineCap(ctx2, 1);
    CGFloat to2 = - M_PI * 0.5 + (1 - self.progress) * (-M_PI * 2);
    CGContextAddArc(ctx2, x, y, radius, - M_PI * 0.5, to2, 0);
    CGContextStrokePath(ctx2);
}


- (void)setProgress:(CGFloat)progress {
    _progress =progress;
    [self setNeedsDisplay];
    if (_progress <= 0) {
        [self setHidden:YES];
    } else {
        [self setHidden:NO];
    }
}



@end
