//
//  AliyunEffectManagerViewController.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectManagerViewController.h"
#import "AliyunEffectManagerView.h"
#import "AliyunEffectMoreTableViewCell.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectPrestoreManager.h"

NSString * const AliyunEffectResourceDeleteNoti = @"AliyunEffectResourceDeleteNoti";

// 管理的素材类别 0: 字体 1: 动图 2:imv 3:音乐 4:字幕
// 警告⚠️ : 和EffectMore界面的顺序不一样的 目前没有滤镜资源需要管理
typedef NS_ENUM(NSInteger, AliyunManagerType){
    AliyunManagerTypeFont = 0,
    AliyunManagerTypePaster = 1,
    AliyunManagerTypeMV = 2,
    AliyunManagerTypeCaption = 3,
};

@interface AliyunEffectManagerViewController () <AliyunEffectManagerViewDelegate, UITableViewDataSource, UITableViewDelegate, AliyunEffectMoreTableViewCellDelegate>

@property (nonatomic, strong) AliyunEffectManagerView *managerView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

@property (nonatomic, assign) AliyunEffectType effectType;

@end

@implementation AliyunEffectManagerViewController

- (void)loadView {
    
    self.managerView = [[AliyunEffectManagerView alloc] initWithSelectSegmentType:[self transEffectTypeToManagerType:self.effectType] frame:[[UIScreen mainScreen] bounds]];
    self.managerView.delegate = self;
    [self.managerView setTableViewDelegates:self];
    self.view = self.managerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;

    [self fetchDataWithType:self.effectType];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (instancetype)initWithManagerType:(AliyunEffectType)type {
    
    self = [[AliyunEffectManagerViewController alloc] init];
    if (self) {
        _effectType = type;
    }
    return self;
}


#pragma mark - Tools

- (AliyunManagerType)transEffectTypeToManagerType:(AliyunEffectType)effectType {
    
    if (effectType <= 3) {
        return effectType - 1;
    } else {
        return effectType - 3;
    }
}

- (AliyunEffectType)transManagerTypeToEffectType:(AliyunManagerType)effectType {
    
    if (effectType < 3) {
        return effectType + 1;
    } else {
        return effectType + 3;
    }
}

#pragma mark - Database
- (void)fetchDataWithType:(NSInteger)type {
    
    [self.dataArray removeAllObjects];
    [self.dbHelper queryAllResourcesWithEffectType:type success:^(NSArray *resourceArray) {
        
        for (AliyunEffectResourceModel *model in resourceArray) {
            // 系统字体不添加到管理
            if (model.eid != -2) {
                [self.dataArray addObject:model];
            }
        }
        [self.managerView.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
        
    } faliure:^(NSError *error) {
        
    }];
}

#pragma mark - AliyunEffectManagerViewDelegate
- (void)segmentClickChangedWithIndex:(NSInteger)currentIndex title:(NSString *)currentTitle {
    
    [self fetchDataWithType:[self transManagerTypeToEffectType:currentIndex]];
    
}

- (void)onClickBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EffectManagerTableViewIndentifier];
    
    if (indexPath.row >= self.dataArray.count) {
        return cell;
    }
    
    AliyunEffectResourceModel *model = self.dataArray[indexPath.row];
    [cell setEffectResourceModel:model];
    cell.buttontType = EffectTableViewButtonDelete;
    cell.delegate = self;
    
    return cell;
}


#pragma mark - EffectMoreTableViewCellDelegate
- (void)onClickFuncButtonWithCell:(AliyunEffectMoreTableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.managerView.tableView indexPathForCell:cell];
    NSInteger index = indexPath.row;
    AliyunEffectResourceModel *model = self.dataArray[index];
    
    [self.dbHelper deleteDataWithEffectResourceModel:model];
    
    NSString *filePath = [[model storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%@", model.eid, model.name]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    if (model.effectType == self.effectType) {
        // 数据变更  上级界面需要重载数据
        [self.delegate deleteResourceWithModel:model];
    }
    
    [self.dataArray removeObjectAtIndex:index];
    
    // post Notification to EditController
    [self postDeleteNotificationWithDeleteModel:model];
    
    [self.managerView.tableView reloadData];
    
}

#pragma mark - Notification
- (void)postDeleteNotificationWithDeleteModel:(AliyunEffectResourceModel *)model {
    
    NSMutableArray *deleteResourcepaths = [[NSMutableArray alloc] init];
    
    if (model.effectType == AliyunEffectTypePaster || model.effectType == AliyunEffectTypeCaption) {
        for (AliyunEffectPasterInfo *pasterInfo in model.pasterList) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:pasterInfo.resourcePath];
            [deleteResourcepaths addObject:path];
        }
    } else {
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:model.resourcePath];
        [deleteResourcepaths addObject:path];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AliyunEffectResourceDeleteNoti object:deleteResourcepaths];
}

- (NSMutableArray *)dataArray {
    
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (AliyunDBHelper *)dbHelper {
    
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
