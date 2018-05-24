//
//  AliyunEffectFilterView.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectMvGroup.h"

@protocol AliyunEffectFilterViewDelegate <NSObject>

- (void)cancelButtonClick;

- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;

- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup;

- (void)didSelectEffectMoreMv;

@end

@interface AliyunEffectMVView : UIView


@property (nonatomic, assign) id<AliyunEffectFilterViewDelegate> delegate;

@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;
@property (nonatomic, assign) BOOL frontMV;

- (void)reloadDataWithEffectType:(NSInteger)eType;
@end
