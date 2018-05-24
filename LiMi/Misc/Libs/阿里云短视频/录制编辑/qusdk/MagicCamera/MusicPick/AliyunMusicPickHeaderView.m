//
//  AliyunMusicPickHeaderView.m
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickHeaderView.h"

@implementation AliyunMusicPickHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self buildSubview];
    }
    
    return self;
}
- (void)buildSubview {
//    // 白色背景
//    self.backgroundColor = [UIColor clearColor];
//    self.backgroundView.backgroundColor = [UIColor clearColor];
    UIView *contentView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,64)];
    contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView = contentView;
    
//    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
//    self.line.backgroundColor = [UIColor whiteColor];
//    [contentView addSubview:self.line];
    
    // 按钮
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0.5, ScreenWidth, 63)];
    [self.button addTarget:self
                    action:@selector(buttonEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0.5, ScreenWidth, 40)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [contentView addSubview:self.titleLabel];
    
    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 40.5, ScreenWidth, 17)];
    self.artistLabel.textColor = rgba(195,197,198,1);
    self.artistLabel.font = [UIFont systemFontOfSize:12.0f];
    [contentView addSubview:self.artistLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(24, 24, 16, 16)];
    self.imageView.image = [AliyunImage imageNamed:@"music_check"];
    self.imageView.hidden = YES;
    [contentView addSubview:self.imageView];
}

- (void)buttonEvent:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeader:)]) {
        [self.delegate didSelectHeader:self];
    }
}

- (void)shouldExpand:(BOOL)expand{
    if (expand) {
        self.imageView.hidden = NO;
    }else {
        self.imageView.hidden = YES;
    }
}

@end
