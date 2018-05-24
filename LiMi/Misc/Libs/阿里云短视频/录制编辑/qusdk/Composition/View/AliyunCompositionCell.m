//
//  AliyunCompositionCell.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompositionCell.h"

@implementation AliyunCompositionCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
    self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.labelDuration.textColor = RGBToColor(239, 75, 129);
    self.labelDuration.textAlignment = NSTextAlignmentRight;
    self.labelDuration.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:self.labelDuration];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.labelDuration.frame = CGRectMake(5, CGRectGetHeight(self.frame) - 20, CGRectGetWidth(self.frame)-10, 20);
}

@end
