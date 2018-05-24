//
//  AliyunEffectFilterView.h
//  qusdk
//
//  Created by Vienta on 2018/1/12.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectMvGroup.h"

@protocol AliyunEffectFilter2ViewDelegate <NSObject>

- (void)cancelButtonClick;

- (void)animtionFilterButtonClick;

- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;

- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup;

- (void)didSelectEffectMoreMv;

- (void)didBeganLongPressEffectFilter:(AliyunEffectFilterInfo *)animtinoFilter;

- (void)didEndLongPress;

- (void)didRevokeButtonClick;

- (void)didTouchingProgress;

- (void)beautyValueChangedWith:(float)value;
@end

@interface AliyunEffectFilterView : UIView

@property (nonatomic, assign) id<AliyunEffectFilter2ViewDelegate> delegate;

@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

- (void)reloadDataWithEffectType:(NSInteger)eType;

@end
