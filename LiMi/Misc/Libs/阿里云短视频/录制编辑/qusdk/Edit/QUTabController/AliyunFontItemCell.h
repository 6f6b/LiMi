//
//  AliyunFontItemCell.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunEffectFontInfo;

@interface AliyunFontItemCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (void)setWithFontModel:(AliyunEffectFontInfo *)info;

@end
