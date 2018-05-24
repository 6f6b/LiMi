//
//  VODUploadClient.h
//  VODUpload
//
//  Created by Leigang on 16/3/28.
//  Copyright © 2016年 Leigang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VODUploadModel.h"

@interface VODUploadClient : NSObject

/**
 无配置上传
 */
- (BOOL)        init:(VODUploadListener *) listener;
/**
 AK方式配置上传
 */
- (BOOL)        init:(NSString *)accessKeyId
     accessKeySecret:(NSString *)accessKeySecret
            listener:(VODUploadListener *) listener;

/**
 STS授权方式配置上传
 */
- (BOOL)        init:(NSString *)accessKeyId
     accessKeySecret:(NSString *)accessKeySecret
         secretToken:(NSString *)secretToken
          expireTime:(NSString *)expireTime
            listener:(VODUploadListener *) listener;

/**
 添加视频上传
 */
- (BOOL)addFile:(NSString *)filePath
        vodInfo:(VodInfo *)vodInfo;

/**
 添加视频上传
 */
- (BOOL)addFile:(NSString *)filePath
       endpoint:(NSString *)endpoint
         bucket:(NSString *)bucket
         object:(NSString *)object;

/**
 添加视频上传
 */
- (BOOL)addFile:(NSString *)filePath
       endpoint:(NSString *)endpoint
         bucket:(NSString *)bucket
         object:(NSString *)object
        vodInfo:(VodInfo *)vodInfo;

/**
 删除文件
 */
- (BOOL)deleteFile:(int) index;

/**
 清除上传列表
 */
- (BOOL)clearFiles;


/**
 获取上传文件列表
 */
- (NSMutableArray<UploadFileInfo *> *)listFiles;

/**
 取消单个文件上传，文件保留在上传列表中
 */
- (BOOL)cancelFile:(int)index;

/**
 恢复已取消的上传文件
 */
- (BOOL)resumeFile:(int)index;

/**
 开始上传
 */
- (BOOL)start;

/**
 停止上传
 */
- (BOOL)stop;

/**
 暂停上传
 */
- (BOOL)pause;

/**
 恢复上传
 */
- (BOOL)resume;

/**
 使用Token恢复上传
 */
- (BOOL)resumeWithAuth:(NSString *)uploadAuth;

/**
 使用Token恢复上传
 */
- (BOOL)resumeWithToken:(NSString *)accessKeyId
        accessKeySecret:(NSString *)accessKeySecret
            secretToken:(NSString *)secretToken
             expireTime:(NSString *)expireTime;

/**
 设置上传凭证
 */
- (BOOL)setUploadAuthAndAddress:(UploadFileInfo *)uploadFileInfo
           uploadAuth:(NSString *)uploadAuth
        uploadAddress:(NSString *)uploadAddress;

@end

