//
//  AliyunResourceFontDownload.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunResourceFontDownload.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectFontManager.h"
#import "AliyunDBHelper.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "QPSSZipArchive.h"


@interface AliyunResourceFontDownload ()

@property (nonatomic, copy) void (^progressBlock)(CGFloat progress);
@property (nonatomic, copy) void (^completionHandler)(AliyunEffectResourceModel *newModel, NSError *error);
@property (nonatomic, strong) AliyunEffectResourceModel *fontModel;

@property (nonatomic, strong) AliyunDBHelper *helper;

@end

@implementation AliyunResourceFontDownload

#pragma mark - 字体下载
- (void)downloadFontWithFontId:(NSInteger)fontId
                      progress:(void(^)(CGFloat progress))progress
                    completion:(void(^)(AliyunEffectResourceModel *newModel, NSError *error))completion {
    
    self.progressBlock = progress;
    self.completionHandler = completion;

    self.helper = [[AliyunDBHelper alloc] init];
    [self.helper openResourceDBSuccess:nil failure:nil];
    if (!fontId || fontId == -2) {
        // 无对应字体 使用默认字体
        self.completionHandler(nil, nil);
        return;
    }
    
    [self requestWithFontId:(int)fontId success:^(AliyunEffectResourceModel *fontModel) {
        
        self.fontModel = fontModel;
        
        BOOL isSave = [self.helper queryOneResourseWithEffectResourceModel:fontModel];
        if (isSave) {
            NSLog(@"字体已下载");
            [self completionCallBack:fontModel error:nil];
            return ;
        }
        [self downloadFontWithFontModel:fontModel];
        
    } failure:^(NSError *error) {
        
        [self completionCallBack:nil error:error];
    }];
  
}

#pragma mark - 字体数据请求
- (void)requestWithFontId:(int)fontId
                  success:(void(^)(AliyunEffectResourceModel *fontModel))success
                  failure:(void(^)(NSError *error))failure {
    
    AliyunHttpClient *client = [[AliyunHttpClient alloc] initWithBaseUrl:kQPResourceHostUrl];
    NSString *url = [NSString stringWithFormat:@"api/res/get/1/%d", fontId];
    NSDictionary *param = @{@"type":@(1),
                            @"id":@(fontId),
                            @"bundleId":BundleID};
    [client GET:url parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            if (failure) {
                [self completionCallBack:nil error:error];
            }
        } else {
            
            if ([responseObject isKindOfClass:[NSArray class]] && [responseObject count] == 0) {
                
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10001 userInfo:nil];
                if (failure) {
                    [self completionCallBack:nil error:error];
                }
                return ;
            }
            
            if ([[responseObject objectForKey:@"id"] intValue] == 0) {
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10002 userInfo:nil];
                if (failure) {
                    [self completionCallBack:nil error:error];
                }
                return ;
            }
            
            AliyunEffectResourceModel *fontModel = [[AliyunEffectResourceModel alloc] initWithDictionary:responseObject error:nil];
            [fontModel setValue:@(1) forKey:@"effectType"];
            if (success) {
                success(fontModel);
            }
        }
        
    }];

}

#pragma mark - 字体下载

- (void)downloadFontWithFontModel:(AliyunEffectResourceModel *)fontModel {
    
    NSString *name = [NSString stringWithFormat:@"%ld-%@", (long)fontModel.eid, fontModel.name];
    NSString *destination = [[fontModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-tmp", name]];
    NSString *zipPath = [[fontModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]];
    
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:nil];
    [httpClient download:fontModel.url destination:destination progress:^(NSProgress *downloadProgress) {
        
        if (self.progressBlock) {
            self.progressBlock((CGFloat)downloadProgress.fractionCompleted);
        }
        
        
    } completionHandler:^(NSURL *filePath, NSError *error) {
        
        if (error) {
            [self completionCallBack:nil error:error];
            return ;
        }
        
        [self unZipFrom:filePath.path to:zipPath];
        
    }];

}

#pragma mark - 解压拷贝

- (void)unZipFrom:(NSString *)filePath to:(NSString *)toDestination  {
    
    BOOL unzip = [QPSSZipArchive unzipFileAtPath:filePath toDestination:toDestination];
    
    // 解压失败
    if (!unzip) {
        NSError *error = [NSError errorWithDomain:@"com.duanqu.fontDownload" code:-1000 userInfo:@{@"errorInfo":@"解压失败"}];
        NSLog(@"字体解压失败");
        [self completionCallBack:nil error:error];
        return ;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    NSString *fileBase = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:toDestination error:nil] firstObject];
    NSString *fileBasePath = [toDestination stringByAppendingPathComponent:fileBase];
    NSArray *fontFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileBasePath error:nil];
    
    for (NSString *oldFilePath in fontFiles) {
        
        NSURL *oldURL = [NSURL fileURLWithPath:[fileBasePath stringByAppendingPathComponent:oldFilePath]];
        [[NSFileManager defaultManager] moveItemAtURL:oldURL toURL:[NSURL fileURLWithPath:[toDestination stringByAppendingPathComponent:oldFilePath]] error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileBasePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileBasePath error:nil];
    }
    
    // 注册字体
    NSString *fontPath = [[toDestination stringByAppendingPathComponent:@"font"] stringByAppendingPathExtension:@"ttf"];
    NSString *fontName = [[AliyunEffectFontManager manager] registerFontWithFontPath:fontPath];
    
    NSArray *filePathArray = [toDestination componentsSeparatedByString:@"Documents/"];
    NSString *relativePath = [@"Documents/" stringByAppendingPathComponent:filePathArray.lastObject];
    [self.fontModel setValue:fontName forKey:@"fontName"];
    [self.fontModel setValue:relativePath forKey:@"resourcePath"];
    [self.fontModel setValue:@(1) forKey:@"isDBContain"];
    [self.helper insertDataWithEffectResourceModel:self.fontModel];
    
    [self completionCallBack:self.fontModel error:nil];
}


#pragma mark - 存储

- (void)completionCallBack:(AliyunEffectResourceModel *)model error:(NSError *)error {
    
    if (error) {
        // 下载失败 删除缓存
        NSString *filePath = [[self.fontModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", (long)self.fontModel.eid, self.fontModel.name]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    [self.helper closeDB];
    self.completionHandler(model, error);
}

@end
