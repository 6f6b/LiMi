//
//  AliyunEffectPasterList.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectPasterInfo.h"

@implementation AliyunEffectPasterInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"pid":@"id",}];
}

- (float)defaultDuration {    
    NSString *path = [self.resourcePath stringByAppendingPathComponent:@"config.json"];
    NSString *absPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSData *json = [NSData dataWithContentsOfFile:absPath];
    if (json) {
        NSError *err = nil;
        NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:json
                                                           options:NSJSONReadingAllowFragments error:&err];
        return [[jsonObj objectForKey:@"du"] floatValue];
    }

    
    return 0;
}

@end
