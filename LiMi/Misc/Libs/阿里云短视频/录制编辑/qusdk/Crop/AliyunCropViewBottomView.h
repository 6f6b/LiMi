//
//  AliyunCropViewBottomView.h
//  AliyunVideo
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunCropViewBottomViewDelegate <NSObject>

- (void)onClickBackButton;
- (void)onClickRatioButton;
- (void)onClickCropButton;

@end

@interface AliyunCropViewBottomView : UIView
@property (nonatomic, strong) UIButton *ratioButton;
@property (nonatomic, strong) UIButton *cropButton;
@property (nonatomic, weak) id<AliyunCropViewBottomViewDelegate> delegate;

@end
