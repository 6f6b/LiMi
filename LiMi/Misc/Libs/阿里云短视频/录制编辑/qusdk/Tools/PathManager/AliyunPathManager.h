//
//  AliyunPathManager.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunPathManager : NSObject

/**
 文件根目录

 @return 文件根目录
 */
+ (NSString *)aliyunRootPath;

/**
 视频合成文件根目录

 @return 视频合成文件根目录
 */
+ (NSString *)compositionRootDir;

/**
 创建一个视频合成临时文件夹

 @return 视频合成临时文件夹
 */
//+ (NSString *)createCompositionDir;



/**
 文件根目录的相对路径

 @return 文件根目录 相对路径
 */
+ (NSString *)quRelativeRootPath;


+ (void)clearDir:(NSString *)dirPath;


+ (NSString *)createRecrodDir;

+ (NSString *)createCutDir ;

+ (NSString *)createMagicRecordDir;

+ (NSString *)createResourceDir;

+ (NSString *)resourceRelativeDir;

/**
 生成随机字符串

 @return 随机字符串
 */
+ (NSString*)uuidString;

@end
