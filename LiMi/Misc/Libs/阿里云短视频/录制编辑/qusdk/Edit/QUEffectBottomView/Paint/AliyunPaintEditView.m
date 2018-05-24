//
//  AliyunPaintEditView.m
//  qusdk
//
//  Created by TripleL on 17/6/6.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPaintEditView.h"
#import "AliyunPaintEditCollectionViewCell.h"
#import "AliyunPathManager.h"
#import <AliyunVideoSDKPro/AliyunIPaint.h>
#import <AliyunVideoSDKPro/AliyunICanvasView.h>

#define kPaintHeight SizeHeight(40)
#define kPaintButtonTag 10105

@interface AliyunPaintEditView () <AliyunICanvasViewDelegate>

@property (nonatomic, strong) AliyunICanvasView *paintView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray *colorsArray;
@property (nonatomic, assign) NSInteger lastButtonIndex;
@end

@implementation AliyunPaintEditView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupPaintView:(CGRectMake(0, SafeTop, ScreenWidth, self.frame.size.height - kPaintHeight * 2))];
        [self setupSubViews];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPaintView:(CGRectMake(0, SafeTop, ScreenWidth, self.frame.size.height - kPaintHeight * 2))];
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame drawRect:(CGRect)drawRect {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPaintView:drawRect];
        [self setupSubViews];
    }
    return self;
}


- (void)updateDrawRect:(CGRect)drawRect {
    
    self.paintView.frame = CGRectMake(drawRect.origin.x, drawRect.origin.y+SafeTop, drawRect.size.width, drawRect.size.height);
}


- (void)setupSubViews {
    
    self.colorsArray = @[RGBToColor(255, 255, 255),RGBToColor(0, 0, 0),RGBToColor(1, 173, 217),RGBToColor(83, 218, 62),RGBToColor(255, 239, 2),RGBToColor(255, 109, 0),RGBToColor(231, 46, 69),RGBToColor(188, 52, 186)];
    
    [self setupBottomViews];
    
    [self setupCenterViews];
}

- (void)setupPaintView:(CGRect)rect {
    
    AliyunIPaint *paint = [[AliyunIPaint alloc] initWithLineWidth:SizeWidth(5.0) lineColor:[UIColor whiteColor]];
    self.paintView = [[AliyunICanvasView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y+SafeTop, rect.size.width, rect.size.height) paint:paint];
    
    self.paintView.delegate = self;
    self.paintView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.paintView];
}

- (void)setupBottomViews {
    
    self.bottomView = [[UIView alloc] initWithFrame:(CGRectMake(0, self.frame.size.height - kPaintHeight, self.frame.size.width, kPaintHeight))];
    self.bottomView.backgroundColor = rgba(27, 33, 51, 1);
    [self addSubview:self.bottomView];
    
    UIButton *finishButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    finishButton.frame = CGRectMake(self.bottomView.bounds.size.width - kPaintHeight, 0, kPaintHeight, kPaintHeight);
    [finishButton setImage:[AliyunImage imageNamed:@"paint_edit_check"] forState:(UIControlStateNormal)];
    [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.bottomView addSubview:finishButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancelButton.frame = CGRectMake(0, 0, kPaintHeight, kPaintHeight);
    [cancelButton setImage:[AliyunImage imageNamed:@"cancel"] forState:(UIControlStateNormal)];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.bottomView addSubview:cancelButton];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(kPaintHeight - 10, kPaintHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelButton.frame), 0, CGRectGetMinX(finishButton.frame) - CGRectGetMaxX(cancelButton.frame), kPaintHeight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[AliyunPaintEditCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunPaintCollectionViewIdentifier"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self.bottomView addSubview:_collectionView];
    [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:(UICollectionViewScrollPositionTop)];

}

- (void)setupCenterViews {
    
    self.centerView = [[UIView alloc] initWithFrame:(CGRectMake(0, CGRectGetMinY(self.bottomView.frame) - kPaintHeight - 10, self.frame.size.width, kPaintHeight))];
    [self addSubview:self.centerView];

    UIButton *undoButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [undoButton setImage:[AliyunImage imageNamed:@"edit_paint_undo"] forState:(UIControlStateNormal)];
    undoButton.frame = CGRectMake(0, 0, kPaintHeight, kPaintHeight);
    [undoButton addTarget:self action:@selector(undoButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.centerView addSubview:undoButton];
    
    int buttonIndex = 3;
    int middleIndex = ceil((float)buttonIndex / 2.0);
    for (int index = 0; index < buttonIndex; index++) {
        UIImage *normalImage = [self createImageWithColor:rgba(255, 255, 255, 0.4) borderColor:nil radius:10+5*index];
        UIImage *selectImage = [self createImageWithColor:rgba(255, 255, 255, 1) borderColor:nil radius:10+5*index];
        UIButton *sizeButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        sizeButton.tag = kPaintButtonTag + index;
        [sizeButton setImage:normalImage forState:(UIControlStateNormal)];
        [sizeButton setImage:selectImage forState:(UIControlStateSelected)];
        sizeButton.frame = CGRectMake(60 * index, 0, kPaintHeight, kPaintHeight);
        CGFloat centerX = (index + 1 - middleIndex) * kPaintHeight + CGRectGetWidth(self.centerView.frame) / 2;
        sizeButton.center = CGPointMake(centerX, kPaintHeight / 2);
        [sizeButton addTarget:self action:@selector(changeWidthButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
        [self.centerView addSubview:sizeButton];
        
        if (index == 0) {
            [sizeButton setSelected:YES];
            self.lastButtonIndex = kPaintButtonTag;
        }
    }
}


- (UIButton *)addWidthButtonWithFrame:(CGRect)frame action:(SEL)action radius:(CGFloat)radius {
    
    UIButton *buttonWidth = [UIButton buttonWithType:(UIButtonTypeCustom)];
    buttonWidth.frame = frame;
    [buttonWidth addTarget:self action:action forControlEvents:(UIControlEventTouchUpInside)];
    return buttonWidth;
}


#pragma mark - AliyunICanvasViewDelegate
- (void)startDrawingWithCurrentPoint:(CGPoint)startPoint {
    
    
    [self.centerView setHidden:YES];
    [self.bottomView setHidden:YES];
}


- (void)endDrawingWithCurrentPoint:(CGPoint)endPoint {
    
    [self.centerView setHidden:NO];
    [self.bottomView setHidden:NO];
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorsArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunPaintEditCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPaintCollectionViewIdentifier" forIndexPath:indexPath];
    
    cell.viewColor = self.colorsArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.paintView.paint.lineColor = self.colorsArray[indexPath.row];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = (ScreenWidth - kPaintHeight * 2) / 7.5;
    return CGSizeMake(width, kPaintHeight);
}


- (void)finishButtonAction:(UIButton *)button {
    
    UIImage *paintImage = [self.paintView complete];
    NSString *paintPath = [[AliyunPathManager resourceRelativeDir] stringByAppendingPathComponent:@"paintImage.png"];
    NSString *realPath = [NSHomeDirectory() stringByAppendingPathComponent:paintPath];
    [UIImagePNGRepresentation(paintImage) writeToFile:realPath atomically:YES];
    
    if (self.delegate) {
        [self.delegate onClickPaintFinishButtonWithImagePath:realPath];
    }
}

- (void)undoButtonAction:(UIButton *)button {
    [self.paintView undo];
}

- (void)cancelButtonAction:(UIButton *)button {
    
    [self.paintView remove];
    if (self.delegate) {
        [self.delegate onClickPaintCancelButton];
    }
}


- (void)changeWidthButtonAction:(UIButton *)button {
    
    UIButton *lastButton = (UIButton *)[self viewWithTag:self.lastButtonIndex];
    [lastButton setSelected:NO];
    self.lastButtonIndex = button.tag;
    
    [button setSelected:!button.selected];
    NSInteger index = button.tag - kPaintButtonTag;
    self.paintView.paint.lineWidth = SizeWidth(5.0) + 5 * index;
}

- (UIImage *)createImageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor radius:(CGFloat)radius{
    
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, 0, radius, radius);
    layer.backgroundColor = color.CGColor;
    layer.cornerRadius = radius / 2;
    layer.masksToBounds = YES;
    layer.borderColor = borderColor.CGColor;
    layer.borderWidth = 1.0;
    
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
