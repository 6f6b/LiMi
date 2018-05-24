//
//  ALiyunPaintEditCollectionViewCell.m
//  qusdk
//
//  Created by TripleL on 17/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPaintEditCollectionViewCell.h"

@interface AliyunPaintEditCollectionViewCell ()

@property (nonatomic, strong) UIView *colorView;

@end

@implementation AliyunPaintEditCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    [self setupSubViews];
    return self;
}

- (void)setupSubViews {
    // subview
    self.colorView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 24, 24))];
    self.colorView.center = self.contentView.center;
    self.colorView.layer.masksToBounds = YES;
    self.colorView.layer.borderWidth = 0;
    self.colorView.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
    self.colorView.layer.cornerRadius = 12;
    [self.contentView addSubview:self.colorView];
}

- (void)setViewColor:(UIColor *)viewColor {
    _viewColor = viewColor;
    self.colorView.backgroundColor = viewColor;
}

- (void)setSelected:(BOOL)selected {
    
    if (selected) {
        self.colorView.layer.borderWidth = 2;
    } else {
        self.colorView.layer.borderWidth = 0;
    }
}


@end
