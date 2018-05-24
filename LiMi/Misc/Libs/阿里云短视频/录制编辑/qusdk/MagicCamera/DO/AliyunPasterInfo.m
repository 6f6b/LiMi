//
//  AliyunPasterInfo.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterInfo.h"
#import "AliyunPathManager.h"


@implementation AliyunPasterInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"eid":@"id"}];
}

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.eid = [[dict objectForKey:@"id"] integerValue];
        self.icon = [dict objectForKey:@"icon"];
        self.name = [dict objectForKey:@"name"];
        self.url = [dict objectForKey:@"url"];
        self.md5 = [dict objectForKey:@"md5"];
        self.preview = [dict objectForKey:@"preview"];
        self.type = [[dict objectForKey:@"type"] integerValue];
    }
    return self;
}

- (id)initWithBundleFile:(NSString *)path
{
    if (self = [super init]) {
        NSString *lastComponent = [path lastPathComponent];
        NSArray *comp = [lastComponent componentsSeparatedByString:@"-"];
        self.name = [comp firstObject];
        self.eid = [[comp lastObject] integerValue];
        self.icon = [path stringByAppendingPathComponent:@"icon.png"];
        self.type = 2;
        self.bundlePath = path;
    }
    return self;
}

- (NSString *)directoryPath
{
    NSString *name = [NSString stringWithFormat:@"%@-%ld", self.groupName, (long)self.groupId];
    NSString *path = [[[AliyunPathManager createResourceDir] stringByAppendingPathComponent:@"facepaster"] stringByAppendingPathComponent:name];
    return path;
}

- (NSString *)filePath
{
    NSString *name = [NSString stringWithFormat:@"%@-%ld", self.name, (long)self.eid];
    NSString *path = [[self directoryPath] stringByAppendingPathComponent:name];
    return path;
}

- (BOOL)fileExist
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[self filePath]]){
        return YES;
    }
    return NO;
}

@end
