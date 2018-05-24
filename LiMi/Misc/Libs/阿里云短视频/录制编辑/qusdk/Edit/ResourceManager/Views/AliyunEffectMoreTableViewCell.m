//
//  EffectMoreTableViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMoreTableViewCell.h"
#import "AliyunEffectResourceModel.h"
#import "UIImageView+WebCache.h"
#import "AliyunDownloadCycleView.h"
#import "UIButton+EnlargeArea.h"

@implementation AliyunEffectMoreTableViewCell

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    self.contentView.backgroundColor = RGBToColor(35, 42, 66);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.showImageView = [[UIImageView alloc] init];
    self.showImageView.frame = CGRectMake(SizeWidth(10), SizeWidth(10), SizeWidth(54), SizeWidth(54));
    [self.contentView addSubview:self.showImageView];
    
    
    self.funcButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.funcButton.frame = CGRectMake(SizeWidth(266), SizeWidth(27), SizeWidth(44), SizeWidth(20));
    [self.funcButton addTarget:self action:@selector(funcButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.funcButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    self.funcButton.layer.masksToBounds = YES;
    self.funcButton.layer.cornerRadius = self.funcButton.frame.size.height / 2;
    [self.contentView addSubview:self.funcButton];
    [self.funcButton setDefaultEnlargeEdge];
    
    
    self.cycleView = [[AliyunDownloadCycleView alloc] initWithFrame:CGRectMake(0, 0, SizeWidth(20), SizeWidth(20))];
    self.cycleView.center = self.funcButton.center;
    self.cycleView.progressBackgroundColor = RGBToColor(239, 75, 129);
    self.cycleView.lineWidth = 2.f;
    self.cycleView.progressColor = [UIColor greenColor];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.showImageView.frame) + SizeWidth(10), CGRectGetMidX(self.showImageView.frame) - SizeWidth(20), CGRectGetMinX(self.funcButton.frame) - CGRectGetMaxX(self.showImageView.frame) - SizeWidth(20), SizeWidth(20));
    self.nameLabel.font = [UIFont systemFontOfSize:14.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.nameLabel];
    
    
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.nameLabel.frame), CGRectGetHeight(self.nameLabel.frame));
    self.descLabel.font = [UIFont systemFontOfSize:10.f];
    self.descLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.descLabel];

}

- (void)setButtontType:(EffectTableViewButtonType)buttontType {
    
    _buttontType = buttontType;
    self.funcButton.userInteractionEnabled = YES;
    if (buttontType == EffectTableViewButtonUse) {
        
        self.funcButton.backgroundColor = RGBToColor(113, 186, 98);
        [self.funcButton setTitle:@"使用" forState:(UIControlStateNormal)];
    } else if (buttontType == EffectTableViewButtonDownload){
        
        self.funcButton.backgroundColor = RGBToColor(239, 75, 129);
        [self.funcButton setTitle:@"下载" forState:(UIControlStateNormal)];
    } else {
        
        self.funcButton.backgroundColor = RGBToColor(41, 50, 77);
        [self.funcButton setTitle:@"删除" forState:(UIControlStateNormal)];
    }
}

- (void)setEffectResourceModel:(AliyunEffectResourceModel *)model {
    
    self.nameLabel.text = model.name;
    self.descLabel.text = model.edescription;
    [self setButtontType:model.isDBContain];
    [self.showImageView sd_setImageWithURL:[NSURL URLWithString:[model.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}


- (void)updateDownlaodProgress:(CGFloat)progress {
    
    
    if (progress >= 1) {
        // 下载完毕
        [self.cycleView removeFromSuperview];
        [self setButtontType:(EffectTableViewButtonUse)];
    } else {
        self.funcButton.userInteractionEnabled = NO;
        [self addSubview:self.cycleView];
        self.cycleView.percentage = progress;
        [self.funcButton setTitle:@"" forState:(UIControlStateNormal)];
    }
    
}

- (void)updateDownloadFaliure {

    [self.cycleView removeFromSuperview];
    [self setButtontType:(EffectTableViewButtonDownload)];

}

- (void)funcButtonAction:(UIButton *)sender {
    
    [self.delegate onClickFuncButtonWithCell:self];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.backgroundColor = [UIColor yellowColor];
    } else {
        
    }
}

@end
