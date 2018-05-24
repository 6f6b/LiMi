//
//  AliyunEffectMusicInfo.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMusicInfo.h"

@implementation AliyunEffectMusicInfo

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"eid":@"id",
                                                                  @"edescription":@"description"}];
}

@end
