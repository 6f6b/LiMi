//
//  SnapchatAttachment.m
//  NIM
//
//  Created by amao on 7/2/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESLiMiSystemMsgAttachment.h"
#import "NTESFileLocationHelper.h"
#import "NSData+NTES.h"
#import "NTESSessionUtil.h"
#import "M80AttributedLabel.h"

@interface NTESLiMiSystemMsgAttachment()

@property (nonatomic,assign) BOOL isFromMe;

@end

@implementation NTESLiMiSystemMsgAttachment

//- (void)setImage:(UIImage *)image
//{
//    NSData *data = UIImageJPEGRepresentation(image, 0.7);
//    NSString *md5= [data MD5String];
//    self.md5 = md5;
//    
//    [data writeToFile:[self filepath]
//           atomically:YES];
//}
//
//- (void)setImageFilePath:(NSString *)path
//{
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        self.md5 =  [data MD5String];
//        [data writeToFile:[self filepath]
//               atomically:YES];
//     }
//}




- (NSString *)cellContent:(NIMMessage *)message{
    return @"NTESSessionLiMiSystemMsgContentView";
}

- (CGSize)contentSize:(NIMMessage *)message cellWidth:(CGFloat)width{
    self.isFromMe = message.isOutgoingMsg;
    //求全部上下间隔宽度
    CGFloat totalEmptySpace = 0;
    if(self.title != Nil){totalEmptySpace += 12;}
    if(self.txt != Nil){totalEmptySpace += 7;}
    if(self.url != Nil){totalEmptySpace += 7;}
    if(self.image != Nil){totalEmptySpace += 7;}
    totalEmptySpace += 12;
    //求最长字符串，以便求得最大宽度
    NSString *longestString =  MAX(self.title, self.txt);
    
    M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    CGFloat msgBubbleMaxWidth    = (UIScreenWidth - 130);
    CGFloat contentLeftToBubble  = 15;
    CGFloat contentRightToBubble = 15;
    CGFloat msgBubbleMinWidth = msgBubbleMaxWidth - (msgBubbleMaxWidth - contentLeftToBubble - contentRightToBubble)*0.5;
    label.autoDetectLinks = NO;
    label.font = [UIFont systemFontOfSize:Message_Font_Size];
    
    //求得最终宽度
    [label setText:longestString];
    CGFloat msgContentMaxWidth = (msgBubbleMaxWidth - contentRightToBubble - contentLeftToBubble);
    CGSize labelSize = [label sizeThatFits:CGSizeMake(msgContentMaxWidth, CGFLOAT_MAX)];
    CGFloat bubbleWidth = MAX(labelSize.width + contentRightToBubble + contentLeftToBubble, msgBubbleMinWidth);
    
    //求title的size
    [label setText:self.title];
    CGSize titleSize = [label sizeThatFits:CGSizeMake(labelSize.width, CGFLOAT_MAX)];
    
    //求txt的size
    [label setText:self.txt];
    CGSize txtSize = [label sizeThatFits:CGSizeMake(labelSize.width, CGFLOAT_MAX)];
    
    //求urlsize
    [label setText:@"点击查看"];
    CGSize urlSize = [label sizeThatFits:CGSizeMake(labelSize.width, CGFLOAT_MAX)];
    if(self.url == nil && self.link_id == nil){
        urlSize = CGSizeZero;
    }
    
    //图片size
    CGSize imageSize = CGSizeZero;
    if(self.image != Nil){
        CGFloat imageWidth = MIN((msgBubbleMaxWidth - contentLeftToBubble - contentRightToBubble)*0.5, self.image_w);
        CGFloat floatImageHeight = self.image_h;
        CGFloat floatImageWidth = self.image_w;
        CGFloat tmpImageHeight = imageWidth * (floatImageHeight/floatImageWidth);
        CGFloat imageHeight = MIN(tmpImageHeight, 200);
        imageSize.height = imageHeight;
        imageSize.width = imageWidth;
    }
    CGSize contentSize = CGSizeMake(bubbleWidth, totalEmptySpace + titleSize.height + txtSize.height + urlSize.height +imageSize.height);
    return contentSize;
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
    [dict setObject:@(CustomMessageTypeLiMiSystemMsg) forKey:CMType];

    [data setObject:_title forKey:CMLiMiSystemMsgTitle];
    [data setObject:_image forKey:CMLiMiSystemMsgImage];
    NSNumber *linkID = [NSNumber numberWithInteger:_link_id];
    [data setObject:linkID forKey:CMLiMiSystemMsgLinkID];
    NSNumber *linkSubID = [NSNumber numberWithInteger:_link_subid];
    [data setObject:linkSubID forKey:CMLiMiSystemMsgLinkSubID];
    NSNumber *linkType = [NSNumber numberWithInteger:_link_type];
    [data setObject:linkType forKey:CMLiMiSystemMsgLinkType];
    NSNumber *imageHeight = [NSNumber numberWithInteger:_image_h];
    [data setObject:imageHeight forKey:CMLiMiSystemMsgImageHeight];
    NSNumber *imageWidth = [NSNumber numberWithInteger:_image_w];
    [data setObject:imageWidth forKey:CMLiMiSystemMsgImageWidth];
    [data setObject:_txt forKey:CMLiMiSystemMsgTXT];
    [data setObject:_url forKey:CMLiMiSystemMsgURL];

    
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
//    return [_url length] == 0;
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
