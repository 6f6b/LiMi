//
//  AliyunFontItemCell.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunFontItemCell.h"
#import "AliyunEffectFontInfo.h"

@implementation AliyunFontItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = SizeWidth(30);
    // Initialization code
}

- (void)setWithFontModel:(AliyunEffectFontInfo *)info {
    
    NSString *iconPath = [[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon.png"];
    self.iconImageView.image = [UIImage imageWithContentsOfFile:iconPath];
    if (info.eid == -2) {
        // 系统字体
        self.iconImageView.image = [AliyunImage imageNamed:@"system_font_icon"];
    }
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
