//
//  AliyunAlbumTableViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunAlbumTableViewCell.h"
#import "AliyunAlbumModel.h"
#import "AliyunPhotoLibraryManager.h"

@interface AliyunAlbumTableViewCell ()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *albumNameLabel;
@property (strong, nonatomic) UIImageView *indicatorImageView;

@end

@implementation AliyunAlbumTableViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.frame = CGRectMake(10, 10, 54, 54);
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.iconImageView];

    self.albumNameLabel = [[UILabel alloc] init];
    self.albumNameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 10, CGRectGetMidY(self.iconImageView.frame) - 13 / 2, 150, 13);
    self.albumNameLabel.font = [UIFont systemFontOfSize:14.f];
    self.albumNameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.albumNameLabel];
    
    self.indicatorImageView = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"roll_more"]];
    self.indicatorImageView.frame = CGRectMake(ScreenWidth - 15 - 13, CGRectGetMidY(self.iconImageView.frame) - 13 / 2, 13, 13);
    [self.contentView addSubview:self.indicatorImageView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setAlbumModel:(AliyunAlbumModel *)albumModel {
    _albumNameLabel.text = [NSString stringWithFormat:@"%@ (%zd)",albumModel.albumName,albumModel.assetsCount];
    [[AliyunPhotoLibraryManager sharedManager] getPostImageWithAlbumModel:albumModel completion:^(UIImage *postImage) {
        _iconImageView.image = postImage;
    }];
}


@end
