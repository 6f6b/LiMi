//
//  AliyunEffectFilterInfo.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFilterInfo.h"

@implementation AliyunEffectFilterInfo

- (NSString *)localFilterIconPath {
    NSString *bundle = [[NSBundle mainBundle] bundlePath];
    if (self.eid == -1) {
        // 原片
        NSString *imagePath = [[AliyunIConfig config] imageName:@"origin_filter_icon"];
        return [bundle stringByAppendingPathComponent:imagePath];
    }
    if (self.iconPath) {
        return [bundle stringByAppendingPathComponent:self.iconPath];
    }
    
    NSString *string = [NSString stringWithFormat:@"%@/%@",self.resourcePath, self.icon];
    NSString *imagePath = [bundle stringByAppendingPathComponent:string];
    self.iconPath = string;
    return imagePath;
}

- (NSString *)localFilterResourcePath {
    if ([self.name isEqualToString:@"原片"]) {
        return nil;
    }
    NSString *bundle = [[NSBundle mainBundle] bundlePath];
    NSString *str = [bundle stringByAppendingPathComponent:self.resourcePath];
    return str;
}

@end
