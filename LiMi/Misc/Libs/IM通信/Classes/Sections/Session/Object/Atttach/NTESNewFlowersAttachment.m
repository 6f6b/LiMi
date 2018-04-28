//
//  SnapchatAttachment.m
//  NIM
//
//  Created by amao on 7/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESNewFlowersAttachment.h"
#import "NTESFileLocationHelper.h"
#import "NSData+NTES.h"
#import "NTESSessionUtil.h"

@interface NTESNewFlowersAttachment()

@property (nonatomic,assign) BOOL isFromMe;

@end

@implementation NTESNewFlowersAttachment



- (NSString *)cellContent:(NIMMessage *)message{
    return @"NTESSessionLiMiSystemMsgContentView";
}

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width{
    self.isFromMe = message.isOutgoingMsg;
    CGSize size = self.showCoverImage.size;
    CGFloat customSnapMessageImageRightToText = 5;
    return CGSizeMake(size.width + customSnapMessageImageRightToText, size.height);
}

- (UIEdgeInsets)contentViewInsets:(NIMMessage *)message
{
    CGFloat bubblePaddingForImage    = 3.f;
    CGFloat bubbleArrowWidthForImage = -4.f;
    if (message.isOutgoingMsg) {
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage);
    }else{
        return  UIEdgeInsetsMake(bubblePaddingForImage,bubblePaddingForImage + bubbleArrowWidthForImage, bubblePaddingForImage,bubblePaddingForImage);
    }
}

- (void)setIsFromMe:(BOOL)isFromMe{
    if (_isFromMe != isFromMe) {
        _isFromMe = isFromMe;
    }
}

- (BOOL)canBeForwarded
{
    return NO;
}

- (BOOL)canBeRevoked
{
    return YES;
}



#pragma NIMCustomAttachment
- (NSString *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [dict setObject:@(CustomMessageTypeNewFollowersMsg) forKey:CMType];
    [data setObject:self.title forKey:CMNewFridendTitle];

    [dict setObject:data forKey:CMData];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    
    return [[NSString alloc] initWithData:jsonData
                                 encoding:NSUTF8StringEncoding];
}


#pragma mark - 实现文件上传需要接口
//- (BOOL)attachmentNeedsUpload
//{
//    return false
//    //return [_url length] == 0;
//}
//
//- (NSString *)attachmentPathForUploading
//{
//    return [self filepath];
//}
//
//- (void)updateAttachmentURL:(NSString *)urlString
//{
//    self.url = urlString;
//}


#pragma mark - Private


#pragma mark - https
//- (NSString *)url
//{
//    return [_url length] ?
//    [[[NIMSDK sharedSDK] resourceManager] normalizeURLString:_url] : nil;
//}

@end
