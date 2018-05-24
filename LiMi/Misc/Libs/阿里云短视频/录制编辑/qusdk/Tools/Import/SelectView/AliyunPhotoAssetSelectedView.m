//
//  AliyunPhotoAssetSelectedView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPhotoAssetSelectedView.h"

@implementation AliyunPhotoAssetSelectedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UILabel *label = [self configureLabel];
    _durationLabel = [self configureLabel];
    label.text = @"总时长";
    _durationLabel.text = @"5:30";
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[label(==36)]-2-[_durationLabel]"
                                                                  options:0 metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(label,_durationLabel)];
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label(==12)]"
                                                                  options:0 metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(label)];
    NSArray *constraintsV2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_durationLabel(==12)]"
                                                                    options:0 metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(_durationLabel)];
    [self addConstraints:constraintsH];
    [self addConstraints:constraintsV];
    [self addConstraints:constraintsV2];
    
    UIButton *buttonNext = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonNext.translatesAutoresizingMaskIntoConstraints = NO;
    [buttonNext setTitle:@"下一步" forState:0];
    [buttonNext setTitleColor:[UIColor whiteColor] forState:0];
    [buttonNext setBackgroundColor:RGBToColor(239, 75, 129)];
    buttonNext.titleLabel.font = [UIFont systemFontOfSize:12];
    buttonNext.layer.cornerRadius = 2;
    [self addSubview:buttonNext];
    
    NSArray *buttonConstraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[buttonNext(==56)]-10-|"
                                                                         options:0 metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(buttonNext)];
    NSArray *buttonConstraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[buttonNext(==22)]"
                                                                         options:0 metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(buttonNext)];
    [self addConstraints:buttonConstraintsH];
    [self addConstraints:buttonConstraintsV];
}

- (UILabel *)configureLabel {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor =  RGBToColor(110, 118, 139);
    label.textAlignment = 1;
    label.font = [UIFont systemFontOfSize:12];
    [self addSubview:label];
    return label;
}

@end
