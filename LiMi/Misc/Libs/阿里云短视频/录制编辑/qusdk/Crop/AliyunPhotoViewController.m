 //
//  AliyunPhotoViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPhotoViewController.h"
#import "AliyunPhotoLibraryManager.h"
#import "AliyunPhotoListViewCell.h"
#import "AliyunPhotoAssetSelectedView.h"
#import "AliyunAlbumViewController.h"
#import "AliyunCropViewController.h"
#import "AliyunIConfig.h"
#import "QUMBProgressHUD.h"

@interface AliyunPhotoViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) UIButton *buttonTitle;
@property (nonatomic, strong) UIButton *buttonBack;
@property (nonatomic, strong) AliyunAlbumModel *selectModel;

@property (nonatomic, strong) NSMutableArray<AliyunAssetModel *> *libraryDataArray;

@end

@implementation AliyunPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubViews];
    
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    if (self.selectModel) {
        [self updateNavigationTitle:self.selectModel.albumName];
        [self reloadLibraryWithIndex:self.selectModel];
        return;
    }
    [self updateNavigationTitle:@"相机胶卷"];
    [self fetchPhotoData];
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)setupSubViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.view.backgroundColor = [AliyunIConfig config].backgroundColor;
    
    self.buttonBack = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonBack.frame = CGRectMake(0, StatusBarHeight, 44, 44);
    [self.buttonBack setTitle:@"取消" forState:(UIControlStateNormal)];
    [self.buttonBack.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    self.buttonBack.titleLabel.contentMode = UIViewContentModeCenter;
    [self.buttonBack addTarget:self action:@selector(buttonBackClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.buttonBack];
    
    self.buttonTitle = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonTitle.frame = CGRectMake(0, StatusBarHeight, 180, 44);
    [self.buttonTitle.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    self.buttonTitle.titleLabel.contentMode = UIViewContentModeCenter;
    [self.buttonTitle setImage:[AliyunImage imageNamed:@"roll_list"] forState:(UIControlStateNormal)];
    self.buttonTitle.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, StatusBarHeight + 44 / 2);
    [self.view addSubview:self.buttonTitle];
    [self.buttonTitle addTarget:self action:@selector(buttonAlbumClick:) forControlEvents:(UIControlEventTouchUpInside)];
    
    

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 4.0;
    layout.minimumInteritemSpacing = 4.0;
    
    self.photoCollectionView = [[UICollectionView alloc] initWithFrame:(CGRectMake(0, 44+StatusBarHeight, screenWidth, screenHeight - StatusBarHeight - 44-SafeBottom)) collectionViewLayout:layout];
    self.photoCollectionView.alwaysBounceVertical = YES;
    [self.photoCollectionView registerClass:[AliyunPhotoListViewCell class] forCellWithReuseIdentifier:@"AliyunPhotoListViewCell"];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.backgroundColor = [UIColor clearColor];
    self.photoCollectionView.dataSource = self;
    [self.view addSubview:self.photoCollectionView];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cropViewControllerExit {
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller {
//    [self.navigationController popViewControllerAnimated:YES];
    if (mediaInfo.phAsset) {//图片资源
        if (self.delegate) {
            [self.delegate cropFinished:controller mediaType:kPhotoMediaTypePhoto photo:mediaInfo.phImage videoPath:nil];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cropFinished:videoPath:sourcePath:)]) {
            [self.delegate cropFinished:controller videoPath:mediaInfo.outputPath sourcePath:mediaInfo.sourcePath];
        }
    }
    //Refresh
    [self fetchPhotoData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunAssetModel *model = _libraryDataArray[indexPath.row];
    if (model.type == AliyunAssetModelMediaTypeToRecod) {
        if (_delegate) {
            [_delegate recodBtnClick:self];
        }
        
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - (4 * 3)) / 4;
    return CGSizeMake(width, width);
}

- (void)buttonBackClick:(id)sender {
    if (self.delegate) {
        [self.delegate backBtnClick:self];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonAlbumClick:(id)sender {
    AliyunAlbumViewController *albumViewController = [[AliyunAlbumViewController alloc] init];
    albumViewController.albumTitle = _buttonTitle.currentTitle;
    VideoDurationRange range = {_cutInfo.minDuration, _cutInfo.maxDuration};
    albumViewController.videoRange = range;
    albumViewController.videoOnly = self.cutInfo.videoOnly;
    albumViewController.selectBlock = ^(AliyunAlbumModel *albumModel) {
        self.selectModel = albumModel;
    };
    [self.navigationController pushViewController:albumViewController animated:NO];
}

- (void)updateNavigationTitle:(NSString *)title {
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(180, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_buttonTitle.titleLabel.font} context:nil].size;
    [_buttonTitle setTitle:title forState:0];
    [_buttonTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, -12 - 4, 0, 12 + 4)];
    [_buttonTitle setImageEdgeInsets:UIEdgeInsetsMake(0, size.width + 4, 0, -size.width - 4)];
}

- (void)appWillEnterForeground:(NSNotification *)noti {
    [self updateNavigationTitle:@"相机胶卷"];
    [self fetchPhotoData];
}

@end
