//
//  AliyunCoverPickView.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCoverPickView.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+VideoInfo.h"

@interface AliyunCoverPickView ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *progressView;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) AVAssetImageGenerator *pickGenerator;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BOOL imageCaptured;
@end

@implementation AliyunCoverPickView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imagesArray = [NSMutableArray arrayWithCapacity:8];
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews {
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(CGRectGetHeight(self.frame) , CGRectGetHeight(self.frame));
    followLayout.minimumLineSpacing = 0;
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:followLayout];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:_collectionView];
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    _progressView = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"icon_cover_slide"]];
    _progressView.frame = CGRectMake(0, 0, 4, CGRectGetHeight(self.frame));
    [view addSubview:_progressView];
}

- (void)parseAsset {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_videoPath]];
    _duration = [asset avAssetVideoTrackDuration];
}

- (void)loadThumbnailData {
    [self parseAsset];
    
    _selectedImage = [self coverImageAtTime:CMTimeMake(0.1 * 1000, 1000)];
    [_delegate pickViewDidUpdateImage:_selectedImage];
    
    CMTime startTime = kCMTimeZero;
    NSMutableArray *array = [NSMutableArray array];
    CMTime addTime = CMTimeMake(_duration*1000/8.0f,1000);
    
    CMTime endTime = CMTimeMake(_duration*1000, 1000);
    while (CMTIME_COMPARE_INLINE(startTime, <, endTime)) {
        [array addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    // 第一帧取第0.1s   规避有些视频并不是从第0s开始的
    array[0] = [NSValue valueWithCMTime:CMTimeMake(0.1 * 1000, 1000)];
    
    __block int index = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imagesArray addObject:img];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [_collectionView insertItemsAtIndexPaths:@[indexPath]];
                index++;
            });
        }
    }];

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
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_videoPath]];
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = CGSizeMake(100, 100);
    }
    return _imageGenerator;
}

-(AVAssetImageGenerator *)pickGenerator {
    if (!_imageGenerator) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_videoPath]];
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = _outputSize;
    }
    return _imageGenerator;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self.collectionView];
    CGFloat percent = point.x / CGRectGetWidth(self.frame);
    if (percent < 0) {
        percent = 0;
    }else if (percent > 1) {
        percent = 1;
    }
    CMTime time = CMTimeMake(percent *_duration * 1000, 1000);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _selectedImage = [self coverImageAtTime:time];
        [_delegate pickViewDidUpdateImage:_selectedImage];
        _imageCaptured = YES;
    });
    self.progressView.center = CGPointMake(CGRectGetWidth(self .frame)*percent, CGRectGetHeight(self.frame)/2);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self.collectionView];
    CGFloat percent = point.x / CGRectGetWidth(self.frame);
    if (percent < 0) {
        percent = 0;
    }else if (percent > 1) {
        percent = 1;
    }
    CMTime time = CMTimeMake(percent *_duration * 1000, 1000);
    if (_imageCaptured) {
        _imageCaptured = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _selectedImage = [self coverImageAtTime:time];
            [_delegate pickViewDidUpdateImage:_selectedImage];
            _imageCaptured = YES;
        });
    }
    self.progressView.center = CGPointMake(CGRectGetWidth(self.frame)*percent, CGRectGetHeight(self.frame)/2);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self.collectionView];
    CGFloat percent = point.x / CGRectGetWidth(self.frame);
    if (percent < 0) {
        percent = 0;
    }else if (percent > 1) {
        percent = 1;
    }
    CMTime time = CMTimeMake(percent *_duration * 1000, 1000);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _selectedImage = [self coverImageAtTime:time];
        [_delegate pickViewDidUpdateImage:_selectedImage];
    });
    self.progressView.center = CGPointMake(CGRectGetWidth(self.frame)*percent, CGRectGetHeight(self.frame)/2);
}

- (UIImage *)coverImageAtTime:(CMTime)time {
    CGImageRef image = [self.pickGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}
@end
