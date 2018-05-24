//
//  AliyunResourceDownloadManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunResourceDownloadManager.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "QPSSZipArchive.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectFontManager.h"
#import "AliyunResourceFontRequest.h"
#import "AliyunResourceFontDownload.h"

@implementation AliyunResourceDownloadTask

- (id)initWithModel:(AliyunEffectResourceModel *)resourceModel {
    
    if (self = [super init]) {
        _resourceModel = resourceModel;
    }
    return self;
}

@end

@interface AliyunResourceDownloadManager ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, assign) NSInteger totleCount;// 资源总数
@property (nonatomic, assign) NSInteger currentIndex;// 当前下载Index
@end

@implementation AliyunResourceDownloadManager {
    
    AliyunResourceDownloadTask *_task;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public

- (void)addDownloadTask:(AliyunResourceDownloadTask *)task {
    
    [self addDownloadTask:task progress:nil completionHandler:nil];

}

- (void)addDownloadTask:(AliyunResourceDownloadTask *)task
               progress:(void (^)(CGFloat progress))progressBlock
      completionHandler:(void (^)(AliyunEffectResourceModel *newModel, NSError *error))completionHandler {

    task.progressBlock = progressBlock;
    task.completionHandler = completionHandler;
    _task = task;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    self.currentIndex = 0;

    self.downloadQueue = [[NSOperationQueue alloc] init];
    self.downloadQueue.name = @"com.duanqu.resourceDownload";
    NSInvocationOperation *operation  = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadResource) object:nil];
    [self.downloadQueue addOperation:operation];
}


#pragma mark - Download

// 下载资源总入口 该方法用于分类区分怎么下载
- (void)downloadResource {
    
    AliyunEffectType type = _task.resourceModel.effectType;
    if (type == AliyunEffectTypeMV) {
        // MV
        [self downloadMVResource];
    } else if (type == AliyunEffectTypePaster) {
        // 动图
        [self downloadPasterResoure];
    } else if (type == AliyunEffectTypeCaption) {
        // 字幕
        [self downloadCaptionResoure];
    } else if (type == AliyunEffectTypeFont) {
        // 字体
        [self downloadFontResource];
    } else if (type == AliyunEffectTypeMusic) {
        // 音乐
        [self downloadMusicResource];
    } else {
        // 其他
        [self completionOnMainQueue:nil error:[NSError errorWithDomain:@"com.duanqu.download" code:-1000 userInfo:@{@"errorInfo":@"非法的素材类型"}]];
    }
}

// 下载音乐资源
- (void)downloadMusicResource {
    
    self.totleCount = 1;
    NSString *name = [NSString stringWithFormat:@"%ld-%@", (long)_task.resourceModel.eid, _task.resourceModel.name];
    NSString *destination = [[[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]] stringByAppendingPathComponent:_task.resourceModel.url.lastPathComponent];

    [self downloadWithUrl:_task.resourceModel.url destination:destination unZipPath:nil];
}

// 下载字体
- (void)downloadFontResource {
    
    self.totleCount = 1;
    NSString *name = [NSString stringWithFormat:@"%ld-%@", (long)_task.resourceModel.eid, _task.resourceModel.name];
    NSString *destination = [[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-tmp", name]];
    NSString *zipPath = [[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]];
    [self downloadWithUrl:_task.resourceModel.url destination:destination unZipPath:zipPath];

}


// 下载MV资源
- (void)downloadMVResource {
    
    self.totleCount = _task.resourceModel.mvList.count;
    AliyunEffectMvInfo *model = _task.resourceModel.mvList[self.currentIndex];
    
    NSString *basePath= [[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", _task.resourceModel.eid, _task.resourceModel.name]];
    NSString *destination = [[basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-tmp", model.aspect]] stringByAppendingPathComponent:model.download.lastPathComponent];
    NSString *unZipPath = basePath;
    
    [self downloadWithUrl:model.download destination:destination unZipPath:unZipPath];
}


// 下载动图资源
- (void)downloadPasterResoure {
    
    self.totleCount = _task.resourceModel.pasterList.count;
    AliyunEffectPasterInfo *model = _task.resourceModel.pasterList[_currentIndex];
    
    // 下载一个动图
    NSString *basePath= [[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", (long)_task.resourceModel.eid, _task.resourceModel.name]];
    NSString *destination = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@-tmp",(long)model.pid, model.name]];
    NSString *unZipPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@",(long)model.pid, model.name]];
    
    [self downloadWithUrl:model.url destination:destination unZipPath:unZipPath];
    
}

// 下载字幕
- (void)downloadCaptionResoure {
    
    self.totleCount = _task.resourceModel.pasterList.count * 2;
    AliyunEffectPasterInfo *model = _task.resourceModel.pasterList[_currentIndex / 2];
    if (!model.fontId) {
        [_task.resourceModel.pasterList[_currentIndex / 2] setValue:@"-2" forKey:@"fontId"];
    }
    if (self.currentIndex % 2 == 0) {
        // 下载对应的字体
        AliyunResourceFontDownload *fontDown = [[AliyunResourceFontDownload alloc] init];
        [fontDown downloadFontWithFontId:[model.fontId integerValue] progress:^(CGFloat progress) {
            
            CGFloat percent = (CGFloat)self.currentIndex / (CGFloat)self.totleCount;
            CGFloat currentProgress = progress / self.totleCount + percent;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _task.progressBlock(currentProgress);
            }];
        } completion:^(AliyunEffectResourceModel *newModel, NSError *error) {
            
            self.currentIndex++;
            [self downloadResource];
        }];
        
    } else {
        // 下载资源
        NSString *basePath= [[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", (long)_task.resourceModel.eid, _task.resourceModel.name]];
        NSString *destination = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@-tmp",(long)model.pid, model.name]];
        NSString *unZipPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@",(long)model.pid, model.name]];
        
        [self downloadWithUrl:model.url destination:destination unZipPath:unZipPath];

    }
}


// 下载
- (void)downloadWithUrl:(NSString *)url destination:(NSString *)destination unZipPath:(NSString *)unZipPath{
    
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:nil];
    [httpClient download:url destination:destination progress:^(NSProgress *downloadProgress) {
        
        CGFloat percent = (CGFloat)self.currentIndex / (CGFloat)self.totleCount;
        CGFloat progress = downloadProgress.fractionCompleted / self.totleCount + percent;

        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _task.progressBlock(progress);
        }];
        
    } completionHandler:^(NSURL *filePath, NSError *error) {
        
        if (error) {
            [self completionOnMainQueue:nil error:error];
        } else {
            [self unZipFrom:filePath.path to:unZipPath];
        }
    }];

}

#pragma mark - Tools

- (void)unZipFrom:(NSString *)filePath to:(NSString *)toDestination {
    
    if (!toDestination) {
        // 单个下载不需要解压
        [self updateResourceModelWithFilePath:filePath];
        [self completionOnMainQueue:_task.resourceModel error:nil];
    } else {
        // 多个下载  解压缩
        BOOL unzip = [QPSSZipArchive unzipFileAtPath:filePath toDestination:toDestination];
        
        // 解压失败
        if (!unzip) {
            NSError *error = [NSError errorWithDomain:@"com.duanqu" code:-1000 userInfo:@{@"errorInfo":@"解压失败"}];
            [self completionOnMainQueue:nil error:error];
            return ;
        }
        
        // 移除压缩包
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        if (_task.resourceModel.effectType == AliyunEffectTypeFont) {
            // 如果是字体需要移动资源位置
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
            if (!fontName) {
                NSError *error = [NSError errorWithDomain:@"com.duanqu.download" code:-1000 userInfo:@{@"errorInfo":@"字体注册失败"}];
                [self completionOnMainQueue:nil error:error];
                return;
            }
            [_task.resourceModel setValue:fontName forKey:@"fontName"];
        }
        
        // 更新Model
        [self updateResourceModelWithFilePath:toDestination];

        // 下载index +1
        self.currentIndex++;
        if (self.currentIndex < self.totleCount) {
            // 若有多组下载 那么执行下一个下载
            NSLog(@"download next");
            [self downloadResource];
            
        } else {
            // 下载完毕
            [self completionOnMainQueue:_task.resourceModel error:nil];
        }

    }

}


- (void)updateResourceModelWithFilePath:(NSString *)filePath {
    
    NSArray *filePathArray = [filePath componentsSeparatedByString:@"Documents/"];
    
    NSString *relativePath = [@"Documents/" stringByAppendingPathComponent:filePathArray.lastObject];
    
    AliyunEffectType type = _task.resourceModel.effectType;
    if (type == AliyunEffectTypeMV) {
        // MV
        NSString *mvBasePath = [relativePath stringByAppendingPathComponent:_task.resourceModel.name];
        [_task.resourceModel setValue:mvBasePath forKey:@"resourcePath"];
        
    } else if (type == AliyunEffectTypePaster) {
        // 动图
        AliyunEffectPasterInfo *info = _task.resourceModel.pasterList[_currentIndex];
        NSString *pasterPath = [relativePath stringByAppendingPathComponent:info.name];
        [info setValue:pasterPath forKey:@"resourcePath"];
        [_task.resourceModel.pasterList[_currentIndex] setValue:pasterPath forKey:@"resourcePath"];

    } else if (type == AliyunEffectTypeCaption) {
        //   字幕
        // TODO:解析config文件  赋值    ~~~~~~已赋值，但无效~~~~~~
        AliyunEffectPasterInfo *info = _task.resourceModel.pasterList[_currentIndex / 2];
        NSString *pasterPath = [relativePath stringByAppendingPathComponent:info.name];
        
        NSString *configJsonPath = [pasterPath stringByAppendingPathComponent:@"config.json"];
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:configJsonPath]];
        NSDictionary *mapper = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        [info setValue:[mapper objectForKey:@"tFont"] forKey:@"configFontName"];
        [info setValue:@([[mapper objectForKey:@"fontId"] intValue]) forKey:@"configFontId"];
        [info setValue:pasterPath forKey:@"resourcePath"];
        [_task.resourceModel.pasterList[_currentIndex / 2] setValue:pasterPath forKey:@"resourcePath"];//TODO: why???
        
    } else if(type == AliyunEffectTypeFont) {
        // 字体
        [_task.resourceModel setValue:relativePath forKey:@"resourcePath"];
    } else {
        [_task.resourceModel setValue:relativePath forKey:@"resourcePath"];
    }
    
}


- (void)completionOnMainQueue:(AliyunEffectResourceModel *)model error:(NSError *)error {
    
    if (error) {
        // 下载失败 删除缓存
        NSString *filePath = [[_task.resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", (long)_task.resourceModel.eid, _task.resourceModel.name]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
    [_task.resourceModel setValue:@(1) forKey:@"isDBContain"];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _task.completionHandler(model, error);
    }];
}


#pragma mark - Notification

- (void)applicationDidBecomeActive {
    
    [self.downloadQueue setSuspended:NO];
}

- (void)applicationWillResignActive {
    
    [self.downloadQueue setSuspended:YES];
}


@end
