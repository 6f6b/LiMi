//
//  OCTools.h
//  LiMi
//
//  Created by dev.liufeng on 2018/7/11.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCTools : NSObject
+(NSString *) getConstellationInfo:(NSDate *)date ;
+ (NSInteger)getAge:(NSDate *)date;
@end
