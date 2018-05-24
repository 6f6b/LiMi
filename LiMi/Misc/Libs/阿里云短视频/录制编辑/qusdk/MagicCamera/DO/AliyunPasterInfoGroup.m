//
//  AliyunPasterInfoGroup.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterInfoGroup.h"

@implementation AliyunPasterInfoGroup

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"eid":@"id",
                                                                  @"desc":@"description"}];
}


@end
