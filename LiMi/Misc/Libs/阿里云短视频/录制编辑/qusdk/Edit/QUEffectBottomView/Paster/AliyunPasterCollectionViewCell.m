//
//  AliyunPasterCollectionFlowLayout.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterCollectionViewCell.h"

@implementation AliyunPasterCollectionViewCell

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
    [self.contentView addSubview:self.showImageView];
}

@end
