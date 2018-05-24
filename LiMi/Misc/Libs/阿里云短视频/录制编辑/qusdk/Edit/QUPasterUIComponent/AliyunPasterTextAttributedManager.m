//
//  AliyunPasterTextAttributedManager.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterTextAttributedManager.h"
#import <CoreText/CoreText.h>

@implementation AliyunPasterTextAttributedManager


- (NSMutableAttributedString *)attribute:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName color:(UIColor * )textColor
{
    if (!fontName) {
        fontName = @"Helvetica";
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    NSDictionary *attributes = @{(id)kCTFontAttributeName : font,(id)kCTForegroundColorAttributeName:(id)textColor.CGColor};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    //居中
    CTTextAlignment alignment = kCTTextAlignmentCenter;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.valueSize = sizeof(alignment);
    alignmentStyle.value = &alignment;
    
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;//kCTLineBreakByCharWrapping;//换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //创建设置数组
    CTParagraphStyleSetting settings[ ] ={alignmentStyle,lineBreakMode};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings,1);
    //给文本添加设置
    [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)(style) range:NSMakeRange(0 , [text length])];
    CFRelease(style);
    
    return attributedString;
}

- (NSAttributedString *)attributeString:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor
{
    if (!textColor) {
        textColor = [UIColor whiteColor];
    }
    
    NSMutableAttributedString *attributedString = [self attribute:text fontSize:fontSize fontName:fontName color:textColor];
    //    加粗字体
    if ([fontName isEqualToString:@"SentyTEA"] ) {
        NSDictionary *shadowAttributes = @{NSStrokeWidthAttributeName:@-3,NSStrokeColorAttributeName:textColor};
        [attributedString addAttributes:shadowAttributes range:NSMakeRange(0 , [text length])];
    }
    
    return attributedString;
}

- (NSAttributedString *)strokeAttributeString:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor
{
    if (!textColor) {
        textColor = [UIColor whiteColor];
    }
    NSMutableAttributedString *attributedString = [self attribute:text fontSize:fontSize fontName:fontName color:textColor];
    
    //加粗更多充当描边
    NSDictionary *shadowAttributes = @{NSStrokeWidthAttributeName:@-8,NSStrokeColorAttributeName:textColor};
    [attributedString addAttributes:shadowAttributes range:NSMakeRange(0 , [text length])];
    return attributedString;
}

- (CGSize)sizeWithCoreText:(NSAttributedString *)attributedString length:(NSUInteger)textLength width:(CGFloat)width
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                        CFRangeMake(0, textLength),
                                                                        NULL,
                                                                        CGSizeMake(width, CGFLOAT_MAX),
                                                                        NULL);
    CFRelease(framesetter);
    
    return suggestedSize;
}

@end
