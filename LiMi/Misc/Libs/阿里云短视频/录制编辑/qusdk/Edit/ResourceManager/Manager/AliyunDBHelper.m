//
//  QUDBManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/2.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunDBHelper.h"
#import "FMDB.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectInfo.h"
#import "AliyunEffectModelTransManager.h"
#import "AliyunPathManager.h"

@interface AliyunDBHelper ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) FMDatabase *database;

@end

@implementation AliyunDBHelper

#pragma mark - 创建打开
- (void)openResourceDBSuccess:(void(^)(NSString *path))success
                      failure:(void(^)(NSError *error))failure {

    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        self.database = db;
        if([db open]){
            
            BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS table_allresources (tid integer PRIMARY KEY AUTOINCREMENT, effectType integer, resourcePath text, id integer, configFontId integer, configFontName text, name text, cnName text,fontName text, key text, level integer, category text, url text, md5 text, banner text, icon text, description text, isNew integer, tag text, cat text, previewPic text, previewMp4 text,preview text, duration text, type text, sort text, mvList blob, pasterList blob);"];

            if (result) {
                if (success) {
                    success([self databaseFilePath]);
                }
            }else{
                NSLog(@"create database table failure");
                NSError *error = [NSError errorWithDomain:@"com.qusdk" code:0 userInfo:@{@"errorInfo":@"数据库创建失败"}];
                if (failure) {
                    failure(error);
                }
            }
        } else {
            NSLog(@"open database faliure");
            NSError *error = [NSError errorWithDomain:@"com.qusdk" code:0 userInfo:@{@"errorInfo":@"数据库打开失败"}];
            if (failure) {
                failure(error);
            }
        }
    }];
    
}


#pragma mark - 关闭
- (void)closeDB {
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db close];
        if (result) {
            NSLog(@"close databse success");
        } else {
            NSLog(@"close databse faliure");
        }
    }];
}


#pragma mark - 插入数据
- (void)insertDataWithEffectResourceModel:(AliyunEffectResourceModel *)model {
    
    
    if ([self queryOneResourseWithEffectResourceModel:model]) {
        return;
    }
    
    NSData *mvList = [NSKeyedArchiver archivedDataWithRootObject:model.mvList];
    NSData *pasterList = [NSKeyedArchiver archivedDataWithRootObject:model.pasterList];

    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:@"INSERT INTO table_allresources (effectType, resourcePath, id, name, configFontId, configFontName, cnName, fontName, key, level, category, url, md5, banner, icon, description, isNew, preview, tag, cat, previewPic, previewMp4, duration, type, sort, mvList, pasterList) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", @(model.effectType), model.resourcePath, @(model.eid), model.name, @(model.configFontId), model.configFontName, model.cnName, model.fontName, model.key, @(model.level), model.category, model.url, model.md5, model.banner, model.icon, model.edescription, @(model.isNew), model.preview, model.tag, model.cat,model.previewPic, model.previewMp4, model.duration, model.type, model.sort, mvList, pasterList];

        if (!result) {
            NSLog(@"insert database error");
        }
    }];
}


- (void)insertDataWithEffectInfo:(AliyunEffectInfo *)info {
    
    if ([self queryOneResourseWithEffectInfo:info]) {
        return;
    }
    AliyunEffectResourceModel *resourceModel = [[AliyunEffectModelTransManager manager] transResourceModelWithEffectInfo:info];
    [self insertDataWithEffectResourceModel:resourceModel];
}



#pragma mark - 修改数据
- (void)updateDataWithEffectResourceModel:(AliyunEffectResourceModel *)model {
    
    NSData *mvList = [NSKeyedArchiver archivedDataWithRootObject:model.mvList];
    NSData *pasterList = [NSKeyedArchiver archivedDataWithRootObject:model.pasterList];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:@"UPDATE table_allresources SET resourcePath = ? AND mvList = ? AND pasterList = ? WHERE effectType = ? AND id = ? AND name = ?", model.resourcePath, mvList, pasterList, @(model.effectType), @(model.eid), model.name];
        
        if (!result) {
            NSLog(@"update database error");
        }
    }];

}


#pragma mark - 删除数据
-(void)deleteDatabase {
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DROP TABLE IF EXISTS table_allresources;"];
    }];
    
}

- (void)deleteDataWithEffectResourceModel:(AliyunEffectResourceModel *)model {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"DELETE FROM table_allresources WHERE effectType = ? AND id = ? AND name = ?", @(model.effectType), @(model.eid), model.name];
        
        if (!result) {
            NSLog(@"delete database faliure");
        }
    }];
}


#pragma mark - 查询数据
- (BOOL)queryOneResourseWithEffectResourceModel:(AliyunEffectResourceModel *)model {
    
    if ([self.database open]) {
        FMResultSet *resultSet = [self.database executeQuery:@"SELECT * FROM table_allresources WHERE effectType = ? AND id = ? AND name = ?", @(model.effectType), @(model.eid), model.name];
        while ([resultSet next]) {
            NSInteger tid = [resultSet intForColumn:@"tid"];
            if (tid > 0) {
                // 二次效验 如果resourcePath不存在，则认为该资源不存在
                NSString *resourcePath = [NSHomeDirectory() stringByAppendingPathComponent:[resultSet stringForColumn:@"resourcePath"]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
                    return NO;
                }
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}


- (BOOL)queryOneResourseWithEffectInfo:(AliyunEffectInfo *)info {
    
    if ([self.database open]) {
        FMResultSet *resultSet = [self.database executeQuery:@"SELECT * FROM table_allresources WHERE effectType = ? AND id = ? AND name = ?", @(info.effectType), @(info.eid), info.name];
        while ([resultSet next]) {
            NSInteger tid = [resultSet intForColumn:@"tid"];
            if (tid > 0) {
                // 二次效验 如果resourcePath不存在，则认为该资源不存在
                NSString *resourcePath = [NSHomeDirectory() stringByAppendingPathComponent:[resultSet stringForColumn:@"resourcePath"]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
                    return NO;
                }
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}


- (AliyunEffectInfo *)queryEffectInfoWithEffectType:(NSInteger)effectType
                                        effctId:(NSInteger)effectId {
    
    if ([self.database open]) {
        FMResultSet *resultSet = [self.database executeQuery:@"SELECT * FROM table_allresources WHERE effectType = ? AND id = ?", @(effectType), @(effectId)];
        while ([resultSet next]) {
            NSInteger tid = [resultSet intForColumn:@"tid"];
            if (tid > 0) {
                AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] init];
                
                model.effectType  = [resultSet intForColumn:@"effectType"];
                model.eid         = [resultSet intForColumn:@"id"];
                model.level       = [resultSet intForColumn:@"level"];
                model.fontName    = [resultSet stringForColumn:@"fontName"];
                model.configFontId= [resultSet intForColumn:@"configFontId"];
                model.configFontName = [resultSet stringForColumn:@"configFontName"];
                
                model.name        = [resultSet stringForColumn:@"name"];
                model.url         = [resultSet stringForColumn:@"url"];
                model.md5         = [resultSet stringForColumn:@"md5"];
                model.banner      = [resultSet stringForColumn:@"banner"];
                model.icon        = [resultSet stringForColumn:@"icon"];
                model.edescription= [resultSet stringForColumn:@"description"];
                model.type        = [resultSet stringForColumn:@"type"];
                model.sort        = [resultSet stringForColumn:@"sort"];
                model.resourcePath= [resultSet stringForColumn:@"resourcePath"];
                
                AliyunEffectInfo *infoModel = [[AliyunEffectModelTransManager manager] transEffectInfoModelWithResourceModel:model];
                return infoModel;
            }
        }
        return nil;
    } else {
        return nil;
    }
}


- (void)queryAllResourcesWithEffectType:(NSInteger)type
                                success:(void(^)(NSArray *resourceArray))success
                                faliure:(void(^)(NSError *error))failure {
    
    [self queryWithType:type isbackResourceModel:YES success:^(NSArray *resourceArray) {
        
        success(resourceArray);
        
    } faliure:^(NSError *error) {
        failure(error);
    }];
}



- (void)queryResourceWithEffecInfoType:(NSInteger)infoType
                               success:(void(^)(NSArray *infoModelArray))success
                               failure:(void(^)(NSError *error))failure {
    
    [self queryWithType:infoType isbackResourceModel:NO success:^(NSArray *resourceArray) {
       
        success(resourceArray);
        
    } faliure:^(NSError *error) {
        failure(error);
    }];
}


// 私有方法

/**
 查询

 @param type 查询资源的type
 @param isResourceModel 是否返回大类AliyunEffectResourceModel YES:AliyunEffectResourceModel NO:QUEffecInfo
 @param success 成功
 @param failure 失败
 */
- (void)queryWithType:(NSInteger)type
  isbackResourceModel:(BOOL)isResourceModel
              success:(void(^)(NSArray *resourceArray))success
              faliure:(void(^)(NSError *error))failure{
    
    NSMutableArray *resourceArray = [[NSMutableArray alloc] init];
    // 1.执行查询语句
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM table_allresources WHERE effectType = ?", @(type)];
            // 2.遍历结果
            while ([resultSet next]) {
                NSInteger tid = [resultSet intForColumn:@"tid"];
                if (tid <= 0) {
                    success(resourceArray);
                    return;
                }
                
                AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] init];
                
                model.effectType  = [resultSet intForColumn:@"effectType"];
                model.eid         = [resultSet intForColumn:@"id"];
                model.level       = [resultSet intForColumn:@"level"];
                model.isNew       = [resultSet intForColumn:@"isNew"];
                model.fontName    = [resultSet stringForColumn:@"fontName"];
                model.configFontId= [resultSet intForColumn:@"configFontId"];
                model.configFontName = [resultSet stringForColumn:@"configFontName"];
                
                model.name        = [resultSet stringForColumn:@"name"];
                model.cnName      = [resultSet stringForColumn:@"cnName"];
                model.key         = [resultSet stringForColumn:@"key"];
                model.url         = [resultSet stringForColumn:@"url"];
                model.md5         = [resultSet stringForColumn:@"md5"];
                model.banner      = [resultSet stringForColumn:@"banner"];
                model.icon        = [resultSet stringForColumn:@"icon"];
                model.edescription= [resultSet stringForColumn:@"description"];
                model.preview     = [resultSet stringForColumn:@"preview"];
                model.tag         = [resultSet stringForColumn:@"tag"];
                model.cat         = [resultSet stringForColumn:@"cat"];
                model.previewPic  = [resultSet stringForColumn:@"previewPic"];
                model.previewMp4  = [resultSet stringForColumn:@"previewMp4"];
                model.preview     = [resultSet stringForColumn:@"preview"];
                model.duration    = [resultSet stringForColumn:@"duration"];
                model.type        = [resultSet stringForColumn:@"type"];
                model.sort        = [resultSet stringForColumn:@"sort"];
                model.resourcePath= [resultSet stringForColumn:@"resourcePath"];
                
                model.mvList      = [NSKeyedUnarchiver unarchiveObjectWithData:[resultSet dataForColumn:@"mvList"]];
                model.pasterList  = [NSKeyedUnarchiver unarchiveObjectWithData:[resultSet dataForColumn:@"pasterList"]];
                
                if (isResourceModel) {
                    // 如果返回的是大类 则不需要model转换
                    [resourceArray addObject:model];
                } else {
                    AliyunEffectInfo *infoModel = [[AliyunEffectModelTransManager manager] transEffectInfoModelWithResourceModel:model];
                    [resourceArray addObject:infoModel];
                }
            }
            
            success(resourceArray);
            
        } else {
            NSError *error = [NSError errorWithDomain:@"com.qusdk" code:0 userInfo:@{@"errorInfo":@"数据库打开失败"}];
            failure(error);
        }
        
    }];
 
}

#pragma mark - 文件路径
- (NSString *)databaseFilePath {
    
    NSString *path = [[AliyunPathManager createResourceDir] stringByAppendingPathComponent:@"Database"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *dbPath = [[path stringByAppendingPathComponent:@"QUDatabase"] stringByAppendingPathExtension:@"sqlite"];
    
    return dbPath;

}


#pragma mark - Set
- (FMDatabaseQueue *)databaseQueue {
    
    if (!_databaseQueue) {
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath: [self databaseFilePath]];
    }
    return _databaseQueue;
}

@end
