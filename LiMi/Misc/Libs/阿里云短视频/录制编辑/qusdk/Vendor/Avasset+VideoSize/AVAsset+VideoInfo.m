//
//  AVAsset+VideoInfo.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AVAsset+VideoInfo.h"

@implementation AVAsset (VideoInfo)

- (CGSize)avAssetNaturalSize {
    AVAssetTrack *assetTrackVideo;
    NSArray *videoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count) {
        assetTrackVideo = videoTracks[0];
    }
    float sw = assetTrackVideo.naturalSize.width, sh = assetTrackVideo.naturalSize.height;
    BOOL isAssetPortrait = NO;
    CGAffineTransform trackTrans = assetTrackVideo.preferredTransform;
    if ((trackTrans.b == 1.0 && trackTrans.c == -1.0) || (trackTrans.b == -1.0 && trackTrans.c == 1.0)) {
        isAssetPortrait = YES;
    }
    if (isAssetPortrait) {
        float t = sw;
        sw = sh;
        sh = t;
    }
    return CGSizeMake(sw, sh);
}

- (float)frameRate {
    AVAssetTrack *assetTrackVideo;
    NSArray *videoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count) {
        assetTrackVideo = videoTracks[0];
    }
    return assetTrackVideo.nominalFrameRate;
}

- (CGFloat)avAssetVideoTrackDuration {
    
    NSArray *videoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count) {
        AVAssetTrack *track = videoTracks[0];
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    
    NSArray *audioTracks = [self tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count) {
        AVAssetTrack *track = audioTracks[0];
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    
    return -1;
}

- (NSString *)title {
    NSArray<AVMetadataItem *> *artists = [AVMetadataItem metadataItemsFromArray:self.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
    if (artists.count) {
        return (NSString *)[artists[0] value];
    }
    return nil;
}

- (NSString *)artist {
    NSArray<AVMetadataItem *> *artists = [AVMetadataItem metadataItemsFromArray:self.commonMetadata withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon];
    if (artists.count) {
        return (NSString *)[artists[0] value];
    }
    return nil;
}
@end
