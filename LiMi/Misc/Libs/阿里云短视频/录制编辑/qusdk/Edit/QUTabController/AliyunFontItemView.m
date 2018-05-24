//
//  AliyunFontItemView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunFontItemView.h"
#import "AliyunFontItemCell.h"
#import "AliyunEffectFontInfo.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectFontManager.h"

@interface AliyunFontItemView ()

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AliyunFontItemView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview];
        [self setupData];
    }
    return self;
}

- (void)addSubview
{
    
    self.backgroundColor = RGBToColor(27, 33, 51);

    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(ScreenWidth / 4, ScreenWidth / 4);
    followLayout.minimumLineSpacing = 0;
    followLayout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SizeHeight(4), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) collectionViewLayout:followLayout];
    [self addSubview:self.collectionView];
    self.collectionView.delegate = (id)self;
    self.collectionView.dataSource = (id)self;
    self.collectionView.backgroundColor = RGBToColor(27, 33, 51);
    [self.collectionView registerNib:[UINib nibWithNibName:@"AliyunFontItemCell" bundle:nil] forCellWithReuseIdentifier:@"AliyunFontItemCell"];
}

- (void)setupData
{
    [self.fontItems removeAllObjects];
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryResourceWithEffecInfoType:1 success:^(NSArray *infoModelArray) {
       
        for (AliyunEffectFontInfo *info in infoModelArray) {
            
            // 检测字体是否注册
            UIFont* aFont = [UIFont fontWithName:info.fontName size:14.0];
            BOOL isRegister = (aFont && ([aFont.fontName compare:info.fontName] == NSOrderedSame || [aFont.familyName compare:info.fontName] == NSOrderedSame));
            if (!isRegister) {
                NSString *fontPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"font"] stringByAppendingPathExtension:@"ttf"];
                NSString *registeredName = [[AliyunEffectFontManager manager] registerFontWithFontPath:fontPath];
                if (registeredName) {
                    [self.fontItems addObject:info];
                }
            } else {
                [self.fontItems addObject:info];
            }
        }
        
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:nil];
        
    } failure:^(NSError *error) {
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fontItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunFontItemCell *fontItemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunFontItemCell" forIndexPath:indexPath];
    if (self.fontItems.count <= indexPath.row) {
        return fontItemCell;
    }
    AliyunEffectFontInfo *font = [self.fontItems objectAtIndex:indexPath.row];
    [fontItemCell setWithFontModel:font];
    
    return fontItemCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectFontWithFontInfo:)]) {
        [self.delegate onSelectFontWithFontInfo:self.fontItems[indexPath.row]];
    }
    
}


- (NSMutableArray *)fontItems
{
    
    if (!_fontItems) {
        _fontItems = [[NSMutableArray alloc] init];
    }
    return _fontItems;
}

@end
