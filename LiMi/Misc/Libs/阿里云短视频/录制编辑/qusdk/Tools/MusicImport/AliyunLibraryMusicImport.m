//
//  AliyunLibraryMusicImport.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunLibraryMusicImport.h"
#import <AVFoundation/AVFoundation.h>

@interface AliyunLibraryMusicImport()

+ (BOOL)validIpodLibraryURL:(NSURL*)url;
- (void)extractQuicktimeMovie:(NSURL*)movieURL toFile:(NSURL*)destURL;

@end


@implementation AliyunLibraryMusicImport

+ (BOOL)validIpodLibraryURL:(NSURL*)url {
	NSString* IPOD_SCHEME = @"ipod-library";
	if (nil == url) return NO;
	if (nil == url.scheme) return NO;
	if ([url.scheme compare:IPOD_SCHEME] != NSOrderedSame) return NO;
	if ([url.pathExtension compare:@"mp3"] != NSOrderedSame &&
		[url.pathExtension compare:@"aif"] != NSOrderedSame &&
		[url.pathExtension compare:@"m4a"] != NSOrderedSame &&
		[url.pathExtension compare:@"wav"] != NSOrderedSame) {
		return NO;
	}
	return YES;
}

+ (NSString*)extensionForAssetURL:(NSURL*)assetURL {
    if (nil == assetURL) {
        return nil;
    }
    if (![AliyunLibraryMusicImport validIpodLibraryURL:assetURL]) {
        return nil;
    }
	return assetURL.pathExtension;
}

- (void)doMp3ImportToFile:(NSURL*)destURL completionBlock:(void (^)(AliyunLibraryMusicImport* import))completionBlock {
	//TODO: instead of putting this in the same directory as the dest file, we should probably stuff
	//this in tmp
	NSURL* tmpURL = [[destURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"mov"];
	[[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
	exportSession.outputURL = tmpURL;
	
	exportSession.outputFileType = AVFileTypeQuickTimeMovie;
	[exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
		if (exportSession.status == AVAssetExportSessionStatusFailed) {
			completionBlock(self);
		} else if (exportSession.status == AVAssetExportSessionStatusCancelled) {
			completionBlock(self);
		} else {
			@try {
				[self extractQuicktimeMovie:tmpURL toFile:destURL];
			}
			@catch (NSException * e) {
				OSStatus code = noErr;
				if ([e.name compare:QUUnknownError]) code = kQUUnknownError;
				else if ([e.name compare:QUFileExistsError]) code = kQUFileExistsError;
				NSDictionary* errorDict = [NSDictionary dictionaryWithObject:e.reason forKey:NSLocalizedDescriptionKey];
				
				movieFileErr = [[NSError alloc] initWithDomain:QULibraryImportErrorDomain code:code userInfo:errorDict];
			}
			//clean up the tmp .mov file
			[[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
			completionBlock(self);
		}
		
		exportSession = nil;
	}];	
}

- (void)importAsset:(NSURL*)assetURL toURL:(NSURL*)destURL completionBlock:(void (^)(AliyunLibraryMusicImport* import))completionBlock {
    if (nil == assetURL || nil == destURL) {
        return;
    }
    if (![AliyunLibraryMusicImport validIpodLibraryURL:assetURL]) {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[destURL path]]) {
        return;
    }
	
	NSDictionary * options = [[NSDictionary alloc] init];
	AVURLAsset* asset = [AVURLAsset URLAssetWithURL:assetURL options:options];	
    if (nil == asset) {
        return;
    }
        
	exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    if (nil == exportSession) {
        return;
    }
	if ([[assetURL pathExtension] compare:@"mp3"] == NSOrderedSame) {
		[self doMp3ImportToFile:destURL completionBlock:completionBlock];
		return;
	}

	exportSession.outputURL = destURL;
	NSLog(@"destURL = %@",destURL);
	// set the output file type appropriately based on asset URL extension
	if ([[assetURL pathExtension] compare:@"m4a"] == NSOrderedSame) {
		exportSession.outputFileType = AVFileTypeAppleM4A;
	} else if ([[assetURL pathExtension] compare:@"wav"] == NSOrderedSame) {
		exportSession.outputFileType = AVFileTypeWAVE;
	} else if ([[assetURL pathExtension] compare:@"aif"] == NSOrderedSame) {
		exportSession.outputFileType = AVFileTypeAIFF;
	} else {
		
	}

	[exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
		completionBlock(self);
		
		exportSession = nil;
	}];
}

- (void)extractQuicktimeMovie:(NSURL*)movieURL toFile:(NSURL*)destURL {
	FILE* src = fopen([[movieURL path] cStringUsingEncoding:NSUTF8StringEncoding], "r");
	if (NULL == src) {
		return;
	}
	char atom_name[5];
	atom_name[4] = '\0';
	unsigned long atom_size = 0;
	while (true) {
		if (feof(src)) {
			break;
		}
		fread((void*)&atom_size, 4, 1, src);
		fread(atom_name, 4, 1, src);
		atom_size = ntohl(atom_size);
        const size_t bufferSize = 1024*100;
		if (strcmp("mdat", atom_name) == 0) {
			FILE* dst = fopen([[destURL path] cStringUsingEncoding:NSUTF8StringEncoding], "w");
			unsigned char buf[bufferSize];
			if (NULL == dst) {
				fclose(src);
                return;
			}
            // Thanks to Rolf Nilsson/Roni Music for pointing out the bug here:
            // Quicktime atom size field includes the 8 bytes of the header itself.
            atom_size -= 8;
            while (atom_size != 0) {
                size_t read_size = (bufferSize < atom_size)?bufferSize:atom_size;
                if (fread(buf, read_size, 1, src) == 1) {
                    fwrite(buf, read_size, 1, dst);
                }
                atom_size -= read_size;
            }
			fclose(dst);
			fclose(src);
			return;
		}
		if (atom_size == 0)
			break; //0 atom size means to the end of file... if it's not the mdat chunk, we're done
		fseek(src, atom_size, SEEK_CUR);
	}
	fclose(src);
}

- (NSError*)error {
	if (movieFileErr) {
		return movieFileErr;
	}
	return exportSession.error;
}

- (AVAssetExportSessionStatus)status {
	if (movieFileErr) {
		return AVAssetExportSessionStatusFailed;
	}
	return exportSession.status;
}

- (float)progress {
	return exportSession.progress;
}

@end
