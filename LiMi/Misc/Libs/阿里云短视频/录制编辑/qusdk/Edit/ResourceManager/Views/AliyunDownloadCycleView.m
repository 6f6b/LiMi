//
//  AliyunDownloadCycleView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunDownloadCycleView.h"

#define CGPointCenterPointOfRect(rect) CGPointMake(rect.origin.x + rect.size.width / 2.0f, rect.origin.y + rect.size.height / 2.0f)

@interface AliyunDownloadCycleView () {
    CGFloat oldFrameWidth;
}
@end

@implementation AliyunDownloadCycleView

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineWidth = 10.0f;
        self.progressBackgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
        self.progressColor = [UIColor redColor];
        
        self.backgroundColor = [UIColor clearColor];
        oldFrameWidth = frame.size.width;
        
        self.contentMode = UIViewContentModeRedraw;
    }
    
    return self;
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // scale linewidth and font to match new size
    CGFloat w = self.frame.size.width;
    if (w == 0) {
        return;
    }
    if (oldFrameWidth == 0) { // skip scale if initial frame width is zero
        oldFrameWidth = w;
    }
    CGFloat scale = w/oldFrameWidth;
    if (scale != 1.0) {
        _lineWidth *= scale;
    }
    oldFrameWidth = w;
}

- (void)drawRect:(CGRect)rect {
    
    [self drawBackground:rect];
    [self drawProgress:rect];
}

- (void)drawBackground:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([self.progressBackgroundColor CGColor]));
    CGContextFillPath(ctx);
    
}

- (CGFloat) radius {
    
    return self.frame.size.width/2.0;
}

- (void) setRadius:(CGFloat)radius {
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, radius*2.0f, radius*2.0f);
}

- (void)drawProgress:(CGRect)rect {
    
    CGFloat radius = [self radius];
    CGFloat radiusMinusLineWidth = radius - self.lineWidth / 2;
    CGFloat percentage = self.percentage;

    BOOL clockwise = YES;

    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + percentage * 2 * M_PI;
    
    [self drawProgressArcWithStartAngle:startAngle endAngle:endAngle radius:radiusMinusLineWidth clockwise:clockwise];
    
}

- (void)drawProgressArcWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle radius:(CGFloat)radius clockwise:(BOOL)clockwise {
    
    UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:CGPointCenterPointOfRect(self.bounds)
                                                                  radius:radius
                                                              startAngle:startAngle
                                                                endAngle:endAngle
                                                               clockwise:clockwise];
    
    [self.progressColor setStroke];
    progressCircle.lineWidth = self.lineWidth;
    [progressCircle stroke];
}



#pragma mark - Public
- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    
    _progressBackgroundColor = progressBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setPercentage:(CGFloat)percentage {
    
    _percentage = fminf(fmax(percentage, 0), 1);
    [self setNeedsDisplay];
}


@end
