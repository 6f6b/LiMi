//
//  AliyunEffectCaptionShowView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunEffectPasterInfo;
@class AliyunEffectFontInfo;
@class AliyunEffectCaptionGroup;

@protocol AliyunEffectCaptionShowViewDelegate <NSObject>

- (void)onClickCaptionWithPasterModel:(AliyunEffectPasterInfo *)pasterInfo;

- (void)onClickFontWithFontInfo:(AliyunEffectFontInfo *)font;

- (void)onClickRemoveCaption;

- (void)onClickMoreCaption;

- (void)onClickCaptionDone;

@end

@interface AliyunEffectCaptionShowView : UIView

@property (nonatomic, assign) id<AliyunEffectCaptionShowViewDelegate> delegate;

- (void)fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup *)group;

@end
