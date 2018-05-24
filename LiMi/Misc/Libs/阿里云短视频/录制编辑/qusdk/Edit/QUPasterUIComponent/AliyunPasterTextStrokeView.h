//
//  AliyunPasterTextStrokeView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunPasterTextStrokeView : UITextView

@property (nonatomic, strong) UIColor *mTextColor;
@property (nonatomic, strong) UIColor *mTextStrokeColor;
@property (nonatomic, copy) NSString *mfontName;
@property (nonatomic, assign) CGFloat mfontSize;
@property (nonatomic, assign) BOOL isStroke;

@end
