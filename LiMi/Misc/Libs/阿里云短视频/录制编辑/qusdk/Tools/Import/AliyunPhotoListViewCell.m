//
//  AliyunPhotoListViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPhotoListViewCell.h"
#import "AliyunPhotoLibraryManager.h"

@interface AliyunPhotoListViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *durationLabel;

@end

@implementation AliyunPhotoListViewCell


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {

    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = self.contentView.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.frame = CGRectMake(0, CGRectGetHeight(self.contentView.frame) - 10, CGRectGetWidth(self.contentView.frame), 10);
    self.durationLabel.font = [UIFont systemFontOfSize:12.f];
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    self.durationLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.durationLabel];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setAssetModel:(AliyunAssetModel *)assetModel {
    if (assetModel.type == AliyunAssetModelMediaTypeToRecod) {
        _imageView.image = assetModel.thumbnailImage;
        _durationLabel.hidden = YES;
    
        return;
    }
    
    if (assetModel.type == 0) {
        _durationLabel.hidden = YES;
    }else {
        _durationLabel.hidden = NO;
    }
    
    if (assetModel.timeLength.length > 0) {
        _durationLabel.text = assetModel.timeLength;
    }
    
    [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:assetModel.asset thumbnailImage:YES photoWidth:200 completion:^(UIImage *photo, NSDictionary *info) {
        _imageView.image = photo;

    }];
}

@end

