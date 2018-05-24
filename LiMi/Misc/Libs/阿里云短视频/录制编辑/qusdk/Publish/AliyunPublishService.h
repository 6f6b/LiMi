//
//  AliyunPublishService.h
//  qusdk
//
//  Created by Worthy on 2017/10/30.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunPublishManager.h>

@interface AliyunPublishService : NSObject

@property (nonatomic, weak) id<AliyunIExporterCallback> exportCallback;
@property (nonatomic, weak) id<AliyunIUploadCallback> uploadCallback;

+ (instancetype)service;

- (BOOL)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath;

- (void)setTailWaterMark:(UIImage *)image frame:(CGRect)frame duration:(CGFloat)duration;

- (void)cancelExport;

- (BOOL)uploadWithImagePath:(NSString *)imagePath
                 svideoInfo:(AliyunUploadSVideoInfo *)svideoInfo
                accessKeyId:(NSString *)accessKeyId
            accessKeySecret:(NSString *)accessKeySecret
                accessToken:(NSString *)accessToken;

- (void)refreshWithAccessKeyId:(NSString *)accessKeyId
               accessKeySecret:(NSString *)accessKeySecret
                   accessToken:(NSString *)accessToken
                    expireTime:(NSString *)expireTime;

- (void)cancelUpload;


@end
