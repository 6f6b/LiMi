//
//  TextExtraModel.h
//  LiMi
//
//  Created by dev.liufeng on 2018/7/31.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    TextExtraModelTypeNormal,
    TextExtraModelTypeRemined
}TextExtraModelType;
@interface TextExtraModel : NSObject
@property (nonatomic,assign) NSInteger userId;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) TextExtraModelType type;
@property (nonatomic,assign) NSInteger location;
@end
