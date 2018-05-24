//
//  AliyunEditButtonsView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

//素材类别 1: 字体 2: 动图 3:imv 4:滤镜 5:音乐 6:字幕 7:动效滤镜
typedef NS_ENUM(NSInteger, AliyunEditButtonType) {
    AliyunEditButtonTypeFont      = 1,
    AliyunEditButtonTypePaster    = 2,
    AliyunEditButtonTypeMV        = 3,
    AliyunEditButtonTypeFilter    = 4,
    AliyunEditButtonTypeMusic     = 5,
};

@protocol AliyunEditButtonsViewDelegate <NSObject>
- (void)filterButtonClicked:(AliyunEditButtonType)type;
- (void)mvButtonClicked:(AliyunEditButtonType)type;
- (void)pasterButtonClicked;
- (void)subtitleButtonClicked;
- (void)musicButtonClicked;
- (void)paintButtonClicked;

- (void)animationFilterButtonClicked;
- (void)filterButtonClicked;
@end



@interface AliyunEditButtonsView : UIView

@property (nonatomic, weak) id<AliyunEditButtonsViewDelegate> delegate;

@end



