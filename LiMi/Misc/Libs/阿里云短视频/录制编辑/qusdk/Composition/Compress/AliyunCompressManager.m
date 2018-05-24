//
//  QUCompressManager.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompressManager.h"
#import <AliyunVideoSDKPro/AliyunCrop.h>
#import <AliyunVideoSDKPro/AliyunImageCrop.h>
#import "AVAsset+VideoInfo.h"

@interface AliyunCompressManager ()

@property (nonatomic, strong) AliyunMediaConfig *config;
@property (nonatomic, strong) AliyunCrop *cutPanel;
@property (nonatomic, copy) void(^successCallback)();
@property (nonatomic, copy) void(^failureCallback)();
@end

@implementation AliyunCompressManager

- (instancetype)initWithMediaConfig:(AliyunMediaConfig *)config {
    self = [super init];
    if (self) {
        _config = config;
    }
    return self;
}

- (void)compressWithSourcePath:(NSString *)sourcePath
                    outputPath:(NSString *)outputPath
                    outputSize:(CGSize)outputSize
                       success:(void (^)())success
                       failure:(void(^)())failure {
    _successCallback = success;
    _failureCallback = failure;
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:sourcePath]];
    _cutPanel = [[AliyunCrop alloc] initWithDelegate:(id<AliyunCropDelegate>)self];
    _cutPanel.inputPath = sourcePath;
    _cutPanel.outputSize = outputSize;
    _cutPanel.outputPath = outputPath;
    _cutPanel.startTime = 0;
    _cutPanel.endTime = [asset avAssetVideoTrackDuration];
    _cutPanel.rect = CGRectMake(0, 0, 1, 1);
    _cutPanel.fps = _config.fps;
    _cutPanel.gop = _config.gop;
    _cutPanel.videoQuality = (AliyunVideoQuality)_config.videoQuality;
    _cutPanel.encodeMode = _config.encodeMode;
    [_cutPanel startCrop];
}

- (UIImage *)compressImageWithSourceImage:(UIImage *)sourceImage
                               outputSize:(CGSize)outputSize {
    if (sourceImage == nil) {
        return nil;
    }
    AliyunImageCrop *imageCrop = [[AliyunImageCrop alloc] init];
    imageCrop.originImage = sourceImage;
    imageCrop.cropMode = AliyunImageCropModeAspectFill;
    imageCrop.outputSize = outputSize;
    UIImage *generatedImage = [imageCrop generateImage];
    return generatedImage;
}

- (void)stopCompress {
    
    if (_cutPanel) {
        [_cutPanel cancel];
    }
}

#pragma mark - tool

- (CGSize)calOutputSizeWithAsset:(AVAsset *)asset {
    CGSize size = [asset avAssetNaturalSize];
    CGFloat factor = MAX(size.width, size.height)/1280.f;
    return CGSizeMake((int)(size.width/factor), (int)(size.height/factor));
}


#pragma mark --- AliyunCropDelegate

- (void)cropTaskOnProgress:(float)progress {

}

- (void)cropOnError:(int)error {
    self.failureCallback();
}

- (void)cropTaskOnComplete {
    self.successCallback();
    
}

@end
