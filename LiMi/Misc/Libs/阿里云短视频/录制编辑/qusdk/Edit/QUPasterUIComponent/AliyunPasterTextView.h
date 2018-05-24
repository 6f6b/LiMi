//
//  AliyunPasterTextView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <AliyunVideoSDKPro/AliyunPasterBaseView.h>


@interface AliyunPasterTextView : AliyunPasterBaseView

/**
 文字
 */
@property (nonatomic, copy) NSString *text;

/**
 字体名称
 */
@property (nonatomic, copy) NSString *fontName;

/**
 是否描边
 */
@property (nonatomic, assign) BOOL isStroke;

/**
 文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;


- (UIImage *)captureImage:(CGSize)nativeSize outputSize:(CGSize)outputSize;

@end
