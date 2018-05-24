//
//  AliyunEffectMusicCell.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMusicCell.h"
#import "AliyunDownloadCycleView.h"
typedef NS_ENUM(NSInteger, AliyunEffectMusicState) {
    AliyunEffectMusicStateRemote,
    AliyunEffectMusicStateLocal,
    AliyunEffectMusicStateDownloading,
    AliyunEffectMusicStateNone,
};

@interface AliyunEffectMusicCell ()
@property (nonatomic, strong) UIImageView *imageViewSelect;
@property (nonatomic, strong) UIImageView *imageViewHeader;
@property (nonatomic, strong) UILabel *labelSelect;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIButton *buttonDown;
@property (nonatomic, strong) AliyunDownloadCycleView *cycleView;
@end

@implementation AliyunEffectMusicCell

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
    self.imageViewSelect = [[UIImageView alloc] init];
    self.imageViewSelect.frame = CGRectMake(SizeWidth(12), 0, SizeWidth(16), SizeWidth(16));
    self.imageViewSelect.center = CGPointMake(self.imageViewSelect.center.x, self.contentView.center.y);
    [self.contentView addSubview:self.imageViewSelect];
    
    self.imageViewHeader = [[UIImageView alloc] init];
    self.imageViewHeader.backgroundColor = RGBToColor(239, 75, 129);
    self.imageViewHeader.frame = CGRectMake(SizeWidth(17), 0, SizeWidth(6), SizeWidth(6));
    self.imageViewHeader.center = CGPointMake(self.imageViewHeader.center.x, self.contentView.center.y);
    self.imageViewHeader.layer.masksToBounds = YES;
    self.imageViewHeader.layer.cornerRadius = self.imageViewHeader.frame.size.height / 2;
    [self.contentView addSubview:self.imageViewHeader];
    
    
    self.labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelTitle.text = NSLocalizedString(@"original_music_edit", nil);
    
    self.labelTitle.font = [UIFont systemFontOfSize:14];
    self.labelTitle.contentMode = UIViewContentModeCenter;
    self.labelTitle.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.labelTitle];
    
    self.buttonDown = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, 48)];
    [self.buttonDown.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.buttonDown setTitleColor:rgba(110,118,139,1) forState:UIControlStateNormal];
    [self.buttonDown setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.buttonDown addTarget:self action:@selector(downClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.buttonDown];
    
    self.cycleView = [[AliyunDownloadCycleView alloc] initWithFrame:CGRectMake(0, 0, SizeWidth(20), SizeWidth(20))];
    self.cycleView.center = self.buttonDown.center;
    self.cycleView.progressBackgroundColor = RGBToColor(239, 75, 129);
    self.cycleView.lineWidth = 2.f;
    self.cycleView.progressColor = [UIColor greenColor];
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.imageViewSelect.frame = CGRectMake(SizeWidth(12), 0, SizeWidth(16), SizeWidth(16));
    self.imageViewSelect.center = CGPointMake(self.imageViewSelect.center.x, self.contentView.center.y);
    self.imageViewHeader.frame = CGRectMake(SizeWidth(17), 0, SizeWidth(6), SizeWidth(6));
    self.imageViewHeader.center = CGPointMake(self.imageViewHeader.center.x, self.contentView.center.y);
    self.labelTitle.frame = CGRectMake(height, 0, width-2*height-8, height);
    self.buttonDown.frame = CGRectMake(width-height, 0, height, height);
    self.cycleView.center = self.buttonDown.center;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (!self.musicInfo.isDBContain) {
        return;
    }
    if (selected) {
        self.imageViewSelect.image = [AliyunImage imageNamed:@"edit_music_select"];
        self.imageViewHeader.backgroundColor = [UIColor clearColor];
    } else {
        self.imageViewSelect.image = nil;
        self.imageViewHeader.backgroundColor = RGBToColor(239, 75, 129);
    }
}


- (void)updateWithState:(AliyunEffectMusicState)state {
    if (state == AliyunEffectMusicStateRemote) {
        [self.buttonDown setTitle:nil forState:UIControlStateNormal];
        [self.buttonDown setImage:[AliyunImage imageNamed:@"edit_music_download"] forState:(UIControlStateNormal)];
        self.buttonDown.userInteractionEnabled = YES;
    }else if (state == AliyunEffectMusicStateLocal) {
        NSString *tag = _musicInfo.tag?_musicInfo.tag:@"我的";
        [self.buttonDown setTitle:tag forState:UIControlStateNormal];
        [self.buttonDown setImage:nil forState:(UIControlStateNormal)];
        self.buttonDown.userInteractionEnabled = NO;
    }else if(state == AliyunEffectMusicStateNone) {
        [self.buttonDown setTitle:nil forState:UIControlStateNormal];
        [self.buttonDown setImage:nil forState:(UIControlStateNormal)];
        self.buttonDown.userInteractionEnabled = NO;
    } else {
        
    }
}
#pragma mark - public

- (void)updateProgress:(CGFloat)progress {
    if (progress >= 1) {
        // 下载完毕
        self.cycleView.percentage = 1.0;
        [self.cycleView removeFromSuperview];
        self.cycleView = nil;
        [self updateWithState:(AliyunEffectMusicStateLocal)];
    } else {
        self.buttonDown.userInteractionEnabled = NO;
        if (self.cycleView) {
            [self addSubview:self.cycleView];
            self.cycleView.percentage = progress;
        }
    }
}

- (void)updateDownloadFaliure {
    
    [self updateWithState:(AliyunEffectMusicStateRemote)];
    [self.cycleView removeFromSuperview];
}

-(void)setMusicInfo:(AliyunEffectMusicInfo *)musicInfo {
    _musicInfo = musicInfo;
    self.labelTitle.text = musicInfo.name;
    if (musicInfo.eid == 0) {
        [self updateWithState:(AliyunEffectMusicStateNone)];
        return;
    }
    
    BOOL isSave = musicInfo.isDBContain;
    if (isSave) {
        [self updateWithState:(AliyunEffectMusicStateLocal)];
    } else {
        [self updateWithState:(AliyunEffectMusicStateRemote)];
    }
    
}


#pragma mark - action

- (void)downClicked:(UIButton *)sender {
    [_delegate musicCell:self willDown:_musicInfo];
}

@end
