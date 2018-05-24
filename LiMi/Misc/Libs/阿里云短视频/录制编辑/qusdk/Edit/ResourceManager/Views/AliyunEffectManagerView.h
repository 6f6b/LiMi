//
//  AliyunEffectManagerView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *EffectManagerTableViewIndentifier = @"EffectManagerTableViewIndentifier";

@protocol AliyunEffectManagerViewDelegate <NSObject>

- (void)segmentClickChangedWithIndex:(NSInteger)currentIndex title:(NSString *)currentTitle;

- (void)onClickBackButton;

@end

@interface AliyunEffectManagerView : UIView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<AliyunEffectManagerViewDelegate> delegate;


/**
 init

 @param type 初始选中的类别 0: 字体 1: 动图 2:imv 3:音乐 4:字幕
 @return AliyunEffectManagerView
 */
- (instancetype)initWithSelectSegmentType:(NSInteger)type
                                    frame:(CGRect)frame;


- (void)setTableViewDelegates:(id<UITableViewDelegate, UITableViewDataSource>)delegate;

@end
