//
//  AliyunAlbumModel.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunAlbumModel.h"
#import <Photos/Photos.h>

@implementation AliyunAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(AliyunAssetModelMediaType)type{
    AliyunAssetModel *model = [[AliyunAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    
    NSInteger duration = type == AliyunAssetModelMediaTypeVideo ? asset.duration : 0;
    model.assetDuration = duration;
    model.timeLength = [self getNewTimeFromDurationSecond:duration];
    return model;
}

+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}
@end


@implementation AliyunAlbumModel

- (instancetype)initWithFetchResult:(PHFetchResult *)result albumName:(NSString *)albumName {
    self = [super init];
    if (self) {
        _fetchResult = result;
        _albumName = albumName;
        _assetsCount = result.count;
    }
    return self;
}
@end
