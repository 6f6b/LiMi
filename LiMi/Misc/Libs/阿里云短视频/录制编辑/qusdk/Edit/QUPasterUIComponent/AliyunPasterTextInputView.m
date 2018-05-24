//
//  AliyunPasterTextInputView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/10.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterTextInputView.h"
#import "AliyunPasterTextStrokeView.h"

@interface AliyunPasterTextInputView ()

@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) AliyunPasterTextStrokeView *textView;

@end

@implementation AliyunPasterTextInputView
{
    CGFloat _keyboardHeight;
    AliyunColor *_color;
    NSString *_fontName;
}

#pragma mark - Life cycle -
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _color = [[AliyunColor alloc] init];
        _color.tR = _color.tG = _color.tB = 255.0;
        _color.sR = _color.sG = _color.sB = 255.0;
        _color.isStroke = NO;
        _keyboardHeight = 258;
        [self addNotifications];
        [self addSubviews];
    }
    return self;
}

- (void)dealloc
{
    [self removeNotifications];
}

+ (id)createPasterTextInputView
{
    AliyunPasterTextInputView *pasterInputView = [[AliyunPasterTextInputView alloc] initWithFrame:CGRectMake(0, 0, 10, 45)];
    return pasterInputView;
}

+ (id)createPasterTextInputViewWithText:(NSString *)text
                              textColor:(AliyunColor *)textColor
                               fontName:(NSString *)fontName
                           maxCharacterCount:(int)maxCharacterCount
{
    AliyunPasterTextInputView *pasterInputView = [[AliyunPasterTextInputView alloc] initWithFrame:CGRectMake(0, 0, 10, 45)];
    pasterInputView.textView.text = text;
    [pasterInputView setTextColor:textColor];
    [pasterInputView setFontName:fontName];
    pasterInputView.maxCharacterCount = maxCharacterCount;
    [pasterInputView textViewDidChange:pasterInputView.textView];
    
    return pasterInputView;
}

- (void)addSubviews
{
    CGRect borderViewFrame = CGRectMake(-2, -2, self.bounds.size.width + 4, self.bounds.size.height + 4);
    self.borderView = [[UIView alloc] initWithFrame:borderViewFrame];
    [self addSubview:self.borderView];
    self.borderView.autoresizingMask = 0b111111;
    self.borderView.layer.masksToBounds = YES;
    self.borderView.layer.borderColor = [UIColor colorWithRed:239.0 / 255 green:75.0 / 255 blue:129.0 / 255 alpha:1].CGColor;
    self.borderView.layer.borderWidth = 1.5;
    self.borderView.layer.cornerRadius = 2.0;
    self.borderView.backgroundColor = [UIColor clearColor];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(0, 0, 40, 40);
    [self addSubview:self.closeButton];
    [self.closeButton setImage:[AliyunImage imageNamed:@"pasterview_delete"] forState:UIControlStateNormal];
    self.closeButton.center = CGPointMake(0, 0);
    
    self.textView = [[AliyunPasterTextStrokeView alloc] initWithFrame:self.bounds];
    [self addSubview:self.textView];
    self.textView.font = [UIFont systemFontOfSize:40.0];
    self.textView.delegate = (id)self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollEnabled = NO;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.returnKeyType = UIReturnKeyDefault;
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShowAction:(NSNotification *)noti
{
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardFrame.size.height;
    [self.delegate keyboardFrameChanged:keyboardFrame animateDuration:animationDuration];
    [self avoidKeyboardCoverTextInputView];
}

- (void)keyboardWillHideAction:(NSNotification *)noti
{
    
}

- (void)setDelegate:(id<AliyunPasterTextInputViewDelegate>)delegate
{
    _delegate = delegate;
    [_textView becomeFirstResponder];
}

#pragma mark - Private Methods -

#pragma mark - Public Methods
- (NSString *)getText
{
    NSString *text = [self isValidateText:self.textView.text];
    self.textView.text = text;
    
    return self.textView.text;
}

- (void)shouldHiddenKeyboard
{
    [self.textView resignFirstResponder];
}

- (void)shouldAppearKeyboard
{
    [self.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.1];
}

- (void)setTextColor:(AliyunColor *)color
{
    _color = color;
    _textView.isStroke = color.isStroke;
    _textView.mTextStrokeColor =  RGBToColor(_color.sR, _color.sG, _color.sB);
    _textView.mTextColor = RGBToColor(_color.tR, _color.tG, _color.tB);
}

- (void)setFilterTextColor:(AliyunColor *)color
{
    if (_color == nil) {
        _color = color;
    }
    _textView.isStroke = color.isStroke;
    _color.isStroke = color.isStroke;
    if (_textView.isStroke) {
        _color.sR = color.sR;
        _color.sG = color.sG;
        _color.sB = color.sB;
    } else {
        _color.tR = color.tR;
        _color.tG = color.tG;
        _color.tB = color.tB;
    }
    
    _textView.mTextStrokeColor = RGBToColor(_color.sR, _color.sG, _color.sB);
    _textView.mTextColor = RGBToColor(_color.tR, _color.tG, _color.tB);
}

- (void)setFontName:(NSString *)fontName
{
    if (fontName == nil) {
        _fontName = _textView.font.fontName;
    } else {
        _fontName = fontName;
    }
    _textView.mfontName = fontName;
}

- (NSString *)fontName
{
    return _fontName;
}

- (AliyunColor *)getTextColor
{
    return _color;
}

#pragma mark -UITextViewDelegate -
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    UIFont *font = textView.font;
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize textSize =  [text sizeWithAttributes:attr];
    CGFloat padding =  textView.textContainer.lineFragmentPadding;
    CGFloat fixedWidth = textSize.width + 2 *padding;
    
    if (fixedWidth >= ScreenWidth - 20) {
        fixedWidth = ScreenWidth - 20;
    }
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
    CGRect newFrame = textView.frame;
    
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    self.bounds = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    self.borderView.bounds = CGRectMake(0, 0, newFrame.size.width + 4, newFrame.size.height + 4);
   
    [self avoidKeyboardCoverTextInputView];
    
    if (textView.markedTextRange == nil) {//刷新文字
        if (self.maxCharacterCount <= 0) {//对文字数目没有要求
            textView.text = text;
        } else {
            textView.text = [self isValidateText:text];
        }
    }
}

- (void)avoidKeyboardCoverTextInputView {
    //防止键盘遮挡输入文字框
    CGPoint cp = [self.superview convertPoint:self.center toView:[[UIApplication sharedApplication] keyWindow]];
    if (cp.y + self.bounds.size.height / 2 >= ScreenHeight - _keyboardHeight - 10 - 40) {
        cp.y = ScreenHeight - _keyboardHeight - 10 - 40 - self.bounds.size.height / 2;
        CGPoint np = [[[UIApplication sharedApplication] keyWindow] convertPoint:cp toView:self.superview];
        self.center = np;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (NSString *)isValidateText:(NSString *)text {
    if (self.maxCharacterCount == 0) {
        return text;
    }
    
    int  character = 0;
    for(int i=0; i< [text length];i++){
        int a = [text characterAtIndex:i];
        if( a >= 0x4e00 && a <= 0x9fa5){ //判断是否为中文
            character +=2;
        } else {
            if (a != 0xA) {
                character +=1;
            }
        }
        
        
        if (character > self.maxCharacterCount) {
            text = [text substringWithRange:NSMakeRange(0, i)];
            break;
        }
    }
    return text;
}


@end
