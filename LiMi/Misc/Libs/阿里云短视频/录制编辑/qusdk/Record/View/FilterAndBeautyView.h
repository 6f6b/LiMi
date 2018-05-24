//
//  FilterAndBeautyView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/22.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectMvGroup.h"
#import "AliyunEffectFilterView.h"

typedef enum : NSUInteger {
    FilterAndBeautyViewTypeDefault,
    FilterAndBeautyViewTypeOnlyFilter
} FilterAndBeautyViewType;


@interface FilterAndBeautyView : UIView
    @property (nonatomic, assign) id<AliyunEffectFilter2ViewDelegate> delegate;
    
    @property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

- (void)showOnlyWithType:(FilterAndBeautyViewType)type;
- (void)show;
- (void)dismiss;
@end
