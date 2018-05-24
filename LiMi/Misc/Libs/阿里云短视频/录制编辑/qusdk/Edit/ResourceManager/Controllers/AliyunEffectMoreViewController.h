//
//  AliyunEffectMoreViewController.h.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectResourceModel.h"

@class AliyunEffectInfo;


typedef void(^AliyunEffectMoreViewControlBack)(AliyunEffectInfo *selectEffect);

@interface AliyunEffectMoreViewController : UIViewController

// 回调
@property (nonatomic, copy) AliyunEffectMoreViewControlBack effectMoreCallback;

// 需要获取的资源类型 (字幕 动图 MV等)
- (instancetype)initWithEffectType:(AliyunEffectType)type;

@end
