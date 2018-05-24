//
//  AliyunColorItemView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunColor.h"

@protocol AliyunColorItemViewDelegate <NSObject>

- (void)textColorChanged:(AliyunColor *)color;

- (void)textFontChanged:(NSString *)fontName;

@end

@interface AliyunColorItemView : UIView

@property (nonatomic, weak) id <AliyunColorItemViewDelegate> delegate;

@end
