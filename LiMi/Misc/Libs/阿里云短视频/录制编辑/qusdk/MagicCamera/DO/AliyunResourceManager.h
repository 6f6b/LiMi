//
//  AliyunResourceManager.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/23.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunPasterInfoGroup.h"

typedef NS_ENUM(NSUInteger, AliyunResourceType) {
    AliyunResourceTypeFacePaster,
};

@interface AliyunResourceManager : NSObject

+ (NSString *)pathWithType:(AliyunResourceType)type;

- (NSArray *)loadLocalFacePasters;

@end
