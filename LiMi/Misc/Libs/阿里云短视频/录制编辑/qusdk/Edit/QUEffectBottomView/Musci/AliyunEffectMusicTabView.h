//
//  AliyunEffectMusicTabView.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunEffectMusicTabViewDelegate <NSObject>

- (void)tabViewDidSelectTab:(NSInteger)tab;

@end

@interface AliyunEffectMusicTabView : UIView
@property (nonatomic, weak) id<AliyunEffectMusicTabViewDelegate> delegate;
@end
