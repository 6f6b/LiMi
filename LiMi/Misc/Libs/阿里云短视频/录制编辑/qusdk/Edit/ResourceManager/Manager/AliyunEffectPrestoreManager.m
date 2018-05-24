//
//  AliyunEffectPrestoreManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/21.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectPrestoreManager.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectResourceModel.h"

@interface AliyunEffectPrestoreManager ()

@property (nonatomic, strong) AliyunDBHelper *helper;

@end

@implementation AliyunEffectPrestoreManager


#pragma mark - 初始化本地资源
- (void)insertInitialData {
    
    self.helper = [[AliyunDBHelper alloc] init];
    
    [self.helper openResourceDBSuccess:nil failure:nil];
    
    NSArray *filters = [self localFilters];
    if (filters.count > 0) {
        for (NSDictionary *dic in filters) {
            AliyunEffectResourceModel *resource = [[AliyunEffectResourceModel alloc] init];
            resource.effectType = [dic[@"effectType"] integerValue];
            resource.eid = [dic[@"eid"] integerValue];
            resource.icon = dic[@"icon"];
            resource.resourcePath = dic[@"resourcePath"];
            resource.name = dic[@"name"];
            [self.helper insertDataWithEffectResourceModel:resource];
        }
    }
    
    NSArray *animationFilters = [self localAnimationFilters];
    if (animationFilters.count > 0) {
        for (NSDictionary *dic in animationFilters) {
            AliyunEffectResourceModel *resource = [[AliyunEffectResourceModel alloc] init];
            resource.effectType = [dic[@"effectType"] integerValue];
            resource.eid = [dic[@"eid"] integerValue];
            resource.icon = dic[@"icon"];
            resource.resourcePath = dic[@"resourcePath"];
            resource.name = dic[@"name"];
            [self.helper insertDataWithEffectResourceModel:resource];
        }
    }
    
    AliyunEffectResourceModel *fontModel = [self localResourcesWithEffectType:1];
    if (fontModel) {
        [self.helper insertDataWithEffectResourceModel:fontModel];
    }
    
    AliyunEffectResourceModel *pasterModel = [self localResourcesWithEffectType:2];
    if (pasterModel) {
        [self.helper insertDataWithEffectResourceModel:pasterModel];
    }
    
    AliyunEffectResourceModel *captionModel = [self localResourcesWithEffectType:6];
    if (captionModel) {
        [self.helper insertDataWithEffectResourceModel:captionModel];
    }
    
    AliyunEffectResourceModel *mvModel = [self localResourcesWithEffectType:3];
    if (mvModel) {
        [self.helper insertDataWithEffectResourceModel:mvModel];
    }
    
    [self.helper closeDB];
}


- (NSArray *)localFilters {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LocalFilter"]) {
        return nil;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LocalFilter"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"LocalFilter" withExtension:@"json"];
    NSData *json = [NSData dataWithContentsOfURL:url];
    if (json) {
        NSError *err = nil;
        NSArray *filters = [NSJSONSerialization JSONObjectWithData:json
                                                           options:NSJSONReadingAllowFragments error:&err];
        return filters;
    }
    return nil;
}

- (NSArray *)localAnimationFilters {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LocalAnimationFilter"]) {
        return nil;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LocalAnimationFilter"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"LocalAnimationFilter" withExtension:@"json"];
    NSData *json = [NSData dataWithContentsOfURL:url];
    if (json) {
        NSError *err = nil;
        NSArray *filters = [NSJSONSerialization JSONObjectWithData:json
                                                           options:NSJSONReadingAllowFragments error:&err];
        return filters;
    }
    return nil;
}

/**
 加载本地数据 不包含滤镜
 
 @param type 加载资源类型 1: 字体 2: 动图 3:imv 5:音乐 6:字幕
 @return 加载的model
 */
- (AliyunEffectResourceModel *)localResourcesWithEffectType:(NSInteger)type {
    
    NSString *typeString = @"";
    switch (type) {
        case 1:
            typeString = @"LocalFont";
            break;
        case 2:
            typeString = @"LocalPaster";
            break;
        case 3:
            typeString = @"LocalMV";
            break;
        case 5:
            typeString = @"LocalMusic";
            break;
        case 6:
            typeString = @"LocalCaption";
            break;
        default:
            typeString = @"";
            break;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:typeString]) {
        return nil;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:typeString];
    NSURL *url = [[NSBundle mainBundle] URLForResource:typeString withExtension:@"json"];
    NSData *json = [NSData dataWithContentsOfURL:url];
    if (json) {
        NSError *err = nil;
        NSDictionary *modelDic = [NSJSONSerialization JSONObjectWithData:json
                                                                 options:NSJSONReadingAllowFragments error:&err];
        
        AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:modelDic error:nil];
        NSString *fileString = [[NSBundle mainBundle] pathForResource:model.resourcePath ofType:nil];
        NSString *toFileName = [NSString stringWithFormat:@"%ld-%@", model.eid, model.name];
        
        if (fileString && [[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
            
            NSURL *fileURL = [NSURL fileURLWithPath:fileString];
            NSURL *toURL = [NSURL fileURLWithPath:[[model storageFullPath] stringByAppendingPathComponent:toFileName]];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error;
                BOOL copyed = [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:toURL error:&error];
                
                NSLog(@"Errror:%@ copy:%d", error, copyed);
            });
            NSString *toPath = [[[model storageDirectory] stringByAppendingPathComponent:toFileName] stringByAppendingPathComponent:model.name];
            [model setValue:toPath forKey:@"resourcePath"];
        }
        return model;
    }
    return nil;
}


- (void)removeInitialDataWithType:(NSInteger)type {
    NSString *typeString = @"";
    switch (type) {
        case 1:
            typeString = @"LocalFont";
            break;
        case 2:
            typeString = @"LocalPaster";
            break;
        case 3:
            typeString = @"LocalMV";
            break;
        case 5:
            typeString = @"LocalMusic";
            break;
        case 6:
            typeString = @"LocalCaption";
            break;
        default:
            typeString = @"";
            break;
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:typeString];
}

@end
