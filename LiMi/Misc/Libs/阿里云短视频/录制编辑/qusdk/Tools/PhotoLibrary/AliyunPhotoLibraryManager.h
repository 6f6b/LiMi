//
//  AliyunPhotoLibraryManager.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "AliyunAlbumModel.h"


typedef struct VideoDurationRange {
    int min;
    int max;
} VideoDurationRange; // {0,0}为不限时长

@interface AliyunPhotoLibraryManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

/**
 对照片排序
 
 YES 默认
 NO  最新的照片会显示在最前面
 */
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

+ (instancetype)sharedManager;

/**
 相册授权

 @return Return YES if Authorized
 */
- (BOOL)authorizationStatusAuthorized;

- (void)requestAuthorization:(void (^)(BOOL authorization))completion;

/**
    Get Album 获得相册/相册数组
 */
- (void)getAllAlbums:(BOOL)allowPickingVideo
   allowPickingImage:(BOOL)allowPickingImage
       durationRange:(VideoDurationRange)range
          completion:(void (^)(NSArray<AliyunAlbumModel *> *models))completion;

/// Get Assets 获得Asset数组
- (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<AliyunAssetModel *> *models))completion;

- (void)getAssetFromFetchResult:(PHFetchResult *)result
                        atIndex:(NSInteger)index
              allowPickingVideo:(BOOL)allowPickingVideo
              allowPickingImage:(BOOL)allowPickingImage
                     completion:(void (^)(AliyunAssetModel *model))completion;

- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailImage:(BOOL)isThumbnail
               photoWidth:(CGFloat)photoWidth
               completion:(void (^)(UIImage *, NSDictionary *))completion;

/**
 将asset转为image图片

 @param asset asset
 @param completion 完成的回调
 */
- (void)getPhotoWithAsset:(PHAsset *)asset thumbnailWidth:(CGFloat)width completion:(void (^)(UIImage *image, UIImage *thumbnailImage, NSDictionary *info))completion;

- (PHImageRequestID)getPhotoWithAsset:(id)asset
                           photoWidth:(CGFloat)photoWidth
                           completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
                      progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
                 networkAccessAllowed:(BOOL)networkAccessAllowed;


/**
 获取相册封面
 */
- (void)getPostImageWithAlbumModel:(AliyunAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;

/**
 获取相机胶卷中的资源
 */
- (void)getCameraRollAssetWithallowPickingVideo:(BOOL)allowPickingVideo
                         allowPickingImage:(BOOL)allowPickingImage
                                  durationRange:(VideoDurationRange)range
                                completion:(void (^)(NSArray<AliyunAssetModel *> *models, NSInteger videoCount))completion;

/**
 获取视频实例
 */
- (void)getVideoWithAsset:(PHAsset *)asset
               completion:(void (^)(AVAsset * avAsset, NSDictionary * info))completion;

/**
 保存视频到相册
 */
- (void)saveVideoAtUrl:(NSURL *)videoURL
           toAlbumName:(NSString *)albumName
            completion:(void (^)(NSError *error))completion;
@end
