//
//  AliyunEditZoneView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditZoneView.h"


@implementation AliyunEditZoneView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint preLocation = [[touches anyObject] previousLocationInView:self];
    [self.delegate currentTouchPoint:preLocation];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint fp = [touch previousLocationInView:self];
    CGPoint tp = [touch locationInView:self];
//    [_currentPasterView touchMoveFromPoint:fp to:tp];
    [self.delegate mv:fp to:tp];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.delegate touchEnd];
//    [_currentPasterView touchEnd];
//    _currentPasterView = nil;
}

@end
