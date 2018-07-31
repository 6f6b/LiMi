//
//  AliyunPublishContentEditView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextView.h"
#import "OCUserInfoModel.h"
@class AliyunPublishContentEditView;

@protocol AliyunPublishContentEditViewDelegate<NSObject>
- (void)aliyunPublishContentEditViewTapedRemind:(AliyunPublishContentEditView *)editView;
- (void)aliyunPublishContentEditViewDeleteWith:(NSInteger)userId;
- (NSArray *)aliyunPublishContentEditViewCurrentUserModels;
@end
@interface AliyunPublishContentEditView : UIView
@property (nonatomic,copy) NSString *placeholder;
@property (nonatomic,assign) NSInteger maxCharacterNum;
@property (nonatomic,readonly) NSString *content;
@property (nonatomic,strong) CustomTextView *textView;
@property (nonatomic,weak) id<AliyunPublishContentEditViewDelegate> delegate;

- (void)insertWith:(OCUserInfoModel *)userInfoModel;

///返回字段数组json
- (NSString *)textExtraModelsJsonString;
///返回@的用户id拼接成的字符串
- (NSString *)userIds;
@end
