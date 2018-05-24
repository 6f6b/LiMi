//
//  AliyunEffectMvInfo.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMvGroup.h"

@implementation AliyunEffectMvGroup


- (NSString *)localResoucePathWithVideoRatio:(AliyunEffectMVRatio)r {
    
    if (!self.resourcePath) return nil;
    
    NSString *rootPath = [self localMVSourcePath];
    NSString *folderName = nil;
    NSArray *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
    if (subPaths.count) {
        BOOL hasFolder = NO;
        for (NSString *subPath in subPaths) {
            if ([subPath hasPrefix:@"folder"]) {
                hasFolder = YES;
                folderName = subPath;
                break;
            }
        }
        if (!hasFolder) {
            return rootPath;
        }
    }
    
    NSString *folder = folderName;
    float videoAspect;
    switch (r) {
        case AliyunEffectMVRatio1To1:
            folder = @"folder1.1";
            videoAspect = 1 / 1.0;
            break;
        case AliyunEffectMVRatio16To9:
            folder = @"folder16.9";
            videoAspect = 16 / 9.0;
            break;
        case AliyunEffectMVRatio9To16:
            folder = @"folder9.16";
            videoAspect = 9 / 16.0;
            break;
        case AliyunEffectMVRatio4To3:
            folder = @"folder4.3";
            videoAspect = 4 / 3.0;
            break;
        case AliyunEffectMVRatio3To4:
            folder = @"folder1.1";
            videoAspect = 3 / 4.0;
            break;
        default:
            break;
    }
    if (folder) {
        NSString *path = [rootPath stringByAppendingPathComponent:folder];
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (exists) {
            return path;
        } else {
            // 不存在时  取分辨率最近值的mv
            NSDictionary *dic = @{@(fabs(videoAspect - (9/16.0))):@"folder9.16",
                                  @(fabs(videoAspect - (3/4.0))):@"folder3.4",
                                  @(fabs(videoAspect - (1.0))):@"folder1.1",
                                  @(fabs(videoAspect - (4/3.0))):@"folder4.3",
                                  @(fabs(videoAspect - (16/9.0))):@"folder16.9"};
            NSArray *keySort = [[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
            
            for (int index = 0; index < keySort.count; index ++) {
                NSNumber *currentMinKey = keySort[index];
                NSString *currentPath = [rootPath stringByAppendingPathComponent:[dic objectForKey:currentMinKey]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:currentPath]){
                    NSLog(@"mvPath:%@", currentPath);
                    return currentPath;
                }
            }

        }
    }
    return rootPath;
}

- (NSString *)localMVSourcePath {
    return [NSHomeDirectory() stringByAppendingPathComponent:self.resourcePath];
}

@end
