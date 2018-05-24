//
//  QUPasterSelectView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunEffectPasterInfo;
@class AliyunEffectPasterGroup;


@protocol AliyunPasterShowViewDelegate <NSObject>

- (void)onClickPasterWithPasterModel:(AliyunEffectPasterInfo *)pasterInfo;

- (void)onClickRemovePaster;

- (void)onClickMorePaster;

- (void)onClickPasterDone;

@end

@interface AliyunPasterShowView : UIView

@property (nonatomic, assign) id<AliyunPasterShowViewDelegate> delegate;


- (void)fetchPasterGroupDataWithCurrentShowGroup:(AliyunEffectPasterGroup *)group;

@end
