//
//  AliyunPasterInfo.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol AliyunPasterInfo;

@interface AliyunPasterInfo : JSONModel

@property (nonatomic, assign) NSInteger eid;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *bundlePath;

- (id)initWithDict:(NSDictionary *)dict;

- (id)initWithBundleFile:(NSString *)path;

- (NSString *)directoryPath;

- (NSString *)filePath;

- (BOOL)fileExist;

@end
