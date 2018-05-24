//
//  AliyunEffectFilterCell.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFilterCell.h"
#import "UIImageView+WebCache.h"

@interface AliyunEffectFilterCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *MvDecorateImage;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (nonatomic, assign) NSInteger eid;
@end

@implementation AliyunEffectFilterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imageView.layer.cornerRadius = 25;
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
    
}

- (void)cellModel:(AliyunEffectInfo *)effectInfo {
    
    _nameLabel.text = effectInfo.name;
    _eid = effectInfo.eid;
    if (effectInfo.effectType == 4 || effectInfo.effectType == 7) {
        _MvDecorateImage.hidden = YES;
        _imageView.image = [UIImage imageWithContentsOfFile:[effectInfo localFilterIconPath]];

    } else if (effectInfo.effectType == 3) {
        if (effectInfo.eid == -1) {
            _MvDecorateImage.hidden = YES;
            _imageView.image = [UIImage imageNamed:effectInfo.icon];
        } else {
            _MvDecorateImage.hidden = NO;
            _MvDecorateImage.image  = [AliyunImage imageNamed:@"MV_decorate"];
            NSURL *url = [NSURL URLWithString:[effectInfo.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [_imageView sd_setImageWithURL:url];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (_eid != -1) {
        [_coverImage setHidden:!selected];
        //_imageView.layer.borderWidth = selected ? 2 : 0;
    }
}

@end
