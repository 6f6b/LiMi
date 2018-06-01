//
//  AliyunMusicPickView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/28.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMusicLineView.h"


@protocol AliyunMusicPickViewDelegate <NSObject>

- (void)didSelectStartTime:(CGFloat)startTime;
- (void)useButtonClicked;
@end
@interface AliyunMusicPickView : UIView
@property (nonatomic, weak) id<AliyunMusicPickViewDelegate> delegate;
@property (nonatomic, strong) AliyunMusicLineView *lineView;
@property (nonatomic, strong) UIScrollView *scrollView;
-(void)configureMusicDuration:(float)musicDuration pageDuration:(float)pageDuration;
@end
