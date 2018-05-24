//
//  AliyunEffectResourceModel.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectResourceModel.h"
#import "AliyunPathManager.h"

@implementation AliyunEffectResourceModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"eid":@"id",
                                                                  @"edescription":@"description",
                                                                  @"mvList":@"aspectList"}];
}


- (NSString *)storageFullPath {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:[self storageDirectory]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

-(NSString *)storageDirectory {
    
    return [[self class] storageDirectoryWithEffectType:self.effectType];
}

+ (NSString *)storageDirectoryWithEffectType:(AliyunEffectType)type {
    
    NSString *path = @"pasterRes";
    switch (type) {
        case AliyunEffectTypeMV:
            path = @"mvRes";
            break;
        case AliyunEffectTypeFilter:
            path = @"filterRes";
            break;
        case AliyunEffectTypeMusic:
            path = @"musicRes";
            break;
        case AliyunEffectTypeFont:
            path = @"fontRes";
            break;
        case AliyunEffectTypePaster:
            path = @"pasterRes";
            break;
        case AliyunEffectTypeCaption:
            path = @"subtitleRes";
            break;
        default:
            break;
    }
    return [[AliyunPathManager resourceRelativeDir] stringByAppendingPathComponent:path];
}

+ (NSString *)effectNameByPath:(NSString *)path
{
    NSRange range = [path rangeOfString:@"-"];
    if (range.length <= 0) {
        return nil;
    }
    
    NSString *effectName = [path substringFromIndex:NSMaxRange(range)];
    return effectName;
}

+ (id)effectIdByPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"-"];
    if (components.count <= 1) {
        NSError *err = [[NSError alloc] initWithDomain:@"Resource Err" code:-9090 userInfo:nil];
        return err;
    }
    return [components firstObject];
}


@end
