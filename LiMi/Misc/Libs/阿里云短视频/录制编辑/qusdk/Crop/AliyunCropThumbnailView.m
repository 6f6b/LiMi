//
//  AliyunCropThumbnailView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/14.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCropThumbnailView.h"
#import <AVFoundation/AVFoundation.h>
#import "AliyunMediaConfig.h"

@interface AliyunCropThumbnailView ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) AliyunMediaConfig *cutInfo;
@property (nonatomic, strong) UIImageView *imageViewLeft;
@property (nonatomic, strong) UIImageView *imageViewLeftMask;
@property (nonatomic, strong) UIImageView *imageViewRight;
@property (nonatomic, strong) UIImageView *imageViewRightMask;
@property (nonatomic, strong) UIImageView *imageViewBackground;
@property (nonatomic, strong) UIImageView *imageViewSelected;
@property (nonatomic, strong) UIImageView *progressView;

@property (nonatomic, strong) UIImageView *topLineView;
@property (nonatomic, strong) UIImageView *underLineView;

@property (nonatomic, assign) int imageViewWith;
@end

@implementation AliyunCropThumbnailView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withCutInfo:(AliyunMediaConfig *)cutInfo{
    self = [super initWithFrame:frame];
    if (self) {
        _cutInfo = cutInfo;
        _imagesArray = [NSMutableArray arrayWithCapacity:8];
        [self setupCollectionView];
        [self setupSubviews];
    }
    return self;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(ScreenWidth / 8.0 , ScreenWidth / 8.0);
    followLayout.minimumLineSpacing = 0;
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 12, self.frame.size.width, ScreenWidth / 8.0) collectionViewLayout:followLayout];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:_collectionView];
}

- (void)setupSubviews {
    CGFloat selfWidth = self.frame.size.width;

    _progressView = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"progress"]];
    _progressView.bounds = CGRectMake(0, 0, ScreenWidth / 8.0, ScreenWidth / 8.0);
    _progressView.center = CGPointMake(0, CGRectGetMidY(self.bounds) + 6);
    [self addSubview:_progressView];
    
    _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/8*0.35, 0, 200, 12)];
    _durationLabel.textColor = RGBToColor(255, 255, 255);
    _durationLabel.textAlignment = NSTextAlignmentLeft;
    _durationLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_durationLabel];
    
    _imageViewWith = ScreenWidth / 8.0 * 0.35;
    _imageViewLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left"]];
    _imageViewLeft.frame = CGRectMake(0, 12, _imageViewWith, ScreenWidth / 8.0);
    _imageViewLeft.userInteractionEnabled = YES;
    _imageViewRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    _imageViewRight.frame = CGRectMake(selfWidth - _imageViewWith, 12, _imageViewWith, ScreenWidth / 8.0);
    _imageViewRight.userInteractionEnabled = YES;
    
    _topLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_imageViewWith - 3 , 12, selfWidth - _imageViewWith *2 + 6, 1)];
    _topLineView.backgroundColor =rgba(127, 110, 241, 1);
    
    _underLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_imageViewWith - 3, _imageViewLeft.frame.size.height + 12 -1  , selfWidth - _imageViewWith *2 + 6, 1)];
    _underLineView.backgroundColor = rgba(127, 110, 241, 1);
    
    [self addSubview:_topLineView];
    [self addSubview:_underLineView];
    
    [self addSubview:_imageViewLeft];
    [self addSubview:_imageViewRight];
    

    _imageViewLeftMask = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 0, _imageViewLeft.frame.size.height)];
    _imageViewRightMask = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageViewRight.frame), 12, 0, _imageViewLeft.frame.size.height)];
    
    _imageViewLeftMask.backgroundColor = rgba(0, 0, 0, 1);
    _imageViewLeftMask.alpha = 0.8;
    _imageViewRightMask.backgroundColor = rgba(0, 0, 0, 1);
    _imageViewRightMask.alpha = 0.8;
    
    [self addSubview:_imageViewLeftMask];
    [self addSubview:_imageViewRightMask];

//    _imageViewBackground = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"paster_time_edit_slider_bg"]];
//    _imageViewBackground.frame = CGRectMake(CGRectGetMaxX(_imageViewLeft.frame), CGRectGetMinY(_imageViewLeft.frame), CGRectGetMinX(_imageViewRight.frame) - CGRectGetMaxX(_imageViewLeft.frame), ScreenWidth / 8.0);
//    [self addSubview:_imageViewBackground];
    
}

- (void)loadThumbnailData {
    
    _durationLabel.text = [NSString stringWithFormat:@"%.2f",_cutInfo.endTime - _cutInfo.startTime];
    CMTime startTime = kCMTimeZero;
    NSMutableArray *array = [NSMutableArray array];
    CMTime addTime = CMTimeMake(1000,1000);
    CGFloat d = _cutInfo.sourceDuration / 7.0;
    int intd = d * 100;
    float fd = intd / 100.0;
    addTime = CMTimeMakeWithSeconds(fd, 1000);
    
    CMTime endTime = CMTimeMakeWithSeconds(_cutInfo.sourceDuration, 1000);
    
    while (CMTIME_COMPARE_INLINE(startTime, <=, endTime)) {
        [array addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    
    // 第一帧取第0.1s   规避有些视频并不是从第0s开始的
    array[0] = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(0.1, 1000)];
    
    __block int index = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_imagesArray addObject:img];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [_collectionView insertItemsAtIndexPaths:@[indexPath]];
                index++;
            });
        }
    }];
}

- (void)updateProgressViewWithProgress:(CGFloat)progress {
    CGPoint center = _progressView.center;
    
    CGFloat newX = progress *ScreenWidth;
    if (newX < center.x ) {
        center.x = newX;

        _progressView.center = center;
    }else{
        center.x = newX;

        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _progressView.center = center;
        } completion:nil];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imagesArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImage *image = _imagesArray[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = cell.contentView.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    return cell;
}

- (AVAssetImageGenerator *)imageGenerator {
    if (!_imageGenerator) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_avAsset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = CGSizeMake(320, 320);
    }
    return _imageGenerator;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect adjustLeftRespondRect = _imageViewLeft.frame;
    CGRect adjustRightRespondRect = _imageViewRight.frame;
    if (CGRectContainsPoint(adjustLeftRespondRect, point)) {
        _imageViewSelected = _imageViewLeft;
    } else if (CGRectContainsPoint(adjustRightRespondRect, point)) {
        _imageViewSelected = _imageViewRight;
    } else {
        _imageViewSelected = nil;
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_imageViewSelected) return;
    _progressView.hidden = YES;
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint lp = [touch locationInView:self];
    CGPoint pp = [touch previousLocationInView:self];
    CGFloat offset = lp.x - pp.x;
    CGFloat time = offset/(ScreenWidth - 2 * _imageViewWith) * _cutInfo.sourceDuration;
    if (_imageViewSelected == _imageViewLeft) {
        CGFloat left = _cutInfo.startTime + time;
        if (0 < left && left < _cutInfo.endTime - _cutInfo.minDuration) {
            CGRect frame = _imageViewLeft.frame;
            frame.origin.x += offset;
            _imageViewLeft.frame = frame;
            
            CGRect maskFrame = _imageViewLeftMask.frame;
            maskFrame.size.width = frame.origin.x;
            _imageViewLeftMask.frame = maskFrame;
            
            _cutInfo.startTime = left;
            _imageViewBackground.frame = CGRectMake(CGRectGetMaxX(_imageViewLeft.frame), CGRectGetMinY(_imageViewLeft.frame), CGRectGetMinX(_imageViewRight.frame) - CGRectGetMaxX(_imageViewLeft.frame), ScreenWidth / 8.0);
            _durationLabel.text = [NSString stringWithFormat:@"%.2f",_cutInfo.endTime - _cutInfo.startTime];
            if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
                [_delegate cutBarDidMovedToTime:left];
            }
        }
    } else if (_imageViewSelected == _imageViewRight) {
        CGFloat right = _cutInfo.endTime + time;
        if (_cutInfo.startTime + _cutInfo.minDuration < right && right < _cutInfo.sourceDuration) {
            _cutInfo.endTime = right;
            CGRect frame = _imageViewRight.frame;
            frame.origin.x += offset;
            _imageViewRight.frame = frame;
            
            CGRect maskFrame = _imageViewRightMask.frame;
            maskFrame.origin.x = frame.origin.x + frame.size.width;
            maskFrame.size.width = ScreenWidth - maskFrame.origin.x;
            _imageViewRightMask.frame = maskFrame;
            _imageViewBackground.frame = CGRectMake(CGRectGetMaxX(_imageViewLeft.frame), CGRectGetMinY(_imageViewLeft.frame), CGRectGetMinX(_imageViewRight.frame) - CGRectGetMaxX(_imageViewLeft.frame), ScreenWidth / 8.0);
            _durationLabel.text = [NSString stringWithFormat:@"%.2f", _cutInfo.endTime - _cutInfo.startTime];
            if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
                [_delegate cutBarDidMovedToTime:right];
            }
        }
    }
    
    CGRect upFrame = _topLineView.frame;
    CGRect downFrame = _underLineView.frame;
    
    upFrame.origin.x = CGRectGetMaxX(_imageViewLeft.frame) - 3;
    downFrame.origin.x = upFrame.origin.x;
    
    upFrame.size.width = CGRectGetMinX(_imageViewRight.frame) - CGRectGetMaxX(_imageViewLeft.frame) + 6;
    downFrame.size.width = upFrame.size.width;
    
    _topLineView.frame = upFrame;
    _underLineView.frame = downFrame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageViewSelected = nil;
    _progressView.hidden = NO;
    if ([_delegate respondsToSelector:@selector(cutBarTouchesDidEnd)]) {
        [_delegate cutBarTouchesDidEnd];
    }
}

@end
