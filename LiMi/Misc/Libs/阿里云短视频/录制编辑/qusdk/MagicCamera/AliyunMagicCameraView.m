//
//  MagicCameraView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraView.h"


@interface AliyunMagicCameraView ()

//@property (nonatomic, strong) UIView *topView;
//@property (nonatomic, strong) UIButton *backButton;

//@property (nonatomic, strong) UIButton *cameraIdButton;
//@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *centerView;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *pasterCollectionView;
@property (nonatomic, strong) UIButton *captureButton;

@property (nonatomic, strong) UILabel *timeLabel;


@end

@implementation AliyunMagicCameraView
{
    CGSize _videoSize;
    CFTimeInterval _beginTime;
}

- (instancetype)initWithFrame:(CGRect)frame videoSize:(CGSize)size
{
    if (self = [super initWithFrame:frame]) {
        _videoSize = size;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    
    CGFloat whRatio = _videoSize.width / _videoSize.height;
    CGFloat w, h;
    if (whRatio <= 1) {
        h = CGRectGetHeight(self.bounds);
        w = h * whRatio;
    } else {
        w = CGRectGetWidth(self.bounds);
        h = w / whRatio;
    }

    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ceilf(w), ceilf(h))];
    self.centerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self insertSubview:self.centerView atIndex:0];
    
    self.previewView = [[UIView alloc] initWithFrame:self.centerView.bounds];
    [self.centerView addSubview:self.previewView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 60 , CGRectGetWidth(self.bounds), 60)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bottomView];

    
    self.srollView = [[AliyunMagicCameraScrollView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 75 - SafeBottom, ScreenWidth, 60) delegate:self];
    [self addSubview:self.srollView];
    self.srollView.delegate = (id)self;
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.frame = CGRectMake(0, 0, 60, 16);
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.center = CGPointMake(ScreenWidth / 2, ScreenHeight - 98);
    [self addSubview:self.timeLabel];
    
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.textAlignment = 1;
    self.filterLabel.center = self.center;
    self.filterLabel.bounds = CGRectMake(0, 0, 100, 22);
    self.filterLabel.backgroundColor = [UIColor clearColor];
    self.filterLabel.textColor = [UIColor whiteColor];
    self.filterLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.filterLabel];
    

}

- (void)loadEffectData:(NSArray *)effectData
{
    self.srollView.effectItems = effectData;
}

- (void)recordingPercent:(CGFloat)percent
{
    self.timeLabel.text = [NSString stringWithFormat:@"%.2lf s",_maxDuration * percent];
}

- (void)recording:(CADisplayLink *)displayLink
{
    if (_beginTime == 0) {
        _beginTime = displayLink.timestamp;
    }
    CFTimeInterval duration = displayLink.timestamp - _beginTime;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%.2lf s",duration];

    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingProgressDuration:)]) {
        [self.delegate recordingProgressDuration:duration];
    }
}

- (void)destroy
{
    _beginTime = 0;
    self.timeLabel.text = @"";
//    [self recordingPercent:0.0];
    [self.srollView resetCircleView];
    [self.srollView hiddenScroll:NO];
}

- (void)displayFilterName:(NSString *)filterName {
    if (!filterName) filterName = @"原色(美颜)";
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animation];
    keyframeAnimation.duration = 1.f;
    keyframeAnimation.keyTimes = @[@0.0, @0.3, @0.7, @1.0];
    keyframeAnimation.values   = @[@0.0, @1.0, @1.0, @0.0];
    keyframeAnimation.fillMode = kCAFillModeForwards;
    keyframeAnimation.repeatCount = 1;
    keyframeAnimation.removedOnCompletion = NO;
    [self.filterLabel.layer addAnimation:keyframeAnimation forKey:@"opacity"];
    
    self.filterLabel.text = filterName;
}

#pragma mark - MagicCameraScrollViewDelegate -

- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectItemFocusToIndex:cell:)]) {
        [self.delegate effectItemFocusToIndex:index cell: cell];
    }
}

#pragma mark - Getter -




#pragma mark - Actions -






- (void)mvButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mvButtonClicked)]) {
        [self.delegate mvButtonClicked];
    }
}



@end
