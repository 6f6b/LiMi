#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QiniuFile.h"
#import "QiniuInputStream.h"
#import "QiniuMultipartElement.h"
#import "QiniuToken.h"
#import "QiniuUploader.h"
#import "QUMBase64.h"
#import "QUMDefines.h"
#import "ALAssetsLibrary+POS.h"
#import "NSInputStream+POS.h"
#import "POSAdjustedAssetReaderIOS7.h"
#import "POSAdjustedAssetReaderIOS8.h"
#import "POSAssetReader.h"
#import "POSBlobInputStream.h"
#import "POSBlobInputStreamAssetDataSource.h"
#import "POSBlobInputStreamDataSource.h"
#import "POSFastAssetReader.h"
#import "POSInputStreamLibrary.h"
#import "POSLocking.h"

FOUNDATION_EXPORT double QiniuUploadVersionNumber;
FOUNDATION_EXPORT const unsigned char QiniuUploadVersionString[];

