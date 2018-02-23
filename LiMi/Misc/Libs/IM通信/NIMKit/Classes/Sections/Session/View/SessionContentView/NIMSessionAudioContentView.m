//
//  SessionAudioCententView.m
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSessionAudioContentView.h"
#import "UIView+NIM.h"
#import "NIMMessageModel.h"
#import "UIImage+NIMKit.h"
#import "NIMKitAudioCenter.h"
#import "NIMKit.h"

@interface NIMSessionAudioContentView()<NIMMediaManagerDelegate>

@property (nonatomic,strong) UIImageView *voiceImageView;

@property (nonatomic,strong) UILabel *durationLabel;

@end

@implementation NIMSessionAudioContentView

-(instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
//        [self addVoiceView];
        [[NIMSDK sharedSDK].mediaManager addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].mediaManager removeDelegate:self];
}

- (void)setPlaying:(BOOL)isPlaying
{
    if (isPlaying) {
        [self.voiceImageView startAnimating];
    }else{
        [self.voiceImageView stopAnimating];
    }
}

//Edit by LiuFeng   (NIM) 2018/2/11
- (void)addVoiceView{
    UIImage * image;
    NSArray *animateNames;
    if (self.model.message.isOutgoingMsg){
         image = [UIImage nim_imageInKit:@"im_icon_yuyin2"];
         animateNames = @[@"im_icon_bfb1",@"im_icon_bfb2",@"im_icon_bfb3"];
    }else{
        image = [UIImage nim_imageInKit:@"im_icon_yuyin1"];
        animateNames = @[@"im_icon_bf1",@"im_icon_bf2",@"im_icon_bf3"];

    }
    _voiceImageView = [[UIImageView alloc] initWithImage:image];
    NSMutableArray * animationImages = [[NSMutableArray alloc] initWithCapacity:animateNames.count];
    for (NSString * animateName in animateNames) {
        UIImage * animateImage = [UIImage nim_imageInKit:animateName];
        [animationImages addObject:animateImage];
    }
    _voiceImageView.animationImages = animationImages;
    _voiceImageView.animationDuration = 1.0;
    [self addSubview:_voiceImageView];
    
    _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _durationLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_durationLabel];
}

//Edit by LiuFeng   (NIM) 2018/2/11
- (void)refresh:(NIMMessageModel *)data{
    [super refresh:data];
    if( _voiceImageView == nil){
        [self addVoiceView];
    }
    NIMAudioObject *object = self.model.message.messageObject;
    self.durationLabel.text = [NSString stringWithFormat:@"%zd\"",(object.duration+500)/1000];//四舍五入
    
    NIMKitSetting *setting = [[NIMKit sharedKit].config setting:data.message];

    self.durationLabel.font      = setting.font;
    self.durationLabel.textColor = setting.textColor;
    
    [self.durationLabel sizeToFit];
    
    [self setPlaying:self.isPlaying];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    if (self.model.message.isOutgoingMsg) {
        self.voiceImageView.nim_right = self.nim_width - contentInsets.right;
        _durationLabel.nim_left = contentInsets.left;
    } else
    {
       self.voiceImageView.nim_left = contentInsets.left;
        _durationLabel.nim_right = self.nim_width - contentInsets.right;
    }
    _voiceImageView.nim_centerY = self.nim_height * .5f;
    _durationLabel.nim_centerY = _voiceImageView.nim_centerY;
}

-(void)onTouchUpInside:(id)sender
{
    if ([self.model.message attachmentDownloadState]== NIMMessageAttachmentDownloadStateFailed) {
        if (self.audioUIDelegate && [self.audioUIDelegate respondsToSelector:@selector(retryDownloadMsg)]) {
            [self.audioUIDelegate retryDownloadMsg];
        }
        return;
    }
    if ([self.model.message attachmentDownloadState] == NIMMessageAttachmentDownloadStateDownloaded) {
        
        if ([[NIMSDK sharedSDK].mediaManager isPlaying]) {
            [self stopPlayingUI];
        }
        
        NIMKitEvent *event = [[NIMKitEvent alloc] init];
        event.eventName = NIMKitEventNameTapAudio;
        event.messageModel = self.model;
        [self.delegate onCatchEvent:event];

    }
}

#pragma mark - NIMMediaManagerDelegate

- (void)playAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if(filePath && !error) {
        if (self.isPlaying && [self.audioUIDelegate respondsToSelector:@selector(startPlayingAudioUI)]) {
            [self.audioUIDelegate startPlayingAudioUI];
        }        
    }
}

- (void)playAudio:(NSString *)filePath didCompletedWithError:(NSError *)error
{
    [self stopPlayingUI];
}

#pragma mark - private methods
- (void)stopPlayingUI
{
    [self setPlaying:NO];
}

- (BOOL)isPlaying
{
    return [NIMKitAudioCenter instance].currentPlayingMessage == self.model.message; //对比是否是同一条消息，严格同一条，不能是相同ID，防止进了会话又进云端消息界面，导致同一个ID的云消息也在动画
}


@end
