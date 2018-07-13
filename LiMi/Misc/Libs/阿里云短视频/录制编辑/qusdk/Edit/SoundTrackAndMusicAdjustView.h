//
//  SoundTrackAndMusicAdjustView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/7/11.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SoundTrackAndMusicAdjustView;
@protocol SoundTrackAndMusicAdjustViewDelegate<NSObject>
- (void)soundTrackAndMusicAdjustView:(SoundTrackAndMusicAdjustView *)soundTrackAndMusicAdjustView changedSoundTrackValue:(float)value;
- (void)soundTrackAndMusicAdjustView:(SoundTrackAndMusicAdjustView *)soundTrackAndMusicAdjustView changedMusicValue:(float)value;
@end
@interface SoundTrackAndMusicAdjustView : UIView
@property (strong, nonatomic)  UIView *topView;
@property (strong, nonatomic)  UIView *bottomContainView;
@property (strong, nonatomic)  UISlider *soundTrackSlider;
@property (strong, nonatomic)  UISlider *musicSlider;

- (void)showWith:(int)soundTrackValue music:(int)musicValue;
@property (weak,nonatomic) id<SoundTrackAndMusicAdjustViewDelegate> delegate;

@end
