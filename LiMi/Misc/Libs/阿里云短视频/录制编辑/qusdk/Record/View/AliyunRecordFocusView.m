//
//  QURecordFoucesView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/10.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordFocusView.h"

@interface AliyunRecordFocusView ()
@property (nonatomic, strong) UIImageView *focusView;
@property (nonatomic, strong) AliyunLightProgress *lightProgress;
@end

@implementation AliyunRecordFocusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        
        _focusView = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"record_focus"]];
        [self addSubview:_focusView];
        
        CGRect rectLight = CGRectMake(0, 0, 12, 140);
        _lightProgress = [[AliyunLightProgress alloc] initWithFrame:rectLight];
        _lightProgress.progress = 0.5;
        [self addSubview:_lightProgress];
        self.frame = _focusView.frame;
    }
    return self;
}

- (void)setAutoFocus:(BOOL)autoFocus {
    _autoFocus = autoFocus;
    _lightProgress.hidden = NO;
}

- (void)refreshPosition {
    CGFloat x = -12;
    self.alpha = 1;
    if (CGRectGetMaxX(self.frame) < ScreenWidth - 60) {
        x = CGRectGetWidth(self.bounds) + 12;
    }
    _lightProgress.center = CGPointMake(x, CGRectGetHeight(self.bounds)/2.0);
    
    [self startDismiss];
}

- (void)changeExposureValue:(CGFloat)value {
    CGFloat v = _lightProgress.progress + value;
    if (v >= 0 || v <= 1.0) {
        _lightProgress.progress = value;
    }
    [self startDismiss];
}

- (void)startDismiss {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(dismissFirst:) withObject:nil afterDelay:1.5];
}

- (void)dismissFirst:(id)obj {
    self.alpha = 0.7;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(dismissSecond:) withObject:nil afterDelay:1.0];
}

- (void)dismissSecond:(id)obj {
    if (self.alpha == 0) {
        return;
    }
    [self.layer removeAllAnimations];
    self.alpha = 0.7;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:nil];
}

@end


@implementation AliyunLightProgress {
    UIImageView *_imageViewAdd;
    UIImageView *_imageViewSub;
    UIImageView *_imageViewLight;
    
    CGFloat _lineAddYFrom;
    CGFloat _lineAddYTo;
    CGFloat _lineSubYFrom;
    CGFloat _lineSubTo;
    
    CGFloat _lineX;
    CGFloat _lineCap;
    CGFloat _lineHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _imageViewAdd = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"record_light_up"]];
        _imageViewLight = [[UIImageView alloc]initWithFrame:CGRectMake(0, 15, 20, 19)];
        _imageViewSub = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"record_light_down"]];
        _imageViewLight.image = [AliyunImage imageNamed:@"record_light_sun"];
        
        [self addSubview:_imageViewAdd];
        [self addSubview:_imageViewLight];
        [self addSubview:_imageViewSub];
        
        _lineCap = 2;
        _lineX = CGRectGetWidth(frame)/2.f;
    }
    return self;
}

- (void)refreshPosition {
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat addH = CGRectGetHeight(_imageViewAdd.bounds);
    CGFloat subH = CGRectGetHeight(_imageViewSub.bounds);
    CGFloat lightH = CGRectGetHeight(_imageViewLight.bounds);
    CGFloat lineH = h - addH - subH - lightH - _lineCap * 4;
    CGFloat y = 0;
    
    y += addH/2.0;
    _imageViewAdd.center = CGPointMake(_lineX, y);
    
    y += addH/2.0 + _lineCap;
    _lineAddYFrom = y;
    
    y += lineH * ( 1- _progress);
    _lineAddYTo = y;
    
    y += _lineCap + lightH/2.0;
    _imageViewLight.center = CGPointMake(_lineX, y);
    
    y += lightH/2.0 + _lineCap;
    _lineSubYFrom = y;
    
    y += lineH * _progress;
    _lineSubTo = y;
    
    y += _lineCap + subH/2.0;
    _imageViewSub.center = CGPointMake(_lineX, y);
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self refreshPosition];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor ].CGColor);
    
    CGContextMoveToPoint(context, _lineX, _lineSubYFrom);
    CGContextAddLineToPoint(context, _lineX, _lineSubTo);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, _lineX, _lineAddYFrom);
    CGContextAddLineToPoint(context, _lineX, _lineAddYTo);
    CGContextStrokePath(context);
}

@end
