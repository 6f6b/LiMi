//
//  AliyunEffectManagerViewController.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectResourceModel.h"

@protocol AliyunEffectManagerViewControllerDelegate <NSObject>

- (void)deleteResourceWithModel:(AliyunEffectResourceModel *)model;

@end

@interface AliyunEffectManagerViewController : UIViewController

@property (nonatomic, weak) id<AliyunEffectManagerViewControllerDelegate> delegate;

// 管理的素材类别（初始类别）
- (instancetype)initWithManagerType:(AliyunEffectType)type;

@end
