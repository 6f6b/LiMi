//
//  AliyunCompositionPickCell.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AliyunCompositionPickCell;

@protocol AliyunCompositionPickCellDelegate <NSObject>
- (void)pickCellWillClose:(AliyunCompositionPickCell *)cell;
@end

@interface AliyunCompositionPickCell : UICollectionViewCell
@property (nonatomic, weak) id<AliyunCompositionPickCellDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *labelDuration;
@property (nonatomic, strong) UIButton *closeButton;
@end
