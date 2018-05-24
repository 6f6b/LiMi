//
//  AliyunEffectAspectListModel.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "JSONModel.h"

@protocol AliyunEffectMvInfo
@end

@interface AliyunEffectMvInfo : JSONModel

@property (nonatomic, copy) NSString *resourcePath; //  资源路径

/* aspect类型
 * 1.  1:1
 * 2.  4:3
 * 3.  16:9
 */
@property (nonatomic, copy) NSString *aspect;
@property (nonatomic, copy) NSString *download;
@property (nonatomic, copy) NSString *md5;

@end
