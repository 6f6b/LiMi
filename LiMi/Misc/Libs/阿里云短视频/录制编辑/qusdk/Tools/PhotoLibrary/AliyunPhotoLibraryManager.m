//
//  AliyunPhotoLibraryManager.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPhotoLibraryManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;

static BOOL iOS9Later;
//static CGSize kAssetGridThumbnailSize;
//static CGFloat kQUScreenWidth;
static CGFloat kQUScreenScale;

@interface AliyunPhotoLibraryManager ()

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@end

@implementation AliyunPhotoLibraryManager

+ (instancetype)sharedManager {
    static AliyunPhotoLibraryManager *mg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mg = [[self alloc] init];
        mg.cachingImageManager = [[PHCachingImageManager alloc] init];
        iOS9Later = ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f);
        kQUScreenScale = 2.0;
    });
    return mg;
}

- (BOOL)authorizationStatusAuthorized {
    return [self authorizationStatus] == 3;
}

- (NSInteger)authorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

- (void)requestAuthorization:(void (^)(BOOL authorization))completion {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == 3) {
            completion(YES);
        }
    }];
}

#pragma mark --- 保存资源
- (void)savePhotoWithImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    if (iOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
    } else {
        [self.assetLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:[self orientationFromImage:image] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"保存图片失败:%@",error.localizedDescription);
                if (completion) {
                    completion(error);
                }
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        }];
    }
}

- (void)saveVideoAtUrl:(NSURL *)videoURL toAlbumName:(NSString *)albumName completion:(void (^)(NSError *error))completion {
    [self saveVideoAtUrl:videoURL completion:completion];
}

- (void)saveVideoAtUrl:(NSURL *)videoURL completion:(void (^)(NSError *error))completion {
    if (iOS9Later) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    NSLog(@"保存成功");
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存视频失败:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
    } else {
        [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"保存视频失败:%@",error.localizedDescription);
                if (completion) {
                    completion(error);
                }
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"保存成功");
                    if (completion) {
                        completion(nil);
                    }
                });
            }
        }];
    }
}

#pragma mark --- 获取具体资源

- (void)getPhotoWithAsset:(PHAsset *)asset
           thumbnailImage:(BOOL)isThumbnail
               photoWidth:(CGFloat)photoWidth
               completion:(void (^)(UIImage *, NSDictionary *))completion {
    
        
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize size;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    PHImageContentMode contentMode = 0;
    if (isThumbnail) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat dimension = photoWidth;
        size = CGSizeMake(dimension * scale, dimension * scale);
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        contentMode = 1;
    } else {
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {

        };
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = photoWidth * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        size = CGSizeMake(pixelWidth, pixelHeight);
        contentMode = PHImageContentModeAspectFit;
    }
    
    if (phAsset.representsBurst) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
        fetchOptions.includeAllBurstAssets = YES;
        PHFetchResult *burstSequence = [PHAsset fetchAssetsWithBurstIdentifier:phAsset.burstIdentifier options:fetchOptions];
        phAsset = burstSequence.firstObject;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:size contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//        if (downloadFinished) {
            completion(result,info);
//        }
    }];
}


- (void)getPhotoWithAsset:(PHAsset *)asset thumbnailWidth:(CGFloat)width completion:(void (^)(UIImage *image, UIImage *thumbnailImage, NSDictionary *info))completion {
    PHAsset *phAsset = (PHAsset *)asset;
    CGSize size = CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = width;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize thumbnailSize = CGSizeMake(pixelWidth, pixelHeight);

    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset
                                               targetSize:size
                                              contentMode:PHImageContentModeDefault
                                                  options:requestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            
            @autoreleasepool {
                UIImage *thumbnailImage = [self imageWithImage:result scaledToSize:thumbnailSize];
                completion(result, thumbnailImage, info);
            }
        }
    }];
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *, BOOL))completion progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    
    {
        CGSize imageSize;
//        if (photoWidth < kQUScreenWidth && photoWidth < _photoPreviewMaxWidth) {
//            imageSize = kAssetGridThumbnailSize;
//        } else {
            PHAsset *phAsset = (PHAsset *)asset       ;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * kQUScreenScale;
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
//        }
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
//                result = [self fixOrientation:result];
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            // Download image from iCloud / 从iCloud下载图片
//            if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
//                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (progressHandler) {
//                            progressHandler(progress, error, stop, info);
//                        }
//                    });
//                };
//                options.networkAccessAllowed = YES;
//                options.resizeMode = PHImageRequestOptionsResizeModeFast;
//                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
//                    resultImage = [self scaleImage:resultImage toSize:imageSize];
//                    if (resultImage) {
//                        resultImage = [self fixOrientation:resultImage];
//                        if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
//                    }
//                }];
//            }
        }];
        return imageRequestID;
    }
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion {
    return [self getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

#pragma mark --- 获取相册资源

// 相册封面
- (void)getPostImageWithAlbumModel:(AliyunAlbumModel *)model completion:(void (^)(UIImage *))completion {
    PHAsset *asset = [model.fetchResult lastObject];
    if (!self.sortAscendingByModificationDate) {
        asset = [model.fetchResult firstObject];
    }
    [self getPhotoWithAsset:asset photoWidth:80 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion) completion(photo);
    }];
}

- (void)getCameraRollAssetWithallowPickingVideo:(BOOL)allowPickingVideo
                         allowPickingImage:(BOOL)allowPickingImage
                                  durationRange:(VideoDurationRange)range
                                completion:(void (^)(NSArray<AliyunAssetModel *> *models, NSInteger videoCount))completion {
    NSInteger videoCount;
    __block NSArray *photoArray;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

    option.predicate = [self configurePredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo range:range];
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:option];
    videoCount = [fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    [self getAssetsFromFetchResult:fetchResult allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage completion:^(NSArray<AliyunAssetModel *> *models) {
        photoArray = (NSArray *)models;
    }];
    if (completion) {
        completion(photoArray,videoCount);
    }
}

- (void)getAllAlbums:(BOOL)allowPickingVideo
   allowPickingImage:(BOOL)allowPickingImage
       durationRange:(VideoDurationRange)range
          completion:(void (^)(NSArray<AliyunAlbumModel *> *models))completion {
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    
    option.predicate = [self configurePredicateWithAllowImage:allowPickingImage allowVideo:allowPickingVideo range:range];
    
    if (!self.sortAscendingByModificationDate) {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
   
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {

            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                AliyunAlbumModel *model = [[AliyunAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                [albumArr insertObject:model atIndex:0];
            } else {
                AliyunAlbumModel *model = [[AliyunAlbumModel alloc] initWithFetchResult:fetchResult albumName:collection.localizedTitle];
                [albumArr addObject:model];
            }
        }
    }
    if (completion && albumArr.count > 0) completion(albumArr);
}

- (void)getAssetsFromFetchResult:(PHFetchResult *)fetchResult
               allowPickingVideo:(BOOL)allowPickingVideo
               allowPickingImage:(BOOL)allowPickingImage
                      completion:(void (^)(NSArray<AliyunAssetModel *> *models))completion {
    NSMutableArray *photoArr = [NSMutableArray array];
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AliyunAssetModel *model = [self assetModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) completion(photoArr);
}

- (void)getAssetFromFetchResult:(PHFetchResult *)result
                        atIndex:(NSInteger)index
              allowPickingVideo:(BOOL)allowPickingVideo
              allowPickingImage:(BOOL)allowPickingImage
                     completion:(void (^)(AliyunAssetModel *model))completion {
    
    PHAsset *asset;
    @try {
        asset = result[index];
    }
    @catch (NSException* e) {
        if (completion) completion(nil);
        return;
    }
    AliyunAssetModel *model = [self assetModelWithAsset:asset allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
    if (completion) completion(model);
}

- (void)getVideoWithAsset:(PHAsset *)asset
               completion:(void (^)(AVAsset * avAsset, NSDictionary * info))completion {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
    };
    PHAsset *phAsset = (PHAsset *)asset;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if(([asset isKindOfClass:[AVComposition class]] && ((AVComposition *)asset).tracks.count == 2)){
            //slow motion videos. See Here: https://overflow.buffer.com/2016/02/29/slow-motion-video-ios/
            
            //Output URL of the slow motion file.
            NSString *root = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
             NSString *tempDir = [root stringByAppendingString:@"/com.sdk.demo/temp"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *myPathDocs =  [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeSlowMoVideo-%d.mov",arc4random() % 1000]];
            NSURL *url = [NSURL fileURLWithPath:myPathDocs];
            //Begin slow mo video export
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                        NSURL *URL = exporter.outputURL;
                        AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(asset, nil);
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, exporter.error);
                        });
                    }
                });
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(asset, nil);
            });
        }
    }];
}

- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"]
            || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"]
            || [albumName isEqualToString:@"相机胶卷"]
            || [albumName isEqualToString:@"所有照片"]
            || [albumName isEqualToString:@"All Photos"];
    }
}

- (AliyunAssetModel *)assetModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage {
    AliyunAssetModel *model;
    AliyunAssetModelMediaType type = AliyunAssetModelMediaTypePhoto;
    
    PHAsset *phAsset = (PHAsset *)asset;
    if (phAsset.mediaType == PHAssetMediaTypeVideo)      type = AliyunAssetModelMediaTypeVideo;
    else if (phAsset.mediaType == PHAssetMediaTypeAudio) type = AliyunAssetModelMediaTypeAudio;
    else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = AliyunAssetModelMediaTypePhotoGif;
        }
    }

    if (!allowPickingImage && type == AliyunAssetModelMediaTypePhotoGif) return nil;
    
    if (self.hideWhenCanNotSelect) {
        if (![self isPhotoSelectableWithAsset:phAsset]) {
            return nil;
        }
    }
    model = [AliyunAssetModel modelWithAsset:asset type:type];
    return model;
}

- (BOOL)isPhotoSelectableWithAsset:(id)asset {
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height) {
        return NO;
    }
    return YES;
}

- (CGSize)photoSizeWithAsset:(id)asset {
    PHAsset *phAsset = (PHAsset *)asset;
    return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
}

- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

- (NSPredicate *)configurePredicateWithAllowImage:(BOOL)image allowVideo:(BOOL)video range:(VideoDurationRange)range {
    NSPredicate *predicate;
    
    
    NSString *imageFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    NSString *videoFormat = [NSString stringWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    if (range.min >= 0 && range.max > 0) {
        NSString *rangeForamt = [NSString stringWithFormat:@" && duration >= %d && duration <= %d",range.min, range.max];
        videoFormat = [videoFormat stringByAppendingString:rangeForamt];
    }
    if (image && !video) {
        predicate = [NSPredicate predicateWithFormat:imageFormat];
    } else if (video && !image) {
        predicate = [NSPredicate predicateWithFormat:videoFormat];
    } else if (video && image) {
        NSString *imageAndVideo = [NSString stringWithFormat:@"%@ || (%@)", videoFormat, imageFormat];
        predicate = [NSPredicate predicateWithFormat:imageAndVideo];
    }
    return predicate;
}

- (ALAssetOrientation)orientationFromImage:(UIImage *)image {
    NSInteger orientation = image.imageOrientation;
    return orientation;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
//    if (!self.shouldFixOrientation) return aImage;
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
