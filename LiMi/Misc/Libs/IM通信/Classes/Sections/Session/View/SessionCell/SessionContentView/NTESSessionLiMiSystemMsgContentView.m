//
//  NTESSessionLiMiSystemMsgContentView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/4/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "NTESSessionLiMiSystemMsgContentView.h"
#import "NTESLiMiSystemMsgAttachment.h"
#import "M80AttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface NTESSessionLiMiSystemMsgContentView()
@property (nonatomic,strong) M80AttributedLabel *titleLabel;
@property (nonatomic,strong) M80AttributedLabel *contentLabel;
@property (nonatomic,strong) UIButton *linkBtn;
@property (nonatomic,strong) UIImageView *imageView;
@end
@implementation NTESSessionLiMiSystemMsgContentView


- (instancetype)initSessionMessageContentView
{
    if(self = [super initSessionMessageContentView]){
        _titleLabel = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
//        _titleLabel.backgroundColor = [UIColor purpleColor];
        _titleLabel.autoDetectLinks = NO;
        _titleLabel.font = [UIFont systemFontOfSize:Message_Font_Size];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        _contentLabel = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
//        _contentLabel.backgroundColor = [UIColor purpleColor];
        _contentLabel.autoDetectLinks = NO;
        _contentLabel.font = [UIFont systemFontOfSize:Message_Font_Size];
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
        
        _linkBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        _linkBtn.userInteractionEnabled = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealTapLink)];
        [_linkBtn addGestureRecognizer:tap];
//        _linkLabel.backgroundColor = [UIColor purpleColor];
        UIColor *titleColor = [UIColor colorWithRed:47/255.0 green:196/255.0 blue:233/255.0 alpha:1];
        [_linkBtn setTitleColor:titleColor forState:UIControlStateNormal];
        _linkBtn.titleLabel.font = [UIFont systemFontOfSize:Message_Font_Size];
        [self addSubview:_linkBtn];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
//        _imageView.backgroundColor = [UIColor purpleColor];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)refresh:(NIMMessageModel*)data
{
    [super refresh:data];
    NIMCustomObject * customObject     = (NIMCustomObject*)data.message.messageObject;
    NTESLiMiSystemMsgAttachment *attachment = (NTESLiMiSystemMsgAttachment *)customObject.attachment;
    
    //求全部上下间隔宽度
    CGFloat totalEmptySpace = 0;
    if(attachment.title != Nil){totalEmptySpace += 12;}
    if(attachment.txt != Nil){totalEmptySpace += 7;}
    if(attachment.url != Nil){totalEmptySpace += 7;}
    if(attachment.image != Nil){totalEmptySpace += 7;}
    totalEmptySpace += 12;
    //求最长字符串，以便求得最大宽度
    NSString *longestString =  MAX(attachment.title, attachment.txt);
//
    M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    CGFloat msgBubbleMaxWidth    = (UIScreenWidth - 130);
    CGFloat contentLeftToBubble  = 15;
    CGFloat contentRightToBubble = 15;
    CGFloat msgBubbleMinWidth = msgBubbleMaxWidth - (msgBubbleMaxWidth - contentLeftToBubble - contentRightToBubble)*0.5;
    label.autoDetectLinks = NO;
    label.font = [UIFont systemFontOfSize:Message_Font_Size];
//
    //求得最终宽度
    [label setText:longestString];
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - contentLeftToBubble);
    CGSize labelSize = [label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
    CGFloat bubbleWidth = MAX(labelSize.width + contentRightToBubble + contentLeftToBubble, msgBubbleMinWidth);

    //求title的size
    [label setText:attachment.title];
    CGSize titleSize = [label sizeThatFits:CGSizeMake(labelSize.width, CGFLOAT_MAX)];

    //求txt的size
    [label setText:attachment.txt];
    CGSize txtSize = [label sizeThatFits:CGSizeMake(labelSize.width, CGFLOAT_MAX)];

    //求urlsize
    [label setText:@"点击查看"];
    CGSize urlSize = [label sizeThatFits:CGSizeMake(labelSize.width, CGFLOAT_MAX)];

    //图片size
    CGSize imageSize = CGSizeZero;
    if(attachment.image != Nil){
        CGFloat imageWidth = MIN((msgBubbleMaxWidth - contentLeftToBubble - contentRightToBubble)*0.5, attachment.image_w);
        CGFloat floatImageHeight = attachment.image_h;
        CGFloat floatImageWidth = attachment.image_w;
        CGFloat tmpImageHeight = imageWidth * (floatImageHeight/floatImageWidth);
        CGFloat imageHeight = MIN(tmpImageHeight, 200);
        imageSize.height = imageHeight;
        imageSize.width = imageWidth;
    }
    
    [self.titleLabel setText:attachment.title];
    self.titleLabel.frame = CGRectMake(15, 12, titleSize.width, titleSize.height);
    
    [self.contentLabel setText:attachment.txt];
    self.contentLabel.frame = CGRectMake(15, CGRectGetMaxY(self.titleLabel.frame) + 7, txtSize.width, txtSize.height);
    
    [self.linkBtn setTitle:@"点击查看" forState:UIControlStateNormal];
    self.linkBtn.frame = CGRectMake(15, CGRectGetMaxY(self.contentLabel.frame) + 7, urlSize.width, urlSize.height);
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:attachment.image]];
    self.imageView.frame = CGRectMake(15, CGRectGetMaxY(self.linkBtn.frame) + 7, imageSize.width, imageSize.height);
}

- (void)dealTapLink{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self.model forKey:@"NIMMessageModel"];
    [NSNotificationCenter.defaultCenter postNotificationName:@"DEAL_TAP_LINK" object:nil userInfo:userInfo];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}


- (void)updateProgress:(float)progress
{
    
}

- (void)onTouchDown:(id)sender
{
    
}

- (void)onTouchUpInside:(id)sender
{
    
}

- (void)onTouchUpOutside:(id)sender{
    
}


#pragma mark - Private
- (UIImage *)chatBubbleImageForState:(UIControlState)state outgoing:(BOOL)outgoing
{
    
    NIMKitSetting *setting = [[NIMKit sharedKit].config setting:self.model.message];
    if (state == UIControlStateNormal)
    {
        return setting.normalBackgroundImage;
    }
    else
    {
        return setting.highLightBackgroundImage;
    }
}


- (void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
}

@end
