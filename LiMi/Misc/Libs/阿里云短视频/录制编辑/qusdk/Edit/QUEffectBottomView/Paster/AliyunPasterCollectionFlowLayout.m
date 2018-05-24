//
//  GiftListCollectionViewFlowLayout.m
//  qupailive
//
//  Created by TripleL on 16/11/14.
//  Copyright © 2016年 qupai. All rights reserved.
//

#import "AliyunPasterCollectionFlowLayout.h"


@interface AliyunPasterCollectionFlowLayout ()

// 每行item个数
@property (nonatomic) NSUInteger itemCountPerRow;
// 行数
@property (nonatomic) NSUInteger rowCount;

@end

@implementation AliyunPasterCollectionFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.rowCount = 2;
    self.itemCountPerRow = 5;
}

- (CGSize)collectionViewContentSize
{
    // 计算所有item的最大X坐标值
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat maxX = (itemCount / (self.itemCountPerRow * self.rowCount) + 1) * self.collectionView.frame.size.width;
    CGSize contenSize = [super collectionViewContentSize];
    contenSize.width = maxX;
    return contenSize;
}


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        NSInteger index = attr.indexPath.row;
        
        // 计算当前item在哪一页
        NSInteger currentPerPage = index / (self.itemCountPerRow * self.rowCount);
        
        //  计算item在当前页中的相对index
        NSInteger currentRelativeIndex = index % (self.itemCountPerRow * self.rowCount);
        
        // 计算当前item应该放置在哪一行
        NSInteger currentCell = currentRelativeIndex / self.itemCountPerRow;
        
        // 计算当前item在当前这一行中的位置
        NSInteger currentCellRow = currentRelativeIndex  - (self.itemCountPerRow * currentCell);
        
        CGRect tmpFrame = attr.frame;
        tmpFrame.origin.x = currentCellRow * attr.frame.size.width + currentPerPage * self.collectionView.frame.size.width;
        tmpFrame.origin.y = currentCell * attr.frame.size.height;
        
        attr.frame = tmpFrame;
        [tmp addObject:attr];
        
    }
    return tmp;
    
    
}


@end
