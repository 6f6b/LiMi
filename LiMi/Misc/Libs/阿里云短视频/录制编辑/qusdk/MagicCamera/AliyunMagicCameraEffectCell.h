//
//  MagicCameraEffectCell.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunMagicCameraEffectCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *downloadImageView;

- (void)borderHidden:(BOOL)isHidden;
- (void)shouldDownload:(BOOL)flag;

- (void)downloadProgress:(CGFloat)progress;

@end
