//
//  AliyunCompositionPickView.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunCompositionInfo.h"

@protocol AliyunCompositionPickViewDelegate <NSObject>

- (void)pickViewDidFinishWithAssets:(NSArray<AliyunCompositionInfo *> *)assets duration:(CGFloat)duration;
- (void)pickViewDidSelectCompositionInfo:(AliyunCompositionInfo *)info;

@end

@interface AliyunCompositionPickView : UIView
@property (nonatomic, weak) id<AliyunCompositionPickViewDelegate> delegate;
- (void)addCompositionInfo:(AliyunCompositionInfo *)info;
- (NSArray *)getPickedAssets;
- (void)refresh;
@end
