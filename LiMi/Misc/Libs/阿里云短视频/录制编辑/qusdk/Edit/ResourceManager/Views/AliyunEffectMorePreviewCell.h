//
//  AliyunEffectMorePreviewCell.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/22.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunEffectResourceModel, AliyunEffectMorePreviewCell;

@protocol AliyunEffectMorePreviewCellDelegate <NSObject>

- (void)onClickPreviewCell:(AliyunEffectMorePreviewCell *)cell;

@end

@interface AliyunEffectMorePreviewCell : UITableViewCell

@property (nonatomic, assign) id<AliyunEffectMorePreviewCellDelegate> delegate;

- (void)setEffectModel:(AliyunEffectResourceModel *)model;

- (void)startPreview;

- (void)stopPreview;

@end
