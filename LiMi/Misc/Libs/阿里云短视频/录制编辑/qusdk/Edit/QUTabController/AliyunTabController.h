//
//  AliyunTabController.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AliyunColor.h"


@protocol AliyunTabControllerDelegate <NSObject>

- (void)completeButtonClicked;

- (void)keyboardShouldHidden;

- (void)keyboardShouldAppear;

- (void)textColorChanged:(AliyunColor *)color;

- (void)textFontChanged:(NSString *)fontName;

@end

@interface AliyunTabController : NSObject

@property (nonatomic, weak) id<AliyunTabControllerDelegate> delegate;

- (void)presentTabContainerViewInSuperView:(UIView *)superView height:(CGFloat)height duration:(CGFloat)duration;

- (void)dismissPresentTabContainerView;

@end

