//
//  QUProgressView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "QUProgressView.h"

@implementation QUProgressView {
    NSTimer *_timer;
    NSInteger _times;
    CGFloat _progress;
    CGFloat _lineWidth;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [AliyunIConfig config].timelineBackgroundCollor;
        [self defaultParam];
    }
    return self;
}

- (void)defaultParam {
    _pointArray = [NSMutableArray arrayWithCapacity:0];
    _lineWidth = CGRectGetHeight(self.bounds) * [UIScreen mainScreen].scale;
    _colorNotice = [UIColor whiteColor];
    _colorProgress = [AliyunIConfig config].timelineTintColor;
    _colorSepatorPoint = [UIColor whiteColor];
    _colorSelect = [AliyunIConfig config].timelineDeleteColor;
    _selectedIndex = -1;
}

- (void)setShowBlink:(BOOL)showBlink {
    _showBlink = showBlink;
    [self destroyTimer];
    if (_showBlink) {
        [self startTimer];
    }
}

- (void)setShowNoticePoint:(BOOL)showNoticePoint {
    _showNoticePoint = showNoticePoint;
}

- (void)destroyTimer {
    [_timer invalidate];
    _timer = nil;
    
}

- (void)setVideoCount:(NSInteger)videoCount {
    
    if (_videoCount < videoCount) {
        [_pointArray addObject:@(_progress)];
    } else {
        [_pointArray removeLastObject];
    }
    
    _videoCount = videoCount < 0 ? 0 : videoCount;
    _selectedIndex = -1;
}

- (void)updateProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                            selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _lineWidth);
    
    CGFloat w = CGRectGetWidth(self.superview.bounds);
    
    for (int i = 0; i < _videoCount; i++) {
        CGFloat sp = [_pointArray[i] floatValue];
        if (i == _selectedIndex) {
            CGContextSetStrokeColorWithColor(context, _colorSelect.CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, _colorProgress.CGColor);
        }
        CGFloat x = sp / _maxDuration * w;
        CGContextMoveToPoint(context, x, 0);
        x = _progress / _maxDuration * w;
        CGContextAddLineToPoint(context, x, 0);
        CGContextStrokePath(context);
    }
    
    for (int i = 0; i < _pointArray.count; i++) {
        CGFloat p = [_pointArray[i] floatValue];
        CGContextSetStrokeColorWithColor(context, _colorSepatorPoint.CGColor);
        CGFloat x = p / _maxDuration * w;
        CGContextMoveToPoint(context, x - 1, 0);
        CGContextAddLineToPoint(context, x, 0);
        CGContextStrokePath(context);
    }
    
    if (_showNoticePoint && [self shouldShowNotice]) {
        CGContextSetStrokeColorWithColor(context, _colorNotice.CGColor);
        CGContextMoveToPoint(context, w * _minDuration/_maxDuration, 0);
        CGContextAddLineToPoint(context, w * _minDuration/_maxDuration + 1,0);
        CGContextStrokePath(context);
    }
    
    if ( _showBlink && (_showBlink ? ++_times : (_times=1)) && (_times%2 == 1)) {
        
        CGFloat x = [self endPointX];
        CGContextSetStrokeColorWithColor(context, [[AliyunIConfig config] timelineBackgroundCollor].CGColor);
        CGContextMoveToPoint(context, x + 0.5, 0);
        CGContextAddLineToPoint(context, x + 4, 0);
        CGContextStrokePath(context);
    }
}

- (CGFloat)endPointX {
    return _progress / _maxDuration * CGRectGetWidth(self.bounds);
}

- (BOOL)shouldShowNotice {
    return _progress < _minDuration;
}

-(void)reset {
    _videoCount = 0;
    [_pointArray removeAllObjects];
    [self updateProgress:0];
}

@end
