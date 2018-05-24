//
//  AliyunPasterTextView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterTextView.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "AliyunPasterTextAttributedManager.h"

#define  MAX_FONT_SIZE 2000

@interface AliyunPasterTextView()

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, strong) AliyunPasterTextAttributedManager *attributedManager;

@end

@implementation AliyunPasterTextView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (AliyunPasterTextAttributedManager *)attributedManager
{
    if (!_attributedManager) {
        _attributedManager = [[AliyunPasterTextAttributedManager alloc] init];
    }
    return _attributedManager;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    NSString *text = self.text ? :@"";
    
    CTFrameRef textFrameRef ;
    CTFramesetterRef framesetterRef;
    CGMutablePathRef leftColumnPathRef;
    
    self.fontSize = [self fontSizeBetweenMinSize:1 andMaxSize:MAX_FONT_SIZE];
    self.textSize = [self stringSizeWithText:text fontSize:self.fontSize];
    
    NSAttributedString *attributedString = [self.attributedManager
                                            attributeString:text
                                            fontSize:self.fontSize
                                            fontName:self.fontName
                                            textColor:self.textColor];
    
    framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    leftColumnPathRef = CGPathCreateMutable();
    CGFloat top = (CGRectGetHeight(self.bounds) - self.textSize.height ) / 2;
    CGPathAddRect(leftColumnPathRef, NULL, CGRectMake(0, -top, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
    textFrameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0,0), leftColumnPathRef, NULL);
    
    //描边
    CTFrameRef textStrokeFrameRef;
    CGMutablePathRef textStrokePathRef;
    CTFramesetterRef textStrokeFramesetterRef;
    if (self.isStroke) {
        NSAttributedString *textStrokeAttributedString = [self.attributedManager
                                                          strokeAttributeString:text
                                                          fontSize:self.fontSize
                                                          fontName:self.fontName
                                                          textColor:self.strokeColor];
        textStrokeFramesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)textStrokeAttributedString);
        textStrokePathRef = CGPathCreateMutable();
        CGSize textStrokeSize = [self strokeStringSizeWithText:text fontSize:self.fontSize];
        CGFloat strokeTop = (CGRectGetHeight(self.bounds) - textStrokeSize.height) / 2;
        CGPathAddRect(textStrokePathRef, NULL, CGRectMake(0, -strokeTop, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
        textStrokeFrameRef = CTFramesetterCreateFrame(textStrokeFramesetterRef, CFRangeMake(0, 0), textStrokePathRef, NULL);
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    if (self.isStroke) {
        CTFrameDraw(textStrokeFrameRef, contextRef);
        CFRelease(textStrokeFrameRef);
        CGPathRelease(textStrokePathRef);
        CFRelease(textStrokeFramesetterRef);
    }
    CTFrameDraw(textFrameRef, contextRef);
    
    CFRelease(textFrameRef);
    CGPathRelease(leftColumnPathRef);
    CFRelease(framesetterRef);
}

- (CGSize)strokeStringSizeWithText:(NSString *)text fontSize:(CGFloat)fontSize
{
    NSAttributedString *attributedString = [self.attributedManager strokeAttributeString:text fontSize:fontSize fontName:self.fontName textColor:self.textColor];
    CGSize strokeTextSize = [self.attributedManager sizeWithCoreText:attributedString length:text.length width:CGRectGetWidth(self.bounds)];
    
    return strokeTextSize;
}

- (CGSize)stringSizeWithText:(NSString *)text fontSize:(CGFloat)fontSize
{
    NSAttributedString *attributedString = [self.attributedManager attributeString:text fontSize:fontSize fontName:self.fontName textColor:self.textColor];
    
    CGSize textSize = [self.attributedManager sizeWithCoreText:attributedString length:text.length width:CGRectGetWidth(self.bounds)];
    
    
    return textSize;
}

//二分查找合适字体
- (CGFloat)binarySearchForFontSizeBetween:(CGFloat)minFontSize and:(CGFloat)maxFontSize
{
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat boundsWidth = self.bounds.size.width;
    
    if (maxFontSize < minFontSize) {
        
        CGSize lastTextSize = [self stringSizeWithText:self.text ? :@"" fontSize:minFontSize];
        if (lastTextSize.height > boundsHeight || lastTextSize.width > boundsWidth) {
            minFontSize -= 1;
        }
        return minFontSize;
    }
    
    CGFloat fontSize = (minFontSize + maxFontSize) / 2;
    
    CGSize textSize = [self stringSizeWithText:self.text ? :@"" fontSize:fontSize];
    
    if (textSize.height >= boundsHeight + 6 && textSize.width >= boundsWidth + 6 && textSize.height <= boundsHeight && textSize.width <= boundsWidth) {
        return fontSize;
    } else if (textSize.height > boundsHeight || textSize.width > boundsWidth) {
        return [self binarySearchForFontSizeBetween:minFontSize and:fontSize - .4];
    } else {
        return [self binarySearchForFontSizeBetween:fontSize + .4 and:maxFontSize];
    }
}

- (CGFloat)fontSizeBetweenMinSize:(CGFloat)minSize andMaxSize:(CGFloat)maxSize
{
    CGFloat fontSize = [self binarySearchForFontSizeBetween:minSize and:maxSize];
    return fontSize;
}

//overwrite
#define Render_Factor 0.055f
- (UIImage *)captureImage:(CGSize)nativeSize outputSize:(CGSize)outputSize {
    
    float factor = CGRectGetHeight(self.bounds) / nativeSize.height;
    if (factor <= Render_Factor) {
        return [self captureImage];
    }
    
    CGFloat rw = nativeSize.width / outputSize.width;
    CGFloat rh = nativeSize.height / outputSize.height;
    CGFloat tw = CGRectGetWidth(self.bounds) / rw;
    CGFloat th = CGRectGetHeight(self.bounds) / rh;
    
    AliyunPasterTextView *toRenderedPasterTextView = [[AliyunPasterTextView alloc] initWithFrame:CGRectMake(0, 0, tw, th)];
    toRenderedPasterTextView.fontName = self.fontName;
    toRenderedPasterTextView.isStroke = self.isStroke;
    toRenderedPasterTextView.textColor = self.textColor;
    toRenderedPasterTextView.strokeColor = self.strokeColor;
    toRenderedPasterTextView.text = self.text;
    
    UIImage *image = [toRenderedPasterTextView captureImage];
    
    return image;
}

@end
