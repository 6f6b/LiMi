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
    
    CGColorRef color1 =  rgba(43, 43, 43, 1).CGColor;
    CGColorRef color2 = rgba(255, 255, 255, 0).CGColor;
    
    CAGradientLayer *gradientLayerLeft = [[CAGradientLayer alloc] init];
    [gradientLayerLeft setColors:@[(__bridge id)color1,(__bridge id)color2]];
    gradientLayerLeft.startPoint = CGPointMake(0, 0.5);
    gradientLayerLeft.endPoint = CGPointMake(1, 0.5);
    gradientLayerLeft.frame = CGRectMake(0, 0, 14, 50);

    CAGradientLayer *gradientLayerRight = [[CAGradientLayer alloc] init];
    [gradientLayerRight setColors:@[(__bridge id)color2,(__bridge id)color1]];
    gradientLayerRight.startPoint = CGPointMake(0, 0.5);
    gradientLayerRight.endPoint = CGPointMake(1, 0.5);
    gradientLayerRight.frame = CGRectMake(0, 0, 14, 50);
    
    self.left = [[UIView alloc] initWithFrame:CGRectZero];
    self.left.backgroundColor = rgba(43, 43, 43, 1);
//    [self.left.layer addSublayer:gradientLayerLeft];
    [self addSubview:self.left];
    self.middle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CropBox"]];
    [self addSubview:self.middle];
    self.right = [[UIView alloc] initWithFrame:CGRectZero];
//    [self.right.layer addSublayer:gradientLayerRight];
    [self addSubview:self.right];
    [self layout];
}

- (void)layout {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.left.frame = CGRectMake(0, 0, 14, height);
    self.middle.frame = CGRectMake(width/4, 0, width/2, height);
    self.right.frame = CGRectMake( width-14,0, 14, height);
}

@end
