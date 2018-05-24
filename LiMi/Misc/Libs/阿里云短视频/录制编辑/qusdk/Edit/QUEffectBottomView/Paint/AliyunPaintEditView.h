//
//  AliyunPaintEditView.h
//  qusdk
//
//  Created by TripleL on 17/6/6.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunPaintEditViewDelegate <NSObject>

- (void)onClickPaintFinishButtonWithImagePath:(NSString *)path;

- (void)onClickPaintCancelButton;

@end

@interface AliyunPaintEditView : UIView

@property (nonatomic, weak) id<AliyunPaintEditViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                     drawRect:(CGRect)drawRect;


/**
 更新画图区域
 */
- (void)updateDrawRect:(CGRect)drawRect;

@end
