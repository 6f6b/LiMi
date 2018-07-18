//
//  TextRotateView.m
//  TextRotateViewDemo
//
//  Created by dev.liufeng on 2018/6/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "TextRotateView.h"
#import "TextRotateItemCell.h"

typedef enum : NSUInteger {
    TextRotateViewStateInIdel,
    TextRotateViewStateInPlaying,
    TextRotateViewStateInPause,
    TextRotateViewStateInStop
} TextRotateViewState;
@interface TextRotateView()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic,strong)  NSArray *textModels;
@property (nonatomic,assign) TextRotateViewState state;
@end
@implementation TextRotateView

- (instancetype)initWithFrame:(CGRect)frame textModels:(NSArray *)textModels{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if(self = [super initWithFrame:frame collectionViewLayout:flowLayout]){
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.state = TextRotateViewStateInIdel;
        _textModels = textModels;
        _rotateRate = (CGFloat)20;
        _horizontalSpacing = (CGFloat)10;
        [self registerClass:[TextRotateItemCell class] forCellWithReuseIdentifier:@"TextRotateItemCell"];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

/**
 启动
 */
- (void)start{
    if(self.state == TextRotateViewStateInPlaying){return;}
    self.state = TextRotateViewStateInPlaying;
    [self animation];
}

/**
 停止
 */
- (void)stop{
    if(self.state == TextRotateViewStateInStop){return;}
    self.state = TextRotateViewStateInStop;
    [self.layer removeAllAnimations];
    self.contentOffset = CGPointMake(0, 0);
}

/**
 暂停
 */
- (void)pause{
    if(self.state == TextRotateViewStateInPause){return;}
    self.state = TextRotateViewStateInPause;
    [self.layer removeAllAnimations];
}

/**
 恢复
 */
- (void)resume{
    if(self.state == TextRotateViewStateInPlaying){return;}
    self.state = TextRotateViewStateInPlaying;
    [self animation];
}

- (void)animation{
    __weak TextRotateView *weakSelf = self;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGPoint offset = weakSelf.contentOffset;
        offset.x += weakSelf.rotateRate;
        weakSelf.contentOffset = offset;
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSLog(@"finished:%d",finished);
        if(finished){
            [weakSelf animation];
        }
    }];
}

#pragma mark UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource
- (NSInteger)numberOfSections{return 1;}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TextRotateItemCell *textRotateItemCell = [self dequeueReusableCellWithReuseIdentifier:@"TextRotateItemCell" forIndexPath:indexPath];
    NSInteger index = indexPath.row % _textModels.count;
    TextModel *textModel = self.textModels[index];
    [textRotateItemCell configWith:textModel];
    return textRotateItemCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row % _textModels.count;
    TextModel *textModel = self.textModels[index];
    return CGSizeMake(textModel.textSize.width, self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return _horizontalSpacing;
}
@end
