//
//  AliyunFontItemView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunEffectFontInfo;

@protocol AliyunFontItemViewDelegate <NSObject>

- (void)onSelectFontWithFontInfo:(AliyunEffectFontInfo *)fontInfo;

@end

@interface AliyunFontItemView : UIView

@property (nonatomic, assign) id<AliyunFontItemViewDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *fontItems;

@end
