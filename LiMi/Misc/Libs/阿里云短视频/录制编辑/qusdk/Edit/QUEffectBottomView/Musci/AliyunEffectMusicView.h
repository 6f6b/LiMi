//
//  AliyunEffectMusicView.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectMusicControlView.h"

@class AliyunEffectMusicInfo;

@protocol AliyunEffectMusicViewDelegate <NSObject>

- (void)musicViewDidUpdateMute:(BOOL)mute;
- (void)musicViewDidUpdateAudioMixWeight:(float)weight;
- (void)musicViewDidUpdateMusic:(NSString *)path;

@end

@interface AliyunEffectMusicView : UIView
@property (nonatomic, weak) id<AliyunEffectMusicViewDelegate> delegate;
@property (nonatomic, strong) AliyunEffectMusicControlView *controlView;
- (void)refreshWithMute:(BOOL)mute mixWeight:(float)weight muiscPath:(NSString *)path;

@end
