//
//  AliyunCompositionPickCell.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompositionPickCell.h"

@implementation AliyunCompositionPickCell
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
    self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.labelDuration.textColor = [UIColor whiteColor];
    self.labelDuration.textAlignment = NSTextAlignmentRight;
    self.labelDuration.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:self.labelDuration];
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[AliyunImage imageNamed:@"import_delete"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat border = 10;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.imageView.frame = CGRectMake(border, border, width-2*border, height-2*border);
    self.labelDuration.frame = CGRectMake(border, height-border-10, width-2*border, 10);
    self.closeButton.frame = CGRectMake(width-2*border, 0, 2*border, 2*border);
}

- (void)closeButtonClicked {
    [_delegate pickCellWillClose:self];
}

@end
