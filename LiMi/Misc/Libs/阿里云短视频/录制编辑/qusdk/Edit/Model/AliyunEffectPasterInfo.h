//
//  AliyunEffectPasterList.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "JSONModel.h"

@protocol AliyunEffectPasterInfo
@end

@interface AliyunEffectPasterInfo : JSONModel

@property (nonatomic, copy) NSString *resourcePath; // 资源路径
@property (nonatomic ,copy) NSString *configFontName;
@property (nonatomic, strong) NSNumber *configFontId;

@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, copy) NSString *fontId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *priority;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *type;

- (float)defaultDuration;

@end
