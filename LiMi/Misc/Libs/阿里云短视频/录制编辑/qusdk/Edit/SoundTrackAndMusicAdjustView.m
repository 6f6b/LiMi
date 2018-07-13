//
//  SoundTrackAndMusicAdjustView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/7/11.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "SoundTrackAndMusicAdjustView.h"
#import "LiMi-Swift.h"


@interface SoundTrackAndMusicAdjustView ()
@property (nonatomic,strong) UILabel *soundTrackLabel;
@property (nonatomic,strong) UILabel *musicLabel;
@end
@implementation SoundTrackAndMusicAdjustView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = UIColor.clearColor;
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-160)];
        _topView.backgroundColor = UIColor.clearColor;
        [self addSubview:_topView];
        
        _bottomContainView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-160, ScreenWidth, 160)];
        _bottomContainView.backgroundColor = rgba(0, 0, 0, 0.9);
        [self addSubview:_bottomContainView];
        
        _soundTrackLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 35, 15)];
        _soundTrackLabel.textColor = UIColor.whiteColor;
        _soundTrackLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _soundTrackLabel.text = @"原声";
        [_bottomContainView addSubview:_soundTrackLabel];
        
        _musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 108, 35, 15)];
        _musicLabel.textColor = UIColor.whiteColor;
        _musicLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _musicLabel.text = @"配乐";
        [_bottomContainView addSubview:_musicLabel];
        
        _soundTrackSlider = [[UISlider alloc] initWithFrame:CGRectMake(70, 0, ScreenWidth-70-26, 10)];
        _soundTrackSlider.tintColor = rgba(114, 0, 218, 1);
        CGPoint center =  _soundTrackSlider.center;
        center.y = _soundTrackLabel.center.y;
        _soundTrackSlider.center = center;
        _soundTrackSlider.maximumValue = 200;
        _soundTrackSlider.minimumValue = 0;
        [_bottomContainView addSubview:_soundTrackSlider];

        _musicSlider = [[UISlider alloc] initWithFrame:CGRectMake(70, 0, ScreenWidth-70-26, 10)];
        _musicSlider.tintColor = rgba(114, 0, 218, 1);
        CGPoint center1 =  _musicSlider.center;
        center1.y = _musicLabel.center.y;
        _musicSlider.center = center1;
        _musicSlider.maximumValue = 100;
        _musicSlider.minimumValue = 0;
        [_bottomContainView addSubview:_musicSlider];
        
        
        [self.soundTrackSlider addTarget:self action:@selector(soundTrackValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.musicSlider addTarget:self action:@selector(musicValueChanged:) forControlEvents:UIControlEventValueChanged];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedTopView)];
        [self.topView addGestureRecognizer:tap];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)showWith:(int)soundTrackValue music:(int)musicValue{
    self.musicSlider.value = (float)musicValue;
    self.soundTrackSlider.value = (float)soundTrackValue;
    [UIApplication.sharedApplication.keyWindow addSubview:self];
}

- (void)soundTrackValueChanged:(UISlider *)slider{
    [self.delegate soundTrackAndMusicAdjustView:self changedSoundTrackValue:slider.value];
}
- (void)musicValueChanged:(UISlider *)slider{
    [self.delegate soundTrackAndMusicAdjustView:self changedMusicValue:slider.value];
}
- (void)tapedTopView{
    [self removeFromSuperview];
}
@end
