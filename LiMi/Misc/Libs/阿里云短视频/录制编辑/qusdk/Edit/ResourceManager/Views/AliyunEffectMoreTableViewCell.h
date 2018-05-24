//
//  EffectMoreTableViewCell.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AliyunDownloadCycleView;

@class AliyunEffectResourceModel;

typedef NS_ENUM(NSInteger, EffectTableViewButtonType){
    EffectTableViewButtonDownload = 0,
    EffectTableViewButtonUse,
    EffectTableViewButtonDelete,
};

@protocol AliyunEffectMoreTableViewCellDelegate;

@interface AliyunEffectMoreTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *funcButton;
@property (nonatomic, strong) AliyunDownloadCycleView *cycleView;

@property (nonatomic, assign) EffectTableViewButtonType buttontType;
@property (nonatomic, weak) id<AliyunEffectMoreTableViewCellDelegate> delegate;

- (void)setEffectResourceModel:(AliyunEffectResourceModel *)model;

// 更新下载进度条
- (void)updateDownlaodProgress:(CGFloat)progress;

// 下载失败
- (void)updateDownloadFaliure;

@end


@protocol AliyunEffectMoreTableViewCellDelegate <NSObject>

- (void)onClickFuncButtonWithCell:(AliyunEffectMoreTableViewCell *)cell;

@end
