//
//  AliyunIConfig.m
//  AliyunVideo
//
//  Created by mengt on 2017/4/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunIConfig.h"

static AliyunIConfig *uiConfig;

@implementation AliyunIConfig

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}

+ (AliyunIConfig *)config {
    
    return uiConfig;
}

+ (void)setConfig:(AliyunIConfig *)c {
    uiConfig = c;
}

- (NSString *)imageName:(NSString *)imageName {
    

    NSString *path = [NSString stringWithFormat:@"%@.bundle/%@",_imageBundleName,imageName];
    
    return path;
}

- (NSString *)filterPath:(NSString *)filterName {
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filterName];
    if (_filterBundleName) {
        path = [[[NSBundle mainBundle] pathForResource:_filterBundleName ofType:@"bundle"] stringByAppendingPathComponent:filterName];
    }
    return path;
}

@end
