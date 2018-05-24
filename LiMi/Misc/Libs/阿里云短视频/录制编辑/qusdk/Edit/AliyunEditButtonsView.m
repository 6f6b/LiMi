//
//  AliyunEditButtonsView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditButtonsView.h"

@implementation AliyunEditButtonsView
{
    NSArray *_btnImageNames;
    NSArray *_btnSelNames;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //滤镜 动图 字幕 MV 音乐 涂鸦
        _btnImageNames = @[@"btn_texiao",
                           @"meiyan",
//                           @"QPSDK.bundle/edit_subtitle.png",
//                           @"QPSDK.bundle/edit_mv.png",
                           @"music.png",
//                           @"QPSDK.bundle/edit_paint.png"
                           ];
        _btnSelNames = @[@"filterButtonClicked:",
                         @"pasterButtonClicked:",
//                         @"subtitleButtonClicked:",
//                         @"mvButtonClicked:",
                         @"musicButtonClicked:",
//                         @"paintButtonClicked:"
                         ];
        [self addButtons];
        self.backgroundColor = UIColor.clearColor;
        //self.backgroundColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:1];
    }
    return self;
}

- (void)addButtons {
    CGFloat dlt = CGRectGetWidth(self.bounds) / ([_btnSelNames count] + 1);
    CGFloat cy = self.bounds.size.height / 2;
    
    for (int idx = 0; idx < [_btnImageNames count]; idx++) {
        NSString *imageName = [_btnImageNames objectAtIndex:idx];
        NSString *selName = [_btnSelNames objectAtIndex:idx];
        SEL sel = NSSelectorFromString(selName);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 24, 24);
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self addSubview:btn];
        btn.center = CGPointMake((idx+1) * dlt, cy);
    }
    
}

- (void)filterButtonClicked:(id)sender {
    [self.delegate animationFilterButtonClicked];
    //[self.delegate filterButtonClicked:AliyunEditButtonTypeFilter];
}

- (void)pasterButtonClicked:(id)sender {
    [self.delegate pasterButtonClicked];
    [self.delegate filterButtonClicked];
}

- (void)subtitleButtonClicked:(id)sender {
    [self.delegate subtitleButtonClicked];
}

- (void)mvButtonClicked:(id)sender {
    [self.delegate mvButtonClicked:AliyunEditButtonTypeMV];
}

- (void)musicButtonClicked:(id)sender {
    [self.delegate musicButtonClicked];
}

- (void)paintButtonClicked:(id)sender {
 
    [self.delegate paintButtonClicked];
}

@end
