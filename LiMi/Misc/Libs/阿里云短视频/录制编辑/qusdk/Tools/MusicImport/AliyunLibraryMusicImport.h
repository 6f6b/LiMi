//
//  AliyunLibraryMusicImport.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#define QULibraryImportErrorDomain @"QULibraryImportErrorDomain"

#define QUUnknownError @"QUUnknownError"
#define QUFileExistsError @"QUFileExistsError"

#define kQUUnknownError -65536
#define kQUFileExistsError -48 //dupFNErr



@class AVAssetExportSession;

@interface AliyunLibraryMusicImport : NSObject {
	AVAssetExportSession* exportSession;
	NSError* movieFileErr;
}

/**
 * Pass in the NSURL* you get from an MPMediaItem's 
 * MPMediaItemPropertyAssetURL property to get the file's extension.
 *
 * Helpful in constructing the destination url for the
 * imported file.
 */
+ (NSString*)extensionForAssetURL:(NSURL*)assetURL;


- (void)importAsset:(NSURL*)assetURL toURL:(NSURL*)destURL completionBlock:(void (^)(AliyunLibraryMusicImport* import))completionBlock;

@property (readonly) NSError* error;
@property (readonly) AVAssetExportSessionStatus status;
@property (readonly) float progress;

@end
