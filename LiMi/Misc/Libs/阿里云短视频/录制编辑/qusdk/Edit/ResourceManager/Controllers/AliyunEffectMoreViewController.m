//
//  AliyunEffectMoreViewController.h.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMoreViewController.h"
#import "AliyunEffectMoreView.h"
#import "AliyunEffectMoreTableViewCell.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectManagerViewController.h"
#import "AliyunResourceRequestManager.h"
#import "AliyunResourceDownloadManager.h"
#import "AliyunEffectModelTransManager.h"
#import "AliyunEffectInfo.h"
#import "AliyunResourceFontRequest.h"
#import "AliyunEffectMorePreviewCell.h"


@interface AliyunEffectMoreViewController () <AliyunEffectMoreViewDelegate, UITableViewDataSource, UITableViewDelegate, AliyunEffectMoreTableViewCellDelegate, AliyunEffectMorePreviewCellDelegate, AliyunEffectManagerViewControllerDelegate>

@property (nonatomic, strong) AliyunEffectMoreView *effectMoreView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

@property (nonatomic, assign) AliyunEffectType effectType;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation AliyunEffectMoreViewController

- (void)loadView {
    
    self.effectMoreView = [[AliyunEffectMoreView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.effectMoreView.delegate = self;
    [self.effectMoreView setTableViewDelegates:self];
    self.view = self.effectMoreView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.effectMoreView setTitleWithEffectType:self.effectType];
    
    [self.dbHelper openResourceDBSuccess:nil failure:nil];
    
    [self fetchListData];
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (instancetype)initWithEffectType:(AliyunEffectType)type {
    
    self = [[AliyunEffectMoreViewController alloc] init];
    if (self) {
        _effectType = type;
    }
    return self;
}

#pragma mark - Data
- (void)fetchListData {

    __weak __typeof (self)weakSelf = self;
    [weakSelf.dataArray removeAllObjects];
    [AliyunResourceRequestManager requestWithEffectTypeTag:self.effectType success:^(NSArray *resourceListArray) {
        
        for (NSDictionary *resourceDic in resourceListArray) {
            
            AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:resourceDic error:nil];
            [model setValue:@(weakSelf.effectType) forKey:@"effectType"];
            
            BOOL isContain = [weakSelf.dbHelper queryOneResourseWithEffectResourceModel:model];
            [model setValue:@(isContain) forKey:@"isDBContain"];

            if (isContain) {
                // 已经下载了的 放在最上面
                [weakSelf.dataArray insertObject:model atIndex:0];
            } else {
                [weakSelf.dataArray addObject:model];
            }
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.effectMoreView.tableView reloadData];
        });
        
    } failure:^(NSError *error) {
        
        // 请求失败时加载本地数据
        NSLog(@"资源列表请求失败:%@", error);
        [self.dbHelper queryAllResourcesWithEffectType:weakSelf.effectType success:^(NSArray *resourceArray) {
            
            for (AliyunEffectResourceModel *model in resourceArray) {
                [model setValue:@(weakSelf.effectType) forKey:@"effectType"];
                [model setValue:@(1) forKey:@"isDBContain"];
                [weakSelf.dataArray addObject:model];
            }
            [self.effectMoreView.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
            
        } faliure:nil];
    }];
}

#pragma mark - AliyunEffectManagerViewControllerDelegate
- (void)deleteResourceWithModel:(AliyunEffectResourceModel *)model {
    
    for (AliyunEffectResourceModel *resourceModel in self.dataArray) {
        if (resourceModel.eid == model.eid) {
            NSInteger index = [self.dataArray indexOfObject:resourceModel];
            AliyunEffectMoreTableViewCell *cell = [self.effectMoreView.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [cell setButtontType:(EffectTableViewButtonDownload)];
        }
    }
    
}

#pragma mark - AliyunEffectManagerViewDelegate
- (void)onClickBackButton {
    
    [self stopPreviewLastCell];
    [self closeWithEffectModel:nil];
}

- (void)onClickNextButton {
    
    AliyunEffectManagerViewController *managerVC = [[AliyunEffectManagerViewController alloc] initWithManagerType:self.effectType];
    managerVC.delegate = self;
    [self.navigationController pushViewController:managerVC animated:YES];
}


#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    AliyunEffectResourceModel *model = self.dataArray[indexPath.row];
    
    if ([indexPath isEqual:self.selectIndexPath]) {
        AliyunEffectMorePreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:EffectMorePreviewTableViewIndentifier forIndexPath:indexPath];
        cell.delegate= self;
        [cell setEffectModel:model];
        return cell;
    } else {
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@%ld", EffectMoreTableViewIndentifier, indexPath.row];
        AliyunEffectMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[AliyunEffectMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setEffectResourceModel:model];
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:self.selectIndexPath]) {
        return SizeHeight(300);
    }
    return SizeHeight(74);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self stopPreviewLastCell];
    
    NSMutableArray *indePaths = [NSMutableArray array];
    if (self.selectIndexPath) {
        [indePaths addObject:self.selectIndexPath];
    }
    if (![self.selectIndexPath isEqual:indexPath]) {
        [indePaths addObject:indexPath];
    }
    
    self.selectIndexPath = indexPath;
    
    [tableView reloadRowsAtIndexPaths:indePaths withRowAnimation:(UITableViewRowAnimationFade)];

}


#pragma mark - EffectMoreTableViewCellDelegate
- (void)onClickFuncButtonWithCell:(AliyunEffectMoreTableViewCell *)cell {
    NSLog(@"click download/use button");
    NSIndexPath *indexPath = [self.effectMoreView.tableView indexPathForCell:cell];
    AliyunEffectResourceModel *model = self.dataArray[indexPath.row];
    
    if (cell.buttontType == EffectTableViewButtonDownload) {
        // 下载
        cell.funcButton.userInteractionEnabled = NO;
        AliyunResourceDownloadTask *task = [[AliyunResourceDownloadTask alloc] initWithModel:model];
        AliyunResourceDownloadManager *manager = [[AliyunResourceDownloadManager alloc] init];
        
        [manager addDownloadTask:task progress:^(CGFloat progress) {
            
            [cell updateDownlaodProgress:progress];
            
        } completionHandler:^(AliyunEffectResourceModel *newModel, NSError *error) {
            
            if (error) {
                [cell updateDownloadFaliure];
            } else {
                self.dataArray[indexPath.row] = newModel;
                [self.dbHelper insertDataWithEffectResourceModel:newModel];
            }
        }];
        
    } else {
        // 使用该资源
        [self closeWithEffectModel:model];
    }
}

#pragma mark - AliyunEffectMorePreviewViewDelegate
- (void)onClickPreviewCell:(AliyunEffectMorePreviewCell *)cell {
    
//    NSIndexPath *indexPath = [self.effectMoreView.tableView indexPathForCell:cell];
    NSArray *indexPaths = @[self.selectIndexPath];
    self.selectIndexPath = nil;
    [self.effectMoreView.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationFade)];
}


#pragma mark - UI
- (void)closeWithEffectModel:(AliyunEffectResourceModel *)model {
    
    [self.dbHelper closeDB];
    AliyunEffectInfo *infoModel = [[AliyunEffectModelTransManager manager] transEffectInfoModelWithResourceModel:model];
    
    if (self.effectMoreCallback) {
        self.effectMoreCallback(infoModel);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopPreviewLastCell {
    
    AliyunEffectMorePreviewCell *lastCell = [self.effectMoreView.tableView cellForRowAtIndexPath:self.selectIndexPath];
    if (lastCell) {
        [lastCell stopPreview];
    }
}


#pragma mark - Setter
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
