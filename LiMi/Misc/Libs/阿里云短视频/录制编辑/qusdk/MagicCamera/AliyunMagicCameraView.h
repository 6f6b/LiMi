//
//  MagicCameraView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
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
@end

@interface AliyunMagicCameraView : UIView

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, weak) id<MagicCameraViewDelegate> delegate;
@property (nonatomic, strong) UILabel *filterLabel;
//@property (nonatomic, strong) UIButton *flashButton;
//@property (nonatomic, strong) QUProgressView *progressView;
@property (nonatomic, assign) CGFloat maxDuration;
//@property (nonatomic, strong) UIButton *finishButton;
//@property (nonatomic, strong) UIButton *musicButton;
//@property (nonatomic, strong) UIButton *mvButton;
@property (nonatomic, strong) AliyunMagicCameraScrollView *srollView;
//@property (nonatomic, strong) AliyunRateSelectView *rateView;

@property (nonatomic, assign) BOOL hide;

- (instancetype)initWithFrame:(CGRect)frame videoSize:(CGSize)size;

- (void)loadEffectData:(NSArray *)effectData;

- (void)recordingPercent:(CGFloat)percent;

- (void)destroy;

- (void)displayFilterName:(NSString *)filterName;

@end
