
//
//  PhotoViewController.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/24.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "PhotoViewController.h"
#import "AliyunPhotoLibraryManager.h"
#import "AliyunPhotoListViewCell.h"
#import "AliyunPhotoAssetSelectedView.h"
#import "AliyunAlbumViewController.h"
#import "AliyunCropViewController.h"
#import "AliyunIConfig.h"
#import "QUMBProgressHUD.h"
#import "AliyunEditViewController.h"
#import "AliyunMediator.h"
#import "AliyunMediaConfig.h"
#import "AliyunPathManager.h"
#import <AliyunVideoSDKPro/AliyunImporter.h>

@interface PhotoViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, strong) AliyunAlbumModel *selectModel;
@property (nonatomic, strong) NSMutableArray<AliyunAssetModel *> *libraryDataArray;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];

    
    self.photoCollectionView.alwaysBounceVertical = YES;
    [self.photoCollectionView registerClass:[AliyunPhotoListViewCell class] forCellWithReuseIdentifier:@"AliyunPhotoListViewCell"];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.backgroundColor = [UIColor clearColor];
    self.photoCollectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
//    if (self.selectModel) {
//        [self updateNavigationTitle:self.selectModel.albumName];
//        [self reloadLibraryWithIndex:self.selectModel];
//        return;
//    }
//    [self updateNavigationTitle:@"相机胶卷"];
    [self fetchPhotoData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (IBAction)cancelButtonClicked:(id)sender {
    [self.delegate cancelButtonClicked];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)appWillEnterForeground:(NSNotification *)noti {
    [self fetchPhotoData];
}

- (void)fetchPhotoData {
    if ([[AliyunPhotoLibraryManager sharedManager] authorizationStatusAuthorized]) {
        VideoDurationRange duration = {_minDuration, _maxDuration};
        BOOL videoOnly = true;
        [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:YES allowPickingImage:!videoOnly durationRange:duration completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount) {
            [self reloadCollocation:models];
        }];
    } else {
        [[AliyunPhotoLibraryManager sharedManager] requestAuthorization:^(BOOL authorization) {
            if (authorization) {
                VideoDurationRange duration = {0, 0};
                
                BOOL videoOnly = true;
                
                [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:YES allowPickingImage:!videoOnly durationRange:duration completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self reloadCollocation:models];
                    });
                }];
            }
        }];
    }
}

- (void)reloadCollocation:(NSArray<AliyunAssetModel *> *)libArry {
    if (!_libraryDataArray) {
        _libraryDataArray = [[NSMutableArray alloc]init];
    }else{
        [_libraryDataArray removeAllObjects];
    }
    if ([AliyunIConfig config].showCameraButton) {
        AliyunAssetModel *model = [[AliyunAssetModel alloc]init];
        model.type = AliyunAssetModelMediaTypeToRecod;
        model.thumbnailImage = [AliyunImage imageNamed:@"import_to_record"];
        [_libraryDataArray addObject:model];
    }
    
    [_libraryDataArray addObjectsFromArray:libArry];
    
    [_photoCollectionView reloadData];
}

- (void)reloadLibraryWithIndex:(AliyunAlbumModel *)model {
    
    [[AliyunPhotoLibraryManager sharedManager] getAssetsFromFetchResult:model.fetchResult allowPickingVideo:YES allowPickingImage:NO completion:^(NSArray<AliyunAssetModel *> *models) {
        [self reloadCollocation:models];
        self.selectModel = nil;
    }];
}

#pragma mark - collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunAssetModel *model = _libraryDataArray[indexPath.row];
    if (model.type == AliyunAssetModelMediaTypeToRecod) {
        [self recodBtnClick:self];
        return;
    }
    [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
    AliyunMediaConfig *cutInfo = [[AliyunMediaConfig alloc] init];
    
    NSString *videoSavePath = [[[AliyunPathManager createCutDir] stringByAppendingPathComponent:[AliyunPathManager uuidString]] stringByAppendingPathExtension:@"mp4"];
    NSString *taskPath = [AliyunPathManager createCutDir];
    [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:taskPath withIntermediateDirectories:YES attributes:nil error:nil];
    cutInfo.outputPath = videoSavePath;
    cutInfo.minDuration = _minDuration;
    cutInfo.maxDuration = _maxDuration;
    cutInfo.outputSize = CGSizeMake(model.asset.pixelWidth, model.asset.pixelHeight);
    cutInfo.cutMode = AliyunMediaCutModeScaleAspectCut;
    cutInfo.backgroundColor = UIColor.blackColor;
    if (model.type == AliyunAssetModelMediaTypeVideo) {
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:model.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            [QUMBProgressHUD hideHUDForView:self.view animated:YES];
            cutInfo.startTime = 0.f;
            cutInfo.endTime = 0.f;
            cutInfo.sourceDuration = 0.f;
            cutInfo.avAsset = avAsset;
            cutInfo.phAsset = nil;
            cutInfo.phImage = nil;
            
//            let screenScale = UIScreen.main.scale
//            let height = Int(1920)/2*2
//            let width = Int(1080)/2*2
//            quVideo.bitrate = Int32(3.87*screenScale*CGFloat(width*height))
            
            cutInfo.bitrate = 15000000;
            cutInfo.fps = 30;
            if (!cutInfo.outputPath) {
                cutInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cutVideo.mp4"];
            }
            NSURL *url = (NSURL *)[[(AVURLAsset *)avAsset URL] fileReferenceURL];
            cutInfo.sourcePath = url.path;
            AliyunCropViewController *cut = [[AliyunCropViewController alloc] init];
            cut.cutInfo = cutInfo;
//            cut.delegate = (id<AliyunCropViewControllerDelegate>)self;
            [self.navigationController pushViewController:cut animated:YES];
        }];
    } else {
        [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:model.asset thumbnailWidth:200 completion:^(UIImage *image, UIImage *thumbnailImage, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [QUMBProgressHUD hideHUDForView:self.view animated:YES];
                cutInfo.phAsset = model.asset;
                cutInfo.phImage = image;
                AliyunCropViewController *cut = [[AliyunCropViewController alloc] init];
                cut.cutInfo = cutInfo;
//                cut.delegate = (id<AliyunCropViewControllerDelegate>)self;
                [self.navigationController pushViewController:cut animated:YES];
            });
        }];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _libraryDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AliyunPhotoListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPhotoListViewCell" forIndexPath:indexPath];
    if (indexPath.row < self.libraryDataArray.count) {
        cell.assetModel = self.libraryDataArray[indexPath.row];
    }
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 3;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - (4 * 2)-1) / 3;
    return CGSizeMake(width, width);
}

- (void)cropViewControllerExit {
    //    [self.navigationController popViewControllerAnimated:YES];
}


/**/
- (void)recodBtnClick:(UIViewController *)vc{
    [self.delegate recodBtnClick];
}

- (void)backBtnClick:(UIViewController *)vc{
    
}
@end
