//
//  AnimationFilterView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/23.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectFilterView.h"

@interface AnimationFilterView : UIView
@property (nonatomic, assign) id<AliyunEffectFilter2ViewDelegate> delegate;

@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

@end
