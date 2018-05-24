//
//  QUDBManager.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/2.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AliyunEffectResourceModel;
@class AliyunEffectInfo;

@interface AliyunDBHelper : NSObject


/**
 打开数据库

 @param success 成功回调
 @param failure 失败回调
 */
- (void)openResourceDBSuccess:(void(^)(NSString *path))success
                      failure:(void(^)(NSError *error))failure;

/**
 添加数据AliyunEffectResourceModel

 @param model AliyunEffectResourceModel
 */
- (void)insertDataWithEffectResourceModel:(AliyunEffectResourceModel *)model;



/**
 添加数据AliyunEffectInfo

 @param info AliyunEffectInfo
 */
- (void)insertDataWithEffectInfo:(AliyunEffectInfo *)info;


/**
 删除数据

 @param model 资源model
 */
- (void)deleteDataWithEffectResourceModel:(AliyunEffectResourceModel *)model;



/**
 修改数据

 @param model 资源model
 */
- (void)updateDataWithEffectResourceModel:(AliyunEffectResourceModel *)model;


/**
 查找某类型资源的全部数据 该方法返回的是大类AliyunEffectResourceModel

 @param type 素材类别 参考EffectMoreController的AliyunEffectType注释
 @param success 成功回调 资源数组
 @param failure 失败回调
 */
- (void)queryAllResourcesWithEffectType:(NSInteger)type
                                success:(void(^)(NSArray *resourceArray))success
                                faliure:(void(^)(NSError *error))failure;

/**
 查询某一个资源是否在数据库中AliyunEffectResourceModel

 @param model AliyunEffectResourceModel
 @return 是否存在于数据库
 */
- (BOOL)queryOneResourseWithEffectResourceModel:(AliyunEffectResourceModel *)model;



/**
 查询某一个资源是否在数据库中AliyunEffectInfo

 @param info AliyunEffectInfo
 @return 是否存在于数据库
 */
- (BOOL)queryOneResourseWithEffectInfo:(AliyunEffectInfo *)info;




/**
 查询某单个AliyunEffectInfo数据

 @param effectType 数据类型
 @param effectId id
 @return 有数据返回AliyunEffectInfo 无数据返回nil
 */
- (AliyunEffectInfo *)queryEffectInfoWithEffectType:(NSInteger)effectType
                                        effctId:(NSInteger)effectId;



/**
 查询某类别素材的全部数据 改方法会返回对应的AliyunEffectInfo

 @param infoType 查询类别type 1: 字体 2: 动图 3:imv 4:滤镜 5:音乐 6:字幕
 @param success 成功回调
 @param failure 失败回调
 */
- (void)queryResourceWithEffecInfoType:(NSInteger)infoType
                               success:(void(^)(NSArray *infoModelArray))success
                               failure:(void(^)(NSError *error))failure;



/**
 关闭数据库
 */
- (void)closeDB;

@end
