//
//  AliyunEffectMorePreviewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/22.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMorePreviewCell.h"
#import "AliyunEffectResourceModel.h"
#import <AVFoundation/AVFoundation.h>


@interface AliyunEffectMorePreviewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *mp4View;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AliyunEffectResourceModel *model;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation AliyunEffectMorePreviewCell

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
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, ScreenWidth, SizeHeight(300));
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = [UIColor blackColor];
    [self.webView setOpaque:NO];
    
    [self.contentView addSubview:self.webView];
    
    self.mp4View = [[UIView alloc] init];
    self.mp4View.frame = self.webView.bounds;
    self.mp4View.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.mp4View];
    self.mp4View.userInteractionEnabled = NO;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewCancelAction)];
    self.tap.cancelsTouchesInView = NO;
    self.tap.delegate = self;
    [self.contentView addGestureRecognizer:self.tap];

}

- (void)setEffectModel:(AliyunEffectResourceModel *)model {
    _model = model;
    [self startPreview];
}

- (void)startPreview {
    
    switch (_model.effectType) {
        case 2: {
            // 动图
            [self.contentView bringSubviewToFront:self.webView];
           
            NSURL *url = [NSURL URLWithString:self.model.preview];
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
            break;
        case 3: {
            // mv
            [self.contentView bringSubviewToFront:self.mp4View];

            NSURL *url = [NSURL URLWithString:self.model.previewMp4];
            AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:item];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.playerLayer.frame = self.mp4View.layer.bounds;
            [self.mp4View.layer addSublayer:self.playerLayer];
            NSLog(@"开始播放");
            [self.player play];
        }
            break;
        case 6: {
            // 字幕
            [self.contentView bringSubviewToFront:self.webView];

            NSURL *url = [NSURL URLWithString:self.model.preview];
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
            break;
        default:
            break;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)previewCancelAction {
    
    [self stopPreview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickPreviewCell:)]) {
        [self.delegate onClickPreviewCell:self];
    }
}


- (void)stopPreview {
    
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
    
}

@end
