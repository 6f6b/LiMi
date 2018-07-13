//
//  AliyunEditButtonsView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditButtonsView.h"
#import "LiMi-Swift.h"

@implementation AliyunEditButtonsView
{
    NSArray *_btnImageNames;
    NSArray *_btnSelNames;
    NSArray *_btnTitles;
    UIButton *_animationButton;
    UIButton *_meiyanButton;
    UIButton *_musicButton;
    UIButton *_volumeButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //滤镜 动图 字幕 MV 音乐 涂鸦
        _btnImageNames = @[@"btn_texiao",
                           @"meiyan",
//                           @"QPSDK.bundle/edit_subtitle.png",
//                           @"QPSDK.bundle/edit_mv.png",
                           @"music.png",
//                           @"QPSDK.bundle/edit_paint.png"
                           @"btn_yinliang"
                           ];
        _btnSelNames = @[@"filterButtonClicked:",
                         @"pasterButtonClicked:",
//                         @"subtitleButtonClicked:",
//                         @"mvButtonClicked:",
                         @"musicButtonClicked:",
//                         @"paintButtonClicked:"
                         @"volumeButtonClicked:"
                         ];
        _btnTitles = @[@"特效",@"滤镜",@"音乐",@"音量"];
        [self addButtons];
        self.backgroundColor = UIColor.clearColor;
        //self.backgroundColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:1];
    }
    return self;
}

- (void)addButtons {

    _animationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _animationButton.frame = CGRectMake(20, 0, 24, 24);
    [_animationButton addTarget:self action:NSSelectorFromString(_btnSelNames[0]) forControlEvents:UIControlEventTouchUpInside];
    [_animationButton setTitle:_btnTitles[0] forState:UIControlStateNormal];
    [_animationButton setImage:[UIImage imageNamed:_btnImageNames[0]] forState:UIControlStateNormal];
    _animationButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_animationButton sizeToFitTitleBelowImageWithDistance:8];
    [self addSubview:_animationButton];
    
    _meiyanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _meiyanButton.frame = CGRectMake(CGRectGetMaxX(_animationButton.frame)+42, 0, 24, 24);
    [_meiyanButton addTarget:self action:NSSelectorFromString(_btnSelNames[1]) forControlEvents:UIControlEventTouchUpInside];
    [_meiyanButton setTitle:_btnTitles[1] forState:UIControlStateNormal];
    [_meiyanButton setImage:[UIImage imageNamed:_btnImageNames[1]] forState:UIControlStateNormal];
    _meiyanButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_meiyanButton sizeToFitTitleBelowImageWithDistance:8];
    [self addSubview:_meiyanButton];
    
    _musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _musicButton.frame = CGRectMake(CGRectGetMaxX(_meiyanButton.frame)+46, 0, 24, 24);
    [_musicButton addTarget:self action:NSSelectorFromString(_btnSelNames[2]) forControlEvents:UIControlEventTouchUpInside];
    [_musicButton setTitle:_btnTitles[2] forState:UIControlStateNormal];
    [_musicButton setImage:[UIImage imageNamed:_btnImageNames[2]] forState:UIControlStateNormal];
    _musicButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_musicButton sizeToFitTitleBelowImageWithDistance:8];
    [self addSubview:_musicButton];
    
    _volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _volumeButton.frame = CGRectMake(CGRectGetMaxX(_musicButton.frame)+46, 0, 24, 24);
    [_volumeButton addTarget:self action:NSSelectorFromString(_btnSelNames[3]) forControlEvents:UIControlEventTouchUpInside];
    [_volumeButton setTitle:_btnTitles[3] forState:UIControlStateNormal];
    [_volumeButton setImage:[UIImage imageNamed:_btnImageNames[3]] forState:UIControlStateNormal];
    _volumeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_volumeButton sizeToFitTitleBelowImageWithDistance:8];
    [self addSubview:_volumeButton];
    
//    CGFloat dlt = CGRectGetWidth(self.bounds) / ([_btnSelNames count] + 1);
//    CGFloat cy = self.bounds.size.height / 2;
//
//    for (int idx = 0; idx < [_btnImageNames count]; idx++) {
//        NSString *imageName = [_btnImageNames objectAtIndex:idx];
//        NSString *selName = [_btnSelNames objectAtIndex:idx];
//        SEL sel = NSSelectorFromString(selName);
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(0, 0, 24, 24);
//        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
//        [btn setTitle:_btnTitles[idx] forState:UIControlStateNormal];
//        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//        [btn sizeToFitTitleBelowImageWithDistance:8];
//        [self addSubview:btn];
//        btn.center = CGPointMake((idx+1) * dlt, cy);
//    }
    
}

- (void)filterButtonClicked:(id)sender {
    [self.delegate animationFilterButtonClicked];
    //[self.delegate filterButtonClicked:AliyunEditButtonTypeFilter];
}

- (void)pasterButtonClicked:(id)sender {
    [self.delegate pasterButtonClicked];
    [self.delegate filterButtonClicked];
}

- (void)subtitleButtonClicked:(id)sender {
    [self.delegate subtitleButtonClicked];
}

- (void)mvButtonClicked:(id)sender {
    [self.delegate mvButtonClicked:AliyunEditButtonTypeMV];
}

- (void)musicButtonClicked:(id)sender {
    [self.delegate musicButtonClicked];
}

- (void)volumeButtonClicked:(id)sender{
    [self.delegate volumeButtonClicked];
}

- (void)paintButtonClicked:(id)sender {
 
    [self.delegate paintButtonClicked];
}

@end
