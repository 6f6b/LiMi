//
//  QUPackageCollectionViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunEffectPasterGroup.h"
#import "UIImageView+WebCache.h"

@implementation AliyunPasterGroupCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    [self setupSubViews];
    return self;
}

- (void)setupSubViews {
    
    self.iconImageView = [[UIImageView alloc] init];
    
    self.iconImageView.frame = CGRectMake(SizeWidth(10), SizeWidth(4), SizeWidth(32), SizeWidth(32));
    self.iconImageView.layer.cornerRadius = SizeWidth(16);
    self.iconImageView.layer.masksToBounds = YES;

    [self.contentView addSubview:self.iconImageView];
}

- (void)setGroup:(AliyunEffectPasterGroup *)group {
    
    _group = group;
    NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:[[group.pasterList firstObject] resourcePath]] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[group.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageWithContentsOfFile:iconPath]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (!_group) {
        return;
    }
    
    self.iconImageView.layer.borderWidth = selected ? 1 : 0;
    self.iconImageView.backgroundColor = selected ? rgba(240, 243, 255, 1) :  [UIColor clearColor];
}

@end
