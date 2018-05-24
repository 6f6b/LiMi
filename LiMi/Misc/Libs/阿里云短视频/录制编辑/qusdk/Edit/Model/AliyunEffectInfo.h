//
//  AliyunEffectInfo.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface AliyunEffectInfo : JSONModel

@property (nonatomic, assign) NSInteger eid;
@property (nonatomic, assign) NSInteger effectType;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *edescription;
@property (nonatomic, assign) BOOL isDBContain;

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *resourcePath;

- (NSString *)localFilterIconPath;
- (NSString *)localFilterResourcePath;

@end
