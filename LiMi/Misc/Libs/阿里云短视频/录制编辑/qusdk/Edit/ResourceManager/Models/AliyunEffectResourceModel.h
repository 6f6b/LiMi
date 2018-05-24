//
//  AliyunEffectResourceModel.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "JSONModel.h"
#import "AliyunEffectMvInfo.h"
#import "AliyunEffectPasterInfo.h"

//素材类别 1: 字体 2: 动图 3:imv 4:滤镜 5:音乐 6:字幕
typedef NS_ENUM(NSInteger, AliyunEffectType){
    AliyunEffectTypeFont = 1,
    AliyunEffectTypePaster = 2,
    AliyunEffectTypeMV = 3,
    AliyunEffectTypeFilter = 4,
    AliyunEffectTypeMusic = 5,
    AliyunEffectTypeCaption = 6,
};


@interface AliyunEffectResourceModel : JSONModel

/*
 * Local
 */

//素材类别
@property (nonatomic, assign) AliyunEffectType effectType;
// 用于判断数据库是否包含该资源
@property (nonatomic, assign) BOOL isDBContain;
// 资源路径
@property (nonatomic, copy) NSString *resourcePath;
// 字体在字体库中的名称
@property (nonatomic, copy) NSString *fontName;
// 字幕在config中的字体id
@property (nonatomic, assign) NSInteger configFontId;
// 字幕在config中的字体name
@property (nonatomic, copy) NSString *configFontName;


/*
 * 以下均为server返回字段
 */

// id
@property (nonatomic, assign) NSInteger eid;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) NSInteger level;

// 名称
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cnName;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *category;
// 下载路径 动图 MV 字幕等在第二层
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *banner;
@property (nonatomic, copy) NSString *icon;
// 描述
@property (nonatomic, copy) NSString *edescription;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *cat;
@property (nonatomic, copy) NSString *previewPic;
@property (nonatomic, copy) NSString *previewMp4;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSArray <AliyunEffectMvInfo> *mvList;
@property (nonatomic, copy) NSArray <AliyunEffectPasterInfo> *pasterList;


//
- (NSString *)storageFullPath;
- (NSString *)storageDirectory;
+ (NSString *)storageDirectoryWithEffectType:(AliyunEffectType)type;


+ (NSString *)effectNameByPath:(NSString *)path;
+ (id)effectIdByPath:(NSString *)path;

@end
