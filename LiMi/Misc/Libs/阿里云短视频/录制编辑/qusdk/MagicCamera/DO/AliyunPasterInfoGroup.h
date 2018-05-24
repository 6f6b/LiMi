//
//  AliyunPasterInfoGroup.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "AliyunPasterInfo.h"

@interface AliyunPasterInfoGroup : JSONModel

@property (nonatomic, assign) NSInteger eid;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<AliyunPasterInfo> *pasterList;

@end
