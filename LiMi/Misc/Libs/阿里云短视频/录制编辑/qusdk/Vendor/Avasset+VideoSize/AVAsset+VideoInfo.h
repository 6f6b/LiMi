//
//  AVAsset+VideoInfo.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (VideoInfo)

- (CGSize)avAssetNaturalSize;

- (CGFloat)avAssetVideoTrackDuration;

- (float)frameRate;

- (NSString *)artist;

- (NSString *)title;
@end
