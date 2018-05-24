//
//  QUCompressManager.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunMediaConfig.h"

@interface AliyunCompressManager : NSObject
- (instancetype)initWithMediaConfig:(AliyunMediaConfig *)config;
- (void)compressWithSourcePath:(NSString *)sourcePath
                    outputPath:(NSString *)outputPath
                    outputSize:(CGSize)outputSize
                       success:(void (^)())success
                       failure:(void(^)())failure;

- (UIImage *)compressImageWithSourceImage:(UIImage *)sourceImage
                               outputSize:(CGSize)outputSize;

- (void)stopCompress;


@end
