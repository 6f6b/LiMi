//
//  AliyunEffectMvInfo.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectInfo.h"
#import "AliyunEffectMvInfo.h"

typedef NS_ENUM(NSInteger, AliyunEffectMVRatio) {
    AliyunEffectMVRatio9To16,
    AliyunEffectMVRatio3To4,
    AliyunEffectMVRatio1To1,
    AliyunEffectMVRatio4To3,
    AliyunEffectMVRatio16To9,
};

@interface AliyunEffectMvGroup : AliyunEffectInfo

@property (nonatomic, copy) NSArray <AliyunEffectMvInfo> *mvList;

- (NSString *)localResoucePathWithVideoRatio:(AliyunEffectMVRatio)r;

@end
