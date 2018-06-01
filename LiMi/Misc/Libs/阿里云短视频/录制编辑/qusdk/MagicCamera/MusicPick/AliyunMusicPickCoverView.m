//
//  AliyunMusicPickCoverView.m
//  qusdk
//
//  Created by Worthy on 2017/6/13.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickCoverView.h"

@interface AliyunMusicPickCoverView()
@property (nonatomic, strong) UIView *left;
@property (nonatomic, strong) UIView *right;
@property (nonatomic, strong) UIImageView *middle;
@end

@implementation AliyunMusicPickCoverView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

-(void)setupSubviews {
    self.userInteractionEnabled = NO;
    self.left = [[UIView alloc] initWithFrame:CGRectZero];
    self.left.backgroundColor = rgba(0, 0, 0, 0.3);
    [self addSubview:self.left];
    self.middle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CropBox"]];
    [self addSubview:self.middle];
    self.right = [[UIView alloc] initWithFrame:CGRectZero];
    self.right.backgroundColor = rgba(0, 0, 0, 0.3);
    [self addSubview:self.right];
    [self layout];
}

- (void)layout {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.left.frame = CGRectMake(0, 0, width/4, height);
    self.middle.frame = CGRectMake(width/4, 0, width/2, height);
    self.right.frame = CGRectMake( width/4*3,0, width/4, height);
}

@end
