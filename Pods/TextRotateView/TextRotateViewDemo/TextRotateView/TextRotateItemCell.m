//
//  TextRotateItemCell.m
//  TextRotateViewDemo
//
//  Created by dev.liufeng on 2018/6/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "TextRotateItemCell.h"
@interface TextRotateItemCell ()
@property (nonatomic,strong) UILabel *contentLabel;
@end
@implementation TextRotateItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _contentLabel.text = @"";
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

- (void)configWith:(TextModel *)textModel{
    _contentLabel.font = [UIFont systemFontOfSize:textModel.textFont];
    _contentLabel.textColor = textModel.textColor;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.frame = self.bounds;
    _contentLabel.text = textModel.text;
}
@end
