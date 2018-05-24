//
//  AliyunDownloadManager.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunDownloadManager.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "QPSSZipArchive.h"

@implementation AliyunDownloadTask

- (id)initWithInfo:(AliyunPasterInfo *)pasterInfo
{
    if (self = [super init]) {
        _pasterInfo = pasterInfo;
    }
    return self;
}

@end

















@implementation AliyunDownloadManager
{
//    AliyunDownloadTask *_task;
    NSMutableDictionary *_tasks;
}

- (void)addTask:(AliyunDownloadTask *)task
{
    [self addTask:task progress:nil completionHandler:nil];
}

- (void)addTask:(AliyunDownloadTask *)task progress:(void (^)(NSProgress*downloadProgress))progressBlock completionHandler:(void(^)(NSString *filePath, NSError *error))completionHandler
{
    AliyunPasterInfo *pasterInfo = task.pasterInfo;
    task.progressBlock = progressBlock;
    task.completionHandler = completionHandler;
    
//    _task = task;
    
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:pasterInfo.url];
    NSString *name = [NSString stringWithFormat:@"%@-%ld-tmp.%@", pasterInfo.name, (long)pasterInfo.eid, [pasterInfo.url pathExtension]];
    NSString *destination = [[pasterInfo directoryPath] stringByAppendingPathComponent:name];
    
    if (_tasks == nil) {
        _tasks = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"~~~~~destination:%@", destination);
    [_tasks setObject:task forKey:destination];
    
    [httpClient download:pasterInfo.url destination:destination progress:^(NSProgress *downloadProgress) {
        if (task.progressBlock) {
            task.progressBlock(downloadProgress);
        }
    } completionHandler:^(NSURL *filePath, NSError *error) {
        NSLog(@" download error:%@", error);
        NSString *unzipName = [NSString stringWithFormat:@"%@-%ld", pasterInfo.name, (long)pasterInfo.eid];
        NSString *unzipPath = [[[pasterInfo directoryPath] stringByAppendingPathComponent:unzipName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self upzip:filePath to:[NSURL URLWithString:unzipPath]];
        });
        
    }];
}

- (void)upzip:(NSURL *)filePath to:(NSURL *)toDestination
{
    [QPSSZipArchive unZipEffectItemAtPath:filePath.path toDestination:toDestination.path overwrite:YES password:nil error:nil block:^(bool finish, NSString *path, NSString *destination) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:destination];
        for (NSString *file in enumerator) {
            NSString *path = [destination stringByAppendingPathComponent:file];
            NSDictionary *attribute = [fm attributesOfItemAtPath:path error:nil];
            NSString * fileType = attribute[NSFileType];
            
            if ([fileType isEqualToString:NSFileTypeDirectory]) {
                NSError *error = nil;
                NSArray *files = [fm contentsOfDirectoryAtPath:path error:&error];
                
                for (NSString *fileItem in files) {
                    NSString *atPath = [path stringByAppendingPathComponent:fileItem];
                    NSString *toPath = [destination stringByAppendingPathComponent:fileItem];
                    
//                    [fm moveItemAtPath:atPath toPath:toPath error:nil];
                    NSError *mvErr = nil;
                    [fm moveItemAtPath:atPath toPath:toPath error:&mvErr];
                    if (mvErr) {
                        NSLog(@"~~~~mv error:%@", mvErr);
                    }
                }
                NSError *rmErr = nil;
                [fm removeItemAtPath:path error:&rmErr];
                if (rmErr) {
                    NSLog(@"~~~~~~rm error:%@", rmErr);
                }
                
                [fm removeItemAtPath:path error:nil];
            }
        }
        
        if (finish) {
//            [fm removeItemAtPath:filePath.path error:nil];
//            _task.completionHandler(toDestination.path, nil);
            NSError *fError = nil;
            [fm removeItemAtPath:filePath.path error:&fError];
            if (fError) {
                NSLog(@"~~~~~~f error:%@", fError);
            }
            
            NSLog(@"~~~~~~filepath.path:%@", filePath.path);
            
            AliyunDownloadTask *task = [_tasks objectForKey:filePath.path];
            [_tasks removeObjectForKey:filePath.path];
            if (task) {
                task.completionHandler(toDestination.path, nil);
            }
            
        }
    }];
}

@end
