//
//  AliyunPublishContentEditView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunPublishContentEditView : UIView
@property (nonatomic,copy) NSString *placeholder;
@property (nonatomic,assign) NSInteger maxCharacterNum;
@property (nonatomic,readonly) NSString *content;
@end
