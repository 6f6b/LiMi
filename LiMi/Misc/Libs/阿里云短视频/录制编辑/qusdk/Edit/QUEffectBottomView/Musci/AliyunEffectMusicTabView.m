//
//  AliyunEffectMusicTabView.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMusicTabView.h"

@interface AliyunEffectMusicTabView ()
@property (nonatomic, strong) UIButton *tabRemote;
@property (nonatomic, strong) UIButton *tabLocal;
@property (nonatomic, strong) UIView *indicatorView;
@end

@implementation AliyunEffectMusicTabView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.tabRemote = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, 48)];
    [self.tabRemote setTitle:NSLocalizedString(@"my_music_edit", nil) forState:UIControlStateNormal];
    [self.tabRemote setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.tabRemote setTitleColor:rgba(110,118,139,1) forState:UIControlStateNormal];
    [self.tabRemote addTarget:self action:@selector(remoteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.tabRemote];
    
    self.tabLocal = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, 0, ScreenWidth/2, 48)];
    [self.tabLocal setTitle:NSLocalizedString(@"local_music_edit", nil) forState:UIControlStateNormal];
    [self.tabLocal setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.tabLocal setTitleColor:rgba(110,118,139,1) forState:UIControlStateNormal];
    [self.tabLocal addTarget:self action:@selector(localClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.tabLocal];
    
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 46, ScreenWidth/2, 2)];
    self.indicatorView.backgroundColor = rgba(239,75,129,1);
    [self addSubview:self.indicatorView];
    [self updateAppearance:0];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

- (void)layout {
    self.tabRemote.frame = CGRectMake(0, 0, ScreenWidth/2, 48);
    self.tabLocal.frame = CGRectMake(ScreenWidth/2, 0, ScreenWidth/2, 48);
}

#pragma mark - action

- (void)remoteClicked:(UIButton *)sender {
    [self updateAppearance:0];
    [_delegate tabViewDidSelectTab:0];
}

- (void)localClicked:(UIButton *)sender {
    [self updateAppearance:1];
    [_delegate tabViewDidSelectTab:1];
}

- (void)updateAppearance:(NSInteger)selectedTab {
    if (selectedTab == 0) {
        self.tabRemote.selected = YES;
        self.tabLocal.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.indicatorView.frame = CGRectMake(0, 46, ScreenWidth/2, 2);
        }];
    }else {
        self.tabRemote.selected = NO;
        self.tabLocal.selected = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.indicatorView.frame = CGRectMake(ScreenWidth/2, 46, ScreenWidth/2, 2);
        }];
    }
}

@end
