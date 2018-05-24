//
//  MagicCameraView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/22.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMagicCameraScrollView.h"
#import "AliyunRateSelectView.h"
#import "QUProgressView.h"

@protocol MagicCameraViewDelegate <NSObject>
    
- (void)backButtonClicked;
- (NSString *)flashButtonClicked;
- (void)cameraIdButtonClicked;
- (void)recordButtonTouchesBegin;
- (void)recordButtonTouchesEnd;
- (void)effectItemFocusToIndex:(NSInteger)index cell:(UICollectionViewCell *)cell;
- (void)musicButtonClicked;
- (void)mvButtonClicked;
- (void)deleteButtonClicked;
- (void)finishButtonClicked;
- (void)recordingProgressDuration:(CFTimeInterval)duration;
- (void)didSelectRate:(CGFloat)rate;
    
- (void)addEffectWithPath:(NSString *)path;
- (void)deleteCurrentEffectPaster;
@end

@interface MagicCameraView : UIView
    @property (nonatomic, weak) id<MagicCameraViewDelegate> delegate;

    @property (nonatomic, assign) CGFloat maxDuration;

    @property (nonatomic, strong) AliyunMagicCameraScrollView *srollView;
    
    @property (nonatomic, assign) BOOL hide;
    
- (instancetype)initWithFrame:(CGRect)frame;
    
- (void)loadEffectData:(NSArray *)effectData;
    
- (void)destroy;
    
    - (void)show;
@end
