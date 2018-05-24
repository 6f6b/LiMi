//
//  AliyunColorItemCell.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunColorItemCell.h"

@interface AliyunColorItemCell ()

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (weak, nonatomic) IBOutlet UIImageView *colorCheckImageView;

@end

@implementation AliyunColorItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.colorCheckImageView.hidden = YES;
}

- (void)setColor:(AliyunColor *)color
{
    _color = color;
    
    if (color.isStroke == NO) {
        [self.borderLayer removeFromSuperlayer];
        UIColor *bgColor = [UIColor colorWithRed:self.color.tR /255 green:self.color.tG / 255 blue:self.color.tB / 255 alpha:1];
        self.colorView.backgroundColor = bgColor;
    } else {
        [self.borderLayer removeFromSuperlayer];
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.borderLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.borderLayer.lineWidth = 8;
        self.borderLayer.fillColor = [UIColor colorWithRed:35 / 255.0 green:42 / 255.0 blue:66 / 255.0 alpha:1].CGColor;
        self.borderLayer.strokeColor = [UIColor colorWithRed:_color.sR / 255 green:_color.sG / 255 blue:_color.sB / 255 alpha:1].CGColor;
        [self.colorView.layer addSublayer:self.borderLayer];
    }
    
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected == YES) {
        self.colorCheckImageView.hidden = NO;
    } else {
        self.colorCheckImageView.hidden = YES;
    }
}

@end
