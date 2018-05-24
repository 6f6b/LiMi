//
//  AliyunEffectMusicControlView.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMusicControlView.h"

@interface AliyunEffectMusicControlView ()

@property (nonatomic, strong) UILabel *labelOrigin;
@property (nonatomic, strong) UILabel *labelMusic;
@end

@implementation AliyunEffectMusicControlView

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
    self.buttonMute = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.buttonMute addTarget:self action:@selector(muteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonMute setImage:[AliyunImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [self.buttonMute setImage:[AliyunImage imageNamed:@"voice_none"] forState:UIControlStateSelected];
    [self addSubview:self.buttonMute];
    
    self.labelOrigin = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelOrigin.text = NSLocalizedString(@"original_music_edit", nil);
    self.labelOrigin.font = [UIFont systemFontOfSize:12];
    self.labelOrigin.contentMode = UIViewContentModeCenter;
    self.labelOrigin.textColor = [UIColor whiteColor];
    [self addSubview:self.labelOrigin];
    
    self.sliderVolume = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.sliderVolume setThumbImage:[AliyunImage imageNamed:@"voice_slide"] forState:UIControlStateNormal];
    [self.sliderVolume setMaximumTrackTintColor:rgba(239,75,129,1)];
    [self.sliderVolume setMinimumTrackTintColor:[UIColor whiteColor]];
    [self.sliderVolume addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.sliderVolume];
    self.sliderVolume.value = 1;
    
    self.labelMusic = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelMusic.text = NSLocalizedString(@"music_edit", nil);
    self.labelMusic.font = [UIFont systemFontOfSize:12];
    self.labelMusic.contentMode = UIViewContentModeCenter;
    self.labelMusic.textColor = rgba(239,75,129,1);
    [self addSubview:self.labelMusic];
    
    
    
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

- (void)layout {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.buttonMute.frame = CGRectMake(4, 0, height, height);
    self.labelOrigin.frame = CGRectMake(height+4, 0, 28, height);
    self.sliderVolume.frame = CGRectMake(height+36, 0, width-height-36-32-8, height);
    self.labelMusic.frame = CGRectMake(width-32, 0, 28, height);
}


- (void)updateControlSliderWithWeight:(float)weight {
    
    self.sliderVolume.value = weight;
}

#pragma mark - action

- (void)sliderChanged:(UISlider *)sender {
    [_delegate controlViewDidUpadteVolume:sender.value];
}

- (void)muteClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_delegate controlViewDidUpdateMute:YES];
    }else {
        [_delegate controlViewDidUpdateMute:NO];
    }
}

@end
