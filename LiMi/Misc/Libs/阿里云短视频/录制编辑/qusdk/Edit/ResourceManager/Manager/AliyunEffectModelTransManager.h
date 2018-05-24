//
//  AliyunEffectModelTransManager.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AliyunEffectResourceModel;
@class AliyunEffectInfo;

@interface AliyunEffectModelTransManager : NSObject



+ (AliyunEffectModelTransManager *)manager;


/**
 AliyunEffectResourceModel转换为AliyunEffectInfo

 @param resourceModel AliyunEffectResourceModel
 @return AliyunEffectInfo
 */
- (AliyunEffectInfo *)transEffectInfoModelWithResourceModel:(AliyunEffectResourceModel *)resourceModel;




/**
 AliyunEffectInfo转换为AliyunEffectResourceModel

 @param info AliyunEffectInfo
 @return AliyunEffectResourceModel
 */
- (AliyunEffectResourceModel *)transResourceModelWithEffectInfo:(AliyunEffectInfo *)info;

@end
