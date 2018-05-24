//
//  AliyunVideoCropParam.m
//  AliyunVideo
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunVideoCropParam.h"

@implementation AliyunVideoCropParam

- (instancetype)init
{
    self = [super init];
    if (self) {
        _outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/aliyun_video_cut.mp4"];
        _size = AliyunVideoVideoSize540P;
        _ratio = AliyunVideoVideoRatio3To4;
        _minDuration = 2.0;
        _maxDuration = 10.0*60;
        _cutMode = AliyunVideoCutModeScaleAspectFill;
        _videoQuality = AliyunVideoQualityHight;
        _encodeMode = AliyunVideoEncodeModeHardH264;
        _fps = 25;
        _gop = 5;
        _fillBackgroundColor = [UIColor blackColor];
    }
    return self;
}

+ (instancetype)recordConfigWithVideoRatio:(AliyunVideoRatio)ratio
                                 videoSize:(AliyunVideoSize)size; {
    
    AliyunVideoCropParam *config = [[AliyunVideoCropParam alloc] init];
    config.ratio = ratio;
    config.size = size;
    return config;
}

+ (instancetype)recordConfigWithVideoRatio:(AliyunVideoRatio)ratio
                                 videoSize:(AliyunVideoSize)size
                                outputPath:(NSString *)outputPath
                               minDuration:(CGFloat)minDuration
                               maxDuration:(CGFloat)maxDuration
                                   cutMode:(AliyunVideoCutMode)cutMode
                              videoQuality:(AliyunVideoQuality)videoQuality
                                encodeMode:(AliyunVideoEncodeMode)encodeMode
                                       fps:(int)fps
                                       gop:(int)gop {
    
    AliyunVideoCropParam *config = [[AliyunVideoCropParam alloc] init];
    config.ratio = ratio;
    config.size = size;
    config.outputPath = outputPath;
    config.minDuration = minDuration;
    config.maxDuration = maxDuration;
    config.videoQuality = videoQuality;
    config.encodeMode = encodeMode;
    config.cutMode = cutMode;
    config.fps = fps;
    config.gop = gop;
    return config;
}

@end
