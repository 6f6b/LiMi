//
//  AliyunCaptionCollectionViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/17.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCaptionCollectionViewCell.h"

@implementation AliyunCaptionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    [self setupSubViews];
    return self;
}

- (void)setupSubViews {
    
    self.showImageView = [[UIImageView alloc] init];
    self.showImageView.frame = CGRectMake(SizeWidth(10), SizeWidth(10), SizeWidth(50), SizeWidth(50));
    self.showImageView.layer.masksToBounds = YES;
    self.showImageView.layer.cornerRadius = self.showImageView.frame.size.height / 2;
    self.showImageView.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
    [self.contentView addSubview:self.showImageView];
}


- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
//    self.showImageView.layer.borderWidth = selected ? 1 : 0;
}

@end
