//
//  AliyunMusicLineView.m
//  qusdk
//
//  Created by Worthy on 2017/6/8.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicLineView.h"
int AliyunMusicLineSeeds[40] =
   {1,2,3,2,2,
    3,4,4,3,5,
    6,7,7,6,5,
    4,3,4,5,4,
    3,3,4,3,4,
    2,3,5,6,7,
    7,6,7,6,5,
    4,3,2,2,2};

@implementation AliyunMusicLineView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _seed = time(NULL);
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    srand((unsigned int)_seed);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat gap = 1;
    CGFloat lineWidth = 3;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, self.bounds);
    int count = 0;
    for (int offset = lineWidth; offset < (width-lineWidth); offset += (gap+lineWidth)) {
        int seed = rand() % 10 + 1;
//        int seed = AliyunMusicLineSeeds[count%40];
        CGFloat lineHeight = seed/9.0f * height;
        CGContextMoveToPoint(context, offset, (height-lineHeight)/2);
        CGContextAddLineToPoint(context, offset, (height+lineHeight)/2);
        CGContextStrokePath(context);
        count ++;
    }
}

- (void)refresh {
    [self setNeedsDisplay];
}


@end
