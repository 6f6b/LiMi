//
//  AliyunPublishContentEditView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AliyunPublishContentEditView.h"
#import "LiMi-Swift.h"
@interface AliyunPublishContentEditView ()<UITextViewDelegate,CustomTextViewDelegate>
@property (nonatomic,strong) UILabel *placeholderLabel;
@property (nonatomic,strong) UILabel *characterNumberLabel;
@end
@implementation AliyunPublishContentEditView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
//        self.backgroundColor = UIColor.greenColor;

        self.backgroundColor = rgba(53, 53, 53, 1);
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+5, 10+6, frame.size.width, 20)];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.textColor = rgba(114, 114, 114, 1);
        [self addSubview:_placeholderLabel];
        
        
        _textView = [[CustomTextView alloc] initWithFrame:CGRectMake(15, 10, frame.size.width-30, frame.size.height-20)];
        [_textView setUserInteractionEnabled:YES];
        _textView.delegate = self;
        _textView.customTextViewDelegate = self;
        _textView.backgroundColor = UIColor.clearColor;
        _textView.textColor = UIColor.whiteColor;
        [self addSubview:_textView];
        
        _characterNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _characterNumberLabel.textColor = rgba(114, 114, 114, 1);
        _characterNumberLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_characterNumberLabel];
    }
    return self;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}

- (NSString *)content{
    return self.textView.text;
}

- (void)setMaxCharacterNum:(NSInteger)maxCharacterNum{
    _maxCharacterNum = maxCharacterNum;
    _characterNumberLabel.text = [NSString stringWithFormat:@"%lu/%lu",_textView.text.length,maxCharacterNum];
    [_characterNumberLabel sizeToFit];
    CGRect frame = _characterNumberLabel.frame;
    frame.origin.x = self.frame.size.width-frame.size.width-15;
    frame.origin.y = self.frame.size.height-frame.size.height-10;
    _characterNumberLabel.frame = frame;
}

#pragma mark - UITextViewDelegate
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{}
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView{}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{}

- (void)textViewDidChange:(UITextView *)textView{
    NSString *preCharacter = [textView.text substringWithRange:NSMakeRange(textView.selectedRange.location-1, 1)];
    NSMutableString *text = [NSMutableString stringWithString:textView.text];
    if([preCharacter isEqualToString:@"@"]){
        [self.delegate aliyunPublishContentEditViewTapedRemind:self];
        [text replaceCharactersInRange:NSMakeRange(textView.selectedRange.location-1, 1) withString:@""];
    }
    self.placeholderLabel.hidden = text.length <= 0 ? NO : YES;
    if (text.length > _maxCharacterNum) {
        textView.text = [text substringToIndex:_maxCharacterNum];
    }
    _characterNumberLabel.text = [NSString stringWithFormat:@"%lu/%lu",textView.text.length,_maxCharacterNum];
    [_characterNumberLabel sizeToFit];
    CGRect frame = _characterNumberLabel.frame;
    frame.origin.x = self.frame.size.width-frame.size.width-15;
    frame.origin.y = self.frame.size.height-frame.size.height-10;
    _characterNumberLabel.frame = frame;
}

@end
