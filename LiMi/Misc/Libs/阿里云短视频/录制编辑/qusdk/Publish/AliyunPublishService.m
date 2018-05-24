//
//  AliyunPublishService.m
//  qusdk
//
//  Created by Worthy on 2017/10/30.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPublishService.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AliyunPublishService() <AliyunIExporterCallback, AliyunIUploadCallback>
@property (nonatomic, strong) AliyunPublishManager *manager;
@end

@implementation AliyunPublishService

-(instancetype)init {
    self = [super init];
    if (self) {
        _manager = [AliyunPublishManager new];
        _manager.exportCallback = self;
        _manager.uploadCallback = self;
    }
    return self;
}

+ (instancetype)service {
    static dispatch_once_t onceToken;
    static AliyunPublishService *service = nil;
    dispatch_once(&onceToken, ^{
        service = [[AliyunPublishService alloc] init];
    });
    return service;
}

-(void)setTailWaterMark:(UIImage *)image frame:(CGRect)frame duration:(CGFloat)duration {
    [_manager setTailWaterMark:image frame:frame duration:duration];
}

- (BOOL)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath {
    return [_manager exportWithTaskPath:taskPath outputPath:outputPath];
}

- (void)cancelExport {
    [_manager cancelExport];
}

-(BOOL)uploadWithImagePath:(NSString *)imagePath
                svideoInfo:(AliyunUploadSVideoInfo *)svideoInfo
               accessKeyId:(NSString *)accessKeyId
           accessKeySecret:(NSString *)accessKeySecret
               accessToken:(NSString *)accessToken {
    return [_manager uploadWithImagePath:imagePath svideoInfo:svideoInfo accessKeyId:accessKeyId accessKeySecret:accessKeySecret accessToken:accessToken];
}

-(void)refreshWithAccessKeyId:(NSString *)accessKeyId
              accessKeySecret:(NSString *)accessKeySecret
                  accessToken:(NSString *)accessToken
                   expireTime:(NSString *)expireTime {
    [_manager refreshWithAccessKeyId:accessKeyId accessKeySecret:accessKeySecret accessToken:accessToken expireTime:expireTime];
}

-(void)cancelUpload {
    [_manager cancelUpload];
}

#pragma mark - callback

-(void)exportError:(int)errorCode {
    [_exportCallback exportError:errorCode];
}

-(void)exporterDidEnd:(NSString *)outputPath {
    [_exportCallback exporterDidEnd:outputPath];
}

-(void)exporterDidStart {
    [_exportCallback exporterDidStart];
}

-(void)exporterDidCancel {
    [_exportCallback exporterDidCancel];
}

- (void)exportProgress:(float)progress {
    [_exportCallback exportProgress:progress];
}

- (void)uploadSuccessWithVid:(NSString *)vid imageUrl:(NSString *)imageUrl {
    [_uploadCallback uploadSuccessWithVid:vid imageUrl:imageUrl];
}

- (void)uploadFailedWithCode:(NSString *)code message:(NSString *)message {
    [_uploadCallback uploadFailedWithCode:code message:message];
}

- (void)uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize {
    [_uploadCallback uploadProgressWithUploadedSize:uploadedSize totalSize:totalSize];
}

- (void)uploadTokenExpired {
    [_uploadCallback uploadTokenExpired];
}

-(void)uploadRetry {
    [_uploadCallback uploadRetry];
}

-(void)uploadRetryResume {
    [_uploadCallback uploadRetryResume];
}

@end
