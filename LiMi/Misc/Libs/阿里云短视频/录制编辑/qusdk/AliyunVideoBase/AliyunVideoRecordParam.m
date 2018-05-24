//
//  AliyunVideoRecordParam.m
//  AliyunVideoSDK
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunVideoRecordParam.h"

@implementation AliyunVideoRecordParam


- (instancetype)init
{
    self = [super init];
    if (self) {
        _position = AliyunCameraPositionFront;
        _torchMode = AliyunCameraTorchModeOff;
        _beautifyStatus = YES;
        _beautifyValue = 80;
        _outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/aliyun_video_record.mp4"];
        _size = AliyunVideoVideoSize540P;
        _ratio = AliyunVideoVideoRatio3To4;
        _minDuration = 2.0;
        _maxDuration = 30.0;
        _videoQuality = AliyunVideoQualityHight;
        _encodeMode = AliyunVideoEncodeModeHardH264;
        _fps = 25;
        _gop = 5;
    }
    return self;
}

+ (instancetype)recordConfigWithVideoRatio:(AliyunVideoRatio)ratio
                                 videoSize:(AliyunVideoSize)size; {
    
    AliyunVideoRecordParam *config = [[AliyunVideoRecordParam alloc] init];
    config.ratio = ratio;
    config.size = size;
    return config;
}

+ (instancetype)recordConfigWithVideoRatio:(AliyunVideoRatio)ratio
                                 videoSize:(AliyunVideoSize)size
                                  position:(AliyunCameraPosition)position
                                 trochMode:(AliyunCameraTorchMode)torchMode
                            beautifyStatus:(BOOL)beautifyStatus
                             beautifyValue:(int)beautifyValue
                                outputPath:(NSString *)outputPath
                               minDuration:(CGFloat)minDuration
                               maxDuration:(CGFloat)maxDuration
                              videoQuality:(AliyunVideoQuality)videoQuality
                                encodeMode:(AliyunVideoEncodeMode)encodeMode
                                       fps:(int)fps
                                       gop:(int)gop {
    
    AliyunVideoRecordParam *config = [[AliyunVideoRecordParam alloc] init];
    config.ratio = ratio;
    config.size = size;
    config.position = position;
    config.torchMode= torchMode;
    config.beautifyStatus = beautifyStatus;
    config.beautifyValue = beautifyValue;
    config.outputPath = outputPath;
    config.minDuration = minDuration;
    config.maxDuration = maxDuration;
    config.videoQuality = videoQuality;
    config.encodeMode = encodeMode;
    config.fps = fps;
    config.gop = gop;
    return config;
}

@end
