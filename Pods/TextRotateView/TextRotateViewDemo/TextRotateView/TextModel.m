//
//  TextModel.m
//  TextRotateViewDemo
//
//  Created by dev.liufeng on 2018/6/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "TextModel.h"
@implementation TextModel
- (instancetype)initWithText:(NSString *)text{
    if(self = [super init]){
        _textFont = 15;
        _textColor = [UIColor blackColor];
        _text = text;
        _textSize = CGSizeZero;
    }
    return  self;
}

- (CGSize)textSize{
    if(_textSize.width != 0){
        return _textSize;
    }else{
        return  [self textSizeWithText:_text];
    }
}

- (void)setTextFont:(CGFloat)textFont{
    _textFont = textFont;
    _textSize = [self textSizeWithText:_text];
}

- (CGSize)textSizeWithText:(NSString *)text{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    [attributes setValue:[UIFont systemFontOfSize:_textFont] forKey:NSFontAttributeName];
    CGRect textRect =  [text boundingRectWithSize:CGSizeMake(1000, _textFont) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return textRect.size;
}

@end
