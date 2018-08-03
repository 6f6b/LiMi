//
//  AliyunPublishContentEditView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AliyunPublishContentEditView.h"
#import "LiMi-Swift.h"
typedef enum {
    ///相等（完全重合）
    RangeRelationshipAEqualB,
    ///相交
    RangeRelationshipAInsersectB,
    ///A包含B
    RangeRelationshipAIncludeB,
    ///B包含A
    RangeRelationshipAIncludedByB,
    ///测试
    RangeRelationshipNone
}RangeRelationship;
@interface AliyunPublishContentEditView ()<UITextViewDelegate,CustomTextViewDelegate>
@property (nonatomic,strong) UILabel *placeholderLabel;
@property (nonatomic,strong) UILabel *characterNumberLabel;
@property (nonatomic,strong) NSMutableArray *remindedUsers;
@end
@implementation AliyunPublishContentEditView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){

        _remindedUsers = [[NSMutableArray alloc] init];
        
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

- (NSArray *)seperateWith:(NSArray *)sourceArray andMarkArray:(NSMutableArray *)markArray{
    if(markArray.count <= 0){return sourceArray;}
    NSMutableArray *nextSourceArray = [NSMutableArray new];
    OCUserInfoModel *userInfoModel = markArray.lastObject;
    for(NSString *text in sourceArray){
        NSRange range = [text rangeOfString:userInfoModel.nickName];
        if(range.length == 0){
            //不存在
            [nextSourceArray addObject:text];
        }else{
            //相等
            if(range.location == 0 && range.length == text.length){
                [nextSourceArray addObject:text];
            }
            //前包含
            else if(range.location == 0 && (range.location + range.length)<text.length){
                [nextSourceArray addObject:userInfoModel.nickName];
                NSString *suffixStr = [text substringFromIndex:range.length];
                [nextSourceArray addObject:suffixStr];
            }
            //后包含
            else if(range.location > 0 &&(range.location+range.length) == text.length){
                NSString *prefixStr = [text substringToIndex:range.location];
                [nextSourceArray addObject:prefixStr];
                [nextSourceArray addObject:userInfoModel.nickName];
            }
            //中间
            else if(range.location > 0 && (range.location+range.length)<text.length){
                NSString *prefixStr = [text substringToIndex:range.location];
                NSString *nickName = userInfoModel.nickName;
                NSString *suffixStr = [text substringFromIndex:range.location + range.length];
                [nextSourceArray addObject:prefixStr];
                [nextSourceArray addObject:nickName];
                [nextSourceArray addObject:suffixStr];
            }
        }
    }
    [markArray removeLastObject];
    return [self seperateWith:nextSourceArray andMarkArray:markArray];
}

//组装TextExtraModel数组
- (NSArray *)assembleTextExtraModelsWith:(NSArray *)strs{
    NSMutableArray *arr = [NSMutableArray new];
    NSArray *userInfos = [self.remindedUsers copy];
    for(NSString *str in strs){
        TextExtraModel *textExtraModel = [TextExtraModel new];
        textExtraModel.type = TextExtraModelTypeNormal;
        textExtraModel.text = str;
        for(OCUserInfoModel *userInfo in userInfos){
            if(userInfo.nickName == str){
                textExtraModel.type = TextExtraModelTypeRemined;
                textExtraModel.userId = userInfo.userId;
                break;
            }
        }
        [arr addObject:textExtraModel];
    }
    return arr;
}

- (NSString *)textExtraModelsJsonString{
    NSMutableArray *markArray = [[NSMutableArray alloc] initWithArray:[self.remindedUsers copy]];
    NSArray *strs = [self seperateWith:@[self.textView.text] andMarkArray:markArray];
    NSArray *textExtraModels = [self assembleTextExtraModelsWith:strs];
    
    NSMutableArray *arr = [NSMutableArray new];
    for(TextExtraModel *textExtraModel in textExtraModels){
        NSMutableDictionary *dic = [NSMutableDictionary new];
        if (textExtraModel.userId == nil) {
            [dic setValue:textExtraModel.text forKey:@"text"];
        }
        NSInteger type = textExtraModel.type;
        [dic setValue:[NSNumber numberWithInteger:type] forKey:@"type"];
        [dic setValue:[NSNumber numberWithInteger:textExtraModel.userId] forKey:@"id"];
        [arr addObject:dic];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONReadingAllowFragments error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return json;
}

///返回@的用户id拼接成的字符串
- (NSString *)userIds{
    NSMutableString *_userIds = [NSMutableString new];
    for(OCUserInfoModel *userInfo in _remindedUsers){
        [_userIds appendFormat:@"%d,",userInfo.userId];
    }
    if(_userIds.length > 1){[_userIds replaceCharactersInRange:NSMakeRange(_userIds.length-1, 1) withString:@""];}
    return _userIds;
}

///插入模型
- (void)insertWith:(OCUserInfoModel *)userInfoModel{
    NSMutableString *text = [NSMutableString stringWithFormat:@"%@",self.textView.text];
    NSRange selectedRange = self.textView.selectedRange;
    BOOL isOperationed = NO;
    //判断是否已经存在
    for(OCUserInfoModel *userInfo in _remindedUsers){
        if(userInfo.userId == userInfoModel.userId){
            return;
        }
    }
    //判断光标位置
    for(int i=0;i<self.remindedUsers.count;i++){
        OCUserInfoModel *userInfoModel = _remindedUsers[i];
        NSRange _userRange = [text rangeOfString:userInfoModel.nickName];
        if(selectedRange.length == 0){
            //1.单个一般性位置 ----》直接替换
            //2.单个位于 @人名 中 ----》直接替换并删除@人名的模型
            if((_userRange.location+_userRange.length) > selectedRange.location > _userRange.location){
                [self.remindedUsers removeObjectAtIndex:i];
                [text replaceCharactersInRange:selectedRange withString:userInfoModel.nickName];
                self.textView.text = text;
                self.textView.selectedTextRange = [self textRangeWith:NSMakeRange(selectedRange.location+userInfoModel.nickName.length, 0)];
                isOperationed = YES;
                break;
            }
        }else{
            //3.多个一般性位置 ----》直接替换
            //4.多个包含 @人名 ----》直接替换并删除@人名的模型
            RangeRelationship relationsip = [self checkRelationshipBetween:selectedRange and:_userRange];
            if(relationsip != RangeRelationshipNone){
                [text replaceCharactersInRange:selectedRange withString:userInfoModel.nickName];
                self.textView.text = text;
                self.textView.selectedTextRange = [self textRangeWith:NSMakeRange(selectedRange.location+userInfoModel.nickName.length, 0)];
                isOperationed = YES;
                break;
            }
        }
    }
    if(!isOperationed){
        [text replaceCharactersInRange:selectedRange withString:userInfoModel.nickName];
        self.textView.text = text;
        self.textView.selectedTextRange = [self textRangeWith:NSMakeRange(selectedRange.location+userInfoModel.nickName.length, 0)];
    }
    [self.remindedUsers addObject:userInfoModel];
    //刷新text
    [self refreshTextViewWith:text];
}

- (void)customTextViewClickedDelete:(CustomTextView *)customTextView{
    //判断光标所处位置
    NSMutableString *text = [NSMutableString stringWithFormat:@"%@",self.textView.text];
    NSRange selectedRange = self.textView.selectedRange;
    BOOL isOperationed = NO;
    for(int i=0;i<self.remindedUsers.count;i++){
        OCUserInfoModel *userInfoModel = _remindedUsers[i];
        NSRange _userRange = [text rangeOfString:userInfoModel.nickName];
        if(selectedRange.length == 0){
            //1.单个一般性 ----》直接删
            //2.单个位于 @人名 中 -----》选中 @人名
            if(selectedRange.location > _userRange.location && selectedRange.location < (_userRange.location+_userRange.length)){
                customTextView.selectedTextRange = [self textRangeWith:_userRange];
                isOperationed = YES;
                break;
            }
            //3.单个位于 @人民 后 -----》选中 @人名
            if((_userRange.location+_userRange.length) == selectedRange.location){
                customTextView.selectedTextRange = [self textRangeWith:_userRange];
                isOperationed = YES;
                break;
            }
        }else{
            //4.多个一般性 -----》直接删
            RangeRelationship relationsip = [self checkRelationshipBetween:selectedRange and:_userRange];
            //5.多个位于 @人名 中 -----》选中 @人名
            if(relationsip == RangeRelationshipAIncludedByB){
                customTextView.selectedTextRange = [self textRangeWith:_userRange];
                isOperationed = YES;
                break;
            }
            //6.多个包括但不限于 @人名 ----》直接删
            if(relationsip == RangeRelationshipAIncludedByB || relationsip == RangeRelationshipAEqualB){
                [self.remindedUsers removeObjectAtIndex:i];
                [customTextView manualDelete];
                isOperationed = YES;
                break;
            }
        }
    }
    if (!isOperationed) {
        NSInteger currentLocation = self.textView.selectedRange.location;
        [customTextView manualDelete];
        customTextView.selectedTextRange = [self textRangeWith:NSMakeRange(currentLocation-1, 0)];
    }
    [self refreshTextViewWith:customTextView.text];
}

- (UITextRange *)textRangeWith:(NSRange)range{
    UITextPosition *startDocument = self.textView.beginningOfDocument;
    UITextPosition *start = [self.textView positionFromPosition:startDocument offset:range.location];
    UITextPosition *end = [self.textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self.textView textRangeFromPosition:start toPosition:end];
    return textRange;
}

- (void)refreshTextViewWith:(NSString *)text{
    UITextRange *selectedRange = self.textView.selectedTextRange;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange textRange = [text rangeOfString:text];
    UIColor *color = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:15];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:color forKey:NSForegroundColorAttributeName];
    [dic setObject:font forKey:NSFontAttributeName];
    [attrText addAttributes:dic range:textRange];
    
    for(OCUserInfoModel *userInfoModel in self.remindedUsers){
        NSRange userRange = [text rangeOfString:userInfoModel.nickName];
        UIColor *color = [UIColor redColor];
        UIFont *font = [UIFont systemFontOfSize:18];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:color forKey:NSForegroundColorAttributeName];
        [dic setObject:font forKey:NSFontAttributeName];
        [attrText addAttributes:dic range:userRange];
    }
    self.textView.attributedText = attrText;
    self.textView.selectedTextRange = selectedRange;
    NSLog(@"被@人数目：%d",self.remindedUsers.count);
    for(OCUserInfoModel *userInfoModel in self.remindedUsers){
        NSLog(@"***************\n被@的名字：%@",userInfoModel.nickName);
    }
}

- (RangeRelationship)checkRelationshipBetween:(NSRange)A and:(NSRange)B{
    if(A.location == B.location && A.length == B.length){return RangeRelationshipAEqualB;}
    if(A.location <= B.location && (A.location+A.length)>=(B.location) && (A.location+A.length)<(B.location+B.length)){return RangeRelationshipAInsersectB;}
    if(B.location <= A.location && (B.location+B.length)>=(A.location) && (B.location+B.length)<(A.location+A.length)){return RangeRelationshipAInsersectB;}
    if(A.location <= B.location && (A.location+A.length)>=(B.location+B.length)){return RangeRelationshipAIncludeB;}
    if(B.location <= A.location && (B.location+B.length)>=(A.location+A.length)){return RangeRelationshipAIncludedByB;}
    return RangeRelationshipNone;
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
    UITextRange *position = textView.markedTextRange;
    if([textView positionFromPosition:position.start offset:0]){return;}
    
    
    NSString *preCharacter = [textView.text substringWithRange:NSMakeRange(textView.selectedRange.location-1, 1)];
    NSMutableString *text = [NSMutableString stringWithString:textView.text];
    if([preCharacter isEqualToString:@"@"]){
        [self.delegate aliyunPublishContentEditViewTapedRemind:self];
        [text replaceCharactersInRange:NSMakeRange(textView.selectedRange.location-1, 1) withString:@""];
    }
    self.placeholderLabel.hidden = text.length <= 0 ? NO : YES;
    if (text.length > _maxCharacterNum) {
        textView.text = [text substringToIndex:_maxCharacterNum];
    }else{
        textView.text = text;
    }
    _characterNumberLabel.text = [NSString stringWithFormat:@"%lu/%lu",textView.text.length,_maxCharacterNum];
    [_characterNumberLabel sizeToFit];
    CGRect frame = _characterNumberLabel.frame;
    frame.origin.x = self.frame.size.width-frame.size.width-15;
    frame.origin.y = self.frame.size.height-frame.size.height-10;
    _characterNumberLabel.frame = frame;
    [self refreshTextViewWith:textView.text];
}

@end
