//
//  AliyunPathManager.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPathManager.h"

@implementation AliyunPathManager

#pragma mark - Public

+ (NSString *)aliyunRootPath {
    return [[self rootPath] stringByAppendingPathComponent:@"com.duanqu.demo"];
}

+ (NSString *)quCachePath {
    return [[self cachePath] stringByAppendingPathComponent:@"com.duanqu.demo"];
}

+ (NSString *)compositionRootDir {
    return [[self aliyunRootPath] stringByAppendingPathComponent:@"composition"];
}

+ (NSString *)quRelativeRootPath {
    
    return @"Documents/com.duanqu.demo";
}

//+ (NSString *)createCompositionDir {
//    NSString *root = [self compositionRootDir];
//    NSString *dir = [root stringByAppendingPathComponent:[self uuidString]];
//    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
//    return dir;
//}

+ (void)clearDir:(NSString *)dirPath {
    [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString*)uuidString {
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

+ (NSString *)createRecrodDir {
    return [[self aliyunRootPath] stringByAppendingPathComponent:@"record"];
}

+ (NSString *)createCutDir {
    return [[self aliyunRootPath] stringByAppendingPathComponent:@"cut"];
}

+ (NSString *)createExportDir {
    return [[self aliyunRootPath] stringByAppendingPathComponent:@"export"];
}

+ (NSString *)creatMusicDownloadDir{
    return [[self quCachePath] stringByAppendingPathComponent:@"musicDownload"];
}
+ (NSString *)createMagicRecordDir {
    return [[self aliyunRootPath] stringByAppendingPathComponent:@"magicRecord"];
}

+ (NSString *)createResourceDir {
    return [[self aliyunRootPath] stringByAppendingPathComponent:@"QPRes"];
}

+ (NSString *)resourceRelativeDir {
    return [[self quRelativeRootPath] stringByAppendingPathComponent:@"QPRes"];
}

#pragma mark - Private

+ (NSString *)rootPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)cachePath {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

@end
