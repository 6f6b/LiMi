//
//  AliyunDownloadManager.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunPasterInfo.h"

@interface AliyunDownloadTask : NSObject

@property(nonatomic, copy) void (^progressBlock)(NSProgress *progress);
@property(nonatomic, copy) void (^completionHandler)(NSString *filePath, NSError *error);
@property(nonatomic, readonly) AliyunPasterInfo *pasterInfo;

//TODO:目前只有一种资源类型 先简单写 年后再拓展封装
- (id)initWithInfo:(AliyunPasterInfo *)pasterInfo;

@end




@interface AliyunDownloadManager : NSObject


- (void)addTask:(AliyunDownloadTask *)task;

- (void)addTask:(AliyunDownloadTask *)task
        progress:(void (^)(NSProgress*downloadProgress))progressBlock
completionHandler:(void(^)(NSString *filePath, NSError *error))completionHandler;


@end
