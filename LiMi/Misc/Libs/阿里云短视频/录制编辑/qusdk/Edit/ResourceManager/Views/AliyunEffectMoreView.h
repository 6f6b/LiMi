//
//  AliyunEffectMoreView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *EffectMoreTableViewIndentifier = @"EffectMoreTableViewIndentifier";
static NSString *EffectMorePreviewTableViewIndentifier = @"EffectMorePreviewTableViewIndentifier";

@protocol AliyunEffectMoreViewDelegate <NSObject>

- (void)onClickBackButton;

- (void)onClickNextButton;

@end


@interface AliyunEffectMoreView : UIView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<AliyunEffectMoreViewDelegate> delegate;

- (void)setTableViewDelegates:(id<UITableViewDelegate, UITableViewDataSource>)delegate;


//素材类别 参考EffectMoreController的AliyunEffectType注释
- (void)setTitleWithEffectType:(NSInteger)type;


@end
