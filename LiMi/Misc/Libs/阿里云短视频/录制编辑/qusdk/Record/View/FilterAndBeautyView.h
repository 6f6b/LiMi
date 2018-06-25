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

@protocol FilterAndBeautyViewDelegate <NSObject>
@required
- (void)filterAndBeautyViewSelectedFilterIndex:(int)index;
- (void)filterAndBeautyViewSeletedBeautifyValue:(CGFloat)value;
@end

@interface FilterAndBeautyView : UIView
    @property (nonatomic, assign) id<FilterAndBeautyViewDelegate> delegate;
    
    @property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

- (void)showOnlyWithType:(FilterAndBeautyViewType)type;
- (void)showWithSelectedFilterIndex:(int)index filterDataArray:(NSMutableArray *)filterDataArray;
- (void)dismiss;
@end
