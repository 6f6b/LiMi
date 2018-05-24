//
//  AliyunResourceFontRequest.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AliyunEffectResourceModel;

@interface AliyunResourceFontRequest : NSObject


/**
 获取fontModel

 @param fontId id
 @param success 成功
 @param failure 失败
 */
+ (void)requestWithFontId:(NSInteger)fontId
                  success:(void(^)(AliyunEffectResourceModel *))success
                  failure:(void(^)(NSError *error))failure;

@end
