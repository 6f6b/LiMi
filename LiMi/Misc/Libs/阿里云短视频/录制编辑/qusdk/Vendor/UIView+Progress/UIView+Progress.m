//
//  UIView+Progress.m
//  
//
//  Created by lslin on 14-6-13.
//  Copyright (c) 2014年 lessfun.com. All rights reserved.
//

#import "UIView+Progress.h"

#define MID(x, y, z)                      ( y < x ? x : (z < y ? z : y) )
#define CGRectSetSize(r, w1, h1)          CGRectMake(r.origin.x, r.origin.y, w1, h1)

static const int kPieProgressViewTag  = 201;
static const int kRectProgressViewTag  = 202;

@implementation PieProgressView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _progress = 1.0;
        _borderSpacing = 6;
        _progressColor = [UIColor clearColor];
        _backgroundMaskColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        self.tag = kPieProgressViewTag;
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = MAX(0, progress);
    if (_progress >= 1) {
        [self removeFromSuperview];
    }

    [self setNeedsDisplay];
}

#pragma mark draw progress

- (void)drawRect:(CGRect)rect
{
    CGFloat progressStart = -M_PI_2;
    CGFloat progressEnd = (-M_PI_2 + M_PI * 2 * self.progress);
    //progress
    [self drawRect:rect withColor:_progressColor.CGColor startAngle:-M_PI_2 endAngle:progressEnd];
    
    //background
    [self drawRect:rect withColor:_backgroundMaskColor.CGColor startAngle:progressEnd endAngle:progressStart];
}

- (void)drawRect:(CGRect)rect withColor:(CGColorRef)cgColor startAngle:(CGFloat)start endAngle:(CGFloat)end
{
    CGFloat radius = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) * 0.5 - _borderSpacing;
    CGFloat centerX = CGRectGetWidth(rect) * 0.5;
    CGFloat centerY = CGRectGetHeight(rect) * 0.5;
    
    CGContextRef progressContext = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(progressContext, cgColor);
    CGContextMoveToPoint(progressContext, centerX, centerY);
    CGContextAddArc(progressContext, centerX, centerY, radius, start, end, 0);
    CGContextClosePath(progressContext);
    CGContextFillPath(progressContext);
}

@end

#pragma mark - 

@implementation RectProgressView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _progress = 1.0;
        _progressColor = [UIColor clearColor];
        self.tag = kRectProgressViewTag;
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = MID(0, progress, 1);
    
    [self setNeedsDisplay];
}

#pragma mark draw progress

- (void)drawRect:(CGRect)rect
{
    [self.progressColor setFill];
    UIRectFill(CGRectSetSize(rect, CGRectGetWidth(rect) * self.progress, CGRectGetHeight(rect)));
}

@end

#pragma mark - UIView+Progress

@implementation UIView (Progress)

- (PieProgressView *)pieProgressView
{
    UIView *view = [self viewWithTag:kPieProgressViewTag];
    if (view && ![view isKindOfClass:[PieProgressView class]]) {
        return nil;
    }
    PieProgressView *progressOverlay = (PieProgressView *)view;
    if (!progressOverlay) {
        progressOverlay = [[PieProgressView alloc] initWithFrame:self.bounds];
        [self addSubview:progressOverlay];
    }
    return progressOverlay;
}

- (void)setPieProgress:(CGFloat)progress
{
    [[self pieProgressView] setProgress:progress];
}

- (RectProgressView *)rectProgressView
{
    UIView *view = [self viewWithTag:kRectProgressViewTag];
    if (view && ![view isKindOfClass:[RectProgressView class]]) {
        return nil;
    }
    RectProgressView *progressOverlay = (RectProgressView *)view;
    if (!progressOverlay) {
        progressOverlay = [[RectProgressView alloc] initWithFrame:self.bounds];
        [self addSubview:progressOverlay];
    }
    return progressOverlay;
}

- (void)setRectProgress:(CGFloat)progress
{
    [[self rectProgressView] setProgress:progress];
}


@end
