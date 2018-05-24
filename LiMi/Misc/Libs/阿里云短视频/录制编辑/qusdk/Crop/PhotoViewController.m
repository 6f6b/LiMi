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

@interface PhotoViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, strong) AliyunAlbumModel *selectModel;
@property (nonatomic, strong) NSMutableArray<AliyunAssetModel *> *libraryDataArray;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    
    NSString *videoSavePath = [[[AliyunPathManager createCutDir] stringByAppendingPathComponent:[AliyunPathManager uuidString]] stringByAppendingPathExtension:@"mp4"];
    NSString *taskPath = [AliyunPathManager createCutDir];
    _cutInfo.outputPath = videoSavePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
    }
    
    self.photoCollectionView.alwaysBounceVertical = YES;
    [self.photoCollectionView registerClass:[AliyunPhotoListViewCell class] forCellWithReuseIdentifier:@"AliyunPhotoListViewCell"];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.backgroundColor = [UIColor clearColor];
    self.photoCollectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden=YES;
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
        VideoDurationRange duration = {_cutInfo.minDuration, _cutInfo.maxDuration};
        BOOL videoOnly = self.cutInfo.videoOnly;
        [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:YES allowPickingImage:!videoOnly durationRange:duration completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount) {
            [self reloadCollocation:models];
        }];
    } else {
        [[AliyunPhotoLibraryManager sharedManager] requestAuthorization:^(BOOL authorization) {
            if (authorization) {
                VideoDurationRange duration = {0, 0};
                
                BOOL videoOnly = self.cutInfo.videoOnly;
                
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
    if (model.type == AliyunAssetModelMediaTypeVideo) {
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:model.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            [QUMBProgressHUD hideHUDForView:self.view animated:YES];
            _cutInfo.startTime = 0.f;
            _cutInfo.endTime = 0.f;
            _cutInfo.sourceDuration = 0.f;
            _cutInfo.avAsset = avAsset;
            _cutInfo.phAsset = nil;
            _cutInfo.phImage = nil;
            if (!_cutInfo.outputPath) {
                _cutInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cutVideo.mp4"];
            }
            NSURL *url = (NSURL *)[[(AVURLAsset *)avAsset URL] fileReferenceURL];
            _cutInfo.sourcePath = url.path;
            AliyunCropViewController *cut = [[AliyunCropViewController alloc] init];
            cut.cutInfo = _cutInfo;
            cut.delegate = (id<AliyunCropViewControllerDelegate>)self;
            [self.navigationController pushViewController:cut animated:YES];
        }];
    } else {
        [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:model.asset thumbnailWidth:200 completion:^(UIImage *image, UIImage *thumbnailImage, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [QUMBProgressHUD hideHUDForView:self.view animated:YES];
                _cutInfo.phAsset = model.asset;
                _cutInfo.phImage = image;
                AliyunCropViewController *cut = [[AliyunCropViewController alloc] init];
                cut.cutInfo = _cutInfo;
                cut.delegate = (id<AliyunCropViewControllerDelegate>)self;
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

#pragma mark -  AliyunCropViewControllerDelegate
- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller {
    //    [self.navigationController popViewControllerAnimated:YES];
    if (mediaInfo.phAsset) {//图片资源
            [self cropFinished:controller mediaType:kPhotoMediaTypePhoto photo:mediaInfo.phImage videoPath:nil];
    } else {
        [self cropFinished:controller videoPath:mediaInfo.outputPath sourcePath:mediaInfo.sourcePath];
    }
    //Refresh
    [self fetchPhotoData];
}

/**/
- (void)recodBtnClick:(UIViewController *)vc{
    [self.delegate recodBtnClick];
}

- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath{
    AliyunEditViewController *editVC = (AliyunEditViewController *)AliyunMediator.shared.editViewController;
    editVC.taskPath = videoPath;
    editVC.config = self.cutInfo;
    [self.navigationController pushViewController:editVC animated:true];
}

/**
 裁剪完成回调，裁剪对象有两种：视频或者图片
 
 @param cropViewController 裁剪viewController
 @param type 媒体类型
 @param photo 如果媒体类型是图像，则返回裁剪出来的图像，否则返回nil
 @param videoPath 如果媒体类型是视频，则返回裁剪出来的视频路径，否则返回nil
 */
- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath{

}

- (void)backBtnClick:(UIViewController *)vc{
    
}
@end
