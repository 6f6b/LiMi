//
//  AliyunPasterTextStrokeView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterTextStrokeView.h"



@implementation AliyunPasterTextStrokeView

@synthesize mTextColor = _mTextColor;
@synthesize mTextStrokeColor = _mTextStrokeColor;
@synthesize mfontName = _mfontName;
@synthesize mfontSize = _mfontSize;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setText:(NSString *)text
{
    [super setText:text];
    if (text) {
        [self drawAttributeText];
    }
}

- (void)drawAttributeText
{
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:[self textAttribute]];
    self.attributedText = attributedString;
}

- (NSDictionary *)textAttribute
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont fontWithName:self.mfontName size:self.mfontSize];
    if (!font) {
        font = [UIFont fontWithName:@"Helvetica" size:self.mfontSize];
    }
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:self.mTextColor};
    
    if (self.isStroke) {
        attributes = @{NSFontAttributeName:font,
                       NSParagraphStyleAttributeName:paragraphStyle,
                       NSForegroundColorAttributeName:self.mTextColor,
                       NSStrokeWidthAttributeName:@-2,
                       NSStrokeColorAttributeName:self.mTextStrokeColor};
    }
    return attributes;
}

#pragma mark - Setter Getter -

- (NSString *)mfontName
{
    if (_mfontName == nil) {
        _mfontName = self.font.fontName;
    }
    return _mfontName;
}

- (void)setMfontName:(NSString *)mfontName
{
    _mfontName = mfontName;
    [self drawAttributeText];
}

- (CGFloat)mfontSize
{
    if (_mfontSize <= 0) {
        _mfontSize = self.font.pointSize;
    }
    return _mfontSize;
}

- (void)setMfontSize:(CGFloat)mfontSize
{
    _mfontSize = mfontSize;
}

- (UIColor *)mTextColor
{
    if (_mTextColor == nil) {
        _mTextColor = [UIColor whiteColor];
    }
    return _mTextColor;
}

- (void)setMTextColor:(UIColor *)mTextColor
{
    _mTextColor = mTextColor;
    [self drawAttributeText];
}

- (UIColor *)mTextStrokeColor
{
    if (_mTextStrokeColor == nil) {
        _mTextStrokeColor = [UIColor whiteColor];
    }
    return _mTextStrokeColor;
}

- (void)setMTextStrokeColor:(UIColor *)mTextStrokeColor
{
    _mTextStrokeColor = mTextStrokeColor;
    [self drawAttributeText];
}

@end
