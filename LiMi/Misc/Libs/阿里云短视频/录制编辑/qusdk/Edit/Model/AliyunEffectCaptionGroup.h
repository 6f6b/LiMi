//
//  AliyunEffectCaptionGroup.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectInfo.h"
#import "AliyunEffectPasterInfo.h"

@interface AliyunEffectCaptionGroup : AliyunEffectInfo

@property (nonatomic, copy) NSString *isNew;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, strong) NSArray<AliyunEffectPasterInfo> *pasterList;

@end
