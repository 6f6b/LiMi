//
//  AliyunMediaConfig.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMediaConfig.h"

@implementation AliyunMediaConfig

+ (instancetype)cutConfigWithOutputPath:(NSString *)outputPath
                             outputSize:(CGSize)outputSize
                            minDuration:(CGFloat)minDuration
                            maxDuration:(CGFloat)maxDuration
                                cutMode:(AliyunMediaCutMode)cutMode
                           videoQuality:(AliyunMediaQuality)videoQuality
                                    fps:(int)fps
                                    gop:(int)gop {
    AliyunMediaConfig *config = [[AliyunMediaConfig alloc] init];
    config.outputPath = outputPath;
    config.outputSize = outputSize;
    config.minDuration = minDuration;
    config.maxDuration = maxDuration;
    config.cutMode = cutMode;
    config.videoQuality = videoQuality;
    config.fps = fps;
    config.gop = gop;
    return config;
}

+ (instancetype)recordConfigWithOutpusPath:(NSString *)outputPath
                                outputSize:(CGSize)outputSize
                               minDuration:(CGFloat)minDuration
                               maxDuration:(CGFloat)maxDuration
                              videoQuality:(AliyunMediaQuality)videoQuality
                                    encode:(AliyunEncodeMode)encodeMode
                                       fps:(int)fps
                                       gop:(int)gop {
    AliyunMediaConfig *config = [[AliyunMediaConfig alloc] init];
    config.outputPath = outputPath;
    config.outputSize = outputSize;
    config.minDuration = minDuration;
    config.maxDuration = maxDuration;
    config.videoQuality = videoQuality;
    config.fps = fps;
    config.gop = gop;
    config.encodeMode = encodeMode;
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fps = 25;
        _gop = 5;
        _videoQuality = 1;
        _backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (CGSize)updateVideoSizeWithRatio:(CGFloat)r {
    
    CGFloat w = _outputSize.width;
    CGFloat h = ceilf(w / r);
    _outputSize = CGSizeMake(w, h);
    [self evenOutputSize];
    return _outputSize;
}

- (CGSize)fixedSize {
    [self evenOutputSize];
    if (_videoRotate == 90 || _videoRotate == 270) {
        return CGSizeMake(_outputSize.height, _outputSize.width);
    }
    return _outputSize;
}
//容错，导出须为偶数
- (void)evenOutputSize {
    int w = (int)_outputSize.width;
    int h = (int)_outputSize.height;
    int fixedW = w / 2 * 2;
    int fixedH = h / 2 * 2;
    _outputSize = CGSizeMake((int)fixedW, (int)fixedH);
}

- (AliyunMediaRatio)mediaRatio {
    float aspects[5] = {9/16.0, 3/4.0, 1.0, 4/3.0,16/9.0};
    CGSize fixedSize = [self fixedSize];
    float videoAspect = fixedSize.width/fixedSize.height;
    int index = 0;
    for (int i = 0; i < 5; i++) {
        index = i;
        if (videoAspect <= aspects[i]) break;
    }
    if (index > 0) {
        if (fabsf(videoAspect - aspects[index]) > fabsf(videoAspect-aspects[index-1])) {
            index = index-1;
        }
    }
    return index;
}

@end
