//
//  MagicCameraScrollView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/5.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraScrollView.h"
#import "AliyunMagicCameraEffectCell.h"
#import <AliyunVideoSDKPro/AliyunEffect.h>
#import "AliyunPasterInfo.h"
#import "UIImageView+WebCache.h"

@class MagicCameraPressCircleView;


@protocol MagicCameraPressCircleViewDelegate <NSObject>

- (void)touchesBegin;
- (void)touchesEnd;

@end
@interface MagicCameraPressCircleView : UIView

@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, weak) id <MagicCameraPressCircleViewDelegate> delegate;

- (void)reset;

@end

@implementation MagicCameraPressCircleView
{
    CGFloat _startAngle;
    CGFloat _endAngle;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _startAngle = 0;
        _endAngle = 2 * M_PI;
        self.clearsContextBeforeDrawing = YES;

        self.transform = CGAffineTransformMakeRotation(- M_PI_2);
        self.layer.cornerRadius = frame.size.width / 2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setPercent:(CGFloat)percent
{
    _percent = percent;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor));
    
    
    CGContextFillPath(ctx);
    
    UIBezierPath *bezierPath1 = [UIBezierPath bezierPath];
    // Create our arc, with the correct angles
    [bezierPath1 addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:rect.size.width / 2 - 3
                      startAngle:0
                        endAngle:M_PI * 2
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath1.lineWidth = 5;
    [[UIColor whiteColor] setStroke];
    [bezierPath1 stroke];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:rect.size.width / 2 - 3
                      startAngle:_startAngle
                        endAngle:_endAngle * _percent
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 5;
    
    UIColor *color = [UIColor colorWithRed:239.0/255 green:75.0/255 blue:129.0/255 alpha:1];
    [color setStroke];
    [bezierPath stroke];

}
//这里这样处理以后维护会比较麻烦 这是偷懒的实现
static bool _longTouching = NO;
static bool _longTouchEnd = NO;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    _longTouching = YES;
    
    [UIView animateWithDuration:.5 animations:^{
        self.transform = CGAffineTransformScale(self.transform, 1.48, 1.48);
    } completion:^(BOOL finished) {
        _longTouching = NO;
        if (_longTouchEnd) {
            _longTouchEnd = NO;
            self.transform = CGAffineTransformIdentity;
            self.transform =  CGAffineTransformMakeRotation(- M_PI_2);
            return ;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(touchesBegin)]) {
            [self.delegate touchesBegin];
        }
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_longTouching) {
        _longTouchEnd = YES;
        [self.layer removeAllAnimations];
        return;
    }
    
    self.transform = CGAffineTransformIdentity;
    self.transform =  CGAffineTransformMakeRotation(- M_PI_2);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesEnd)]) {
        [self.delegate touchesEnd];
    }
}

- (void)reset
{
    _longTouchEnd = NO;
    _longTouching = NO;
    
    self.transform = CGAffineTransformIdentity;
    self.transform =  CGAffineTransformMakeRotation(- M_PI_2);

}

@end





@interface  MagicCameraScrollViewLayout: UICollectionViewFlowLayout

@end


@implementation MagicCameraScrollViewLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + self.collectionView.bounds.size.width * 0.5f;
    
    CGRect proposedRect = self.collectionView.bounds;
    
    // Comment out if you want the collectionview simply stop at the center of an item while scrolling freely
    // proposedRect = CGRectMake(proposedContentOffset.x, 0.0, collectionViewSize.width, collectionViewSize.height);
    
    UICollectionViewLayoutAttributes* candidateAttributes;
    for (UICollectionViewLayoutAttributes* attributes in [self layoutAttributesForElementsInRect:proposedRect])
    {
        
        // == Skip comparison with non-cell items (headers and footers) == //
        if (attributes.representedElementCategory != UICollectionElementCategoryCell)
        {
            continue;
        }
        
        // == First time in the loop == //
        if(!candidateAttributes)
        {
            candidateAttributes = attributes;
            continue;
        }
        
        if (fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes.center.x - proposedContentOffsetCenterX))
        {
            candidateAttributes = attributes;
        }
    }
    
    return CGPointMake(candidateAttributes.center.x - self.collectionView.bounds.size.width * 0.5f, proposedContentOffset.y);
}


@end













@interface AliyunMagicCameraScrollView ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MagicCameraPressCircleView *pressCircleView;

@end

@implementation AliyunMagicCameraScrollView
{
    CGFloat _flowLayoutWidth;
    CGPoint _originOffset;
}


- (id)initWithFrame:(CGRect)frame delegate:(id)delegate
{
    if (self = [super initWithFrame:frame]) {
        MagicCameraScrollViewLayout *flowLayout = [[MagicCameraScrollViewLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        flowLayout.minimumInteritemSpacing = (ScreenWidth-56*4-20*2-1)/3.0;
        flowLayout.minimumLineSpacing = 20;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _flowLayoutWidth = frame.size.height - 2;
        
        flowLayout.itemSize = CGSizeMake(56, 56);
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        [self addSubview:self.collectionView];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = YES;
        self.collectionView.alwaysBounceHorizontal = NO;
        
        //self.collectionView.contentInset = UIEdgeInsetsMake(0, CGRectGetMidX(self.bounds) + (frame.size.height-2)/2, 0, CGRectGetMidX(self.bounds)+ (frame.size.height-2)/2);
        self.collectionView.delegate = (id)self;
        self.collectionView.dataSource = (id)self;
        [self.collectionView registerClass:[AliyunMagicCameraEffectCell class] forCellWithReuseIdentifier:@"AliyunMagicCameraEffectCell"];
        
//        self.pressCircleView = [[MagicCameraPressCircleView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
//        [self addSubview:self.pressCircleView];
//        self.pressCircleView.backgroundColor = [UIColor clearColor];
//        self.pressCircleView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
//        self.pressCircleView.delegate = (id)self;
        
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];

        _originOffset = self.collectionView.contentOffset;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
//    [self.pressCircleView setNeedsDisplay];
}

- (void)setEffectItems:(NSArray *)effectItems
{
    _effectItems = effectItems;
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)touchesBegin
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesBegin)]) {
        [self.delegate touchesBegin];
    }
}

- (void)touchesEnd
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesEnd)]) {
        [self.delegate touchesEnd];
    }
}

- (void)setRecordPercent:(CGFloat)recordPercent
{
    _recordPercent = recordPercent;
    self.pressCircleView.percent = recordPercent;
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.effectItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunMagicCameraEffectCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunMagicCameraEffectCell" forIndexPath:indexPath];
    
    AliyunPasterInfo *pasterInfo = [self.effectItems objectAtIndex:indexPath.row];
    
    if (pasterInfo.bundlePath != nil) {
        UIImage *iconImage = [UIImage imageWithContentsOfFile:pasterInfo.icon];
        [effectCell.imageView setImage:iconImage];
        [effectCell borderHidden:NO];
        [effectCell shouldDownload:NO];
    } else {
        if ([pasterInfo fileExist] && pasterInfo.icon) {
            UIImage *iconImage = [UIImage imageWithContentsOfFile:pasterInfo.icon];
            if (!iconImage) {
                NSURL *url = [NSURL URLWithString:pasterInfo.icon];
                [effectCell.imageView sd_setImageWithURL:url];
            } else {
                [effectCell.imageView setImage:iconImage];
            }
        } else {
            effectCell.imageView.image = [UIImage imageNamed:@"wu"];
//            NSURL *url = [NSURL URLWithString:pasterInfo.icon];
//            [effectCell.imageView sd_setImageWithURL:url];
        }
        if (pasterInfo.icon == nil) {
            [effectCell borderHidden:YES];
            [effectCell shouldDownload:NO];
        } else {
            [effectCell borderHidden:NO];
            [effectCell shouldDownload:![pasterInfo fileExist]];
        }
    }
    

    
   
    
    return effectCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat offsetX = indexPath.row * _flowLayoutWidth  + _originOffset.x;
//    CGPoint offset = CGPointMake(offsetX, _originOffset.y);
//    [collectionView setContentOffset:offset animated:YES];
    
    AliyunMagicCameraEffectCell *cell = (AliyunMagicCameraEffectCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(focusItemIndex:cell:)]) {
        [self.delegate focusItemIndex:indexPath.row cell:cell];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self focusEffectItem];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self focusEffectItem];
}

- (void)focusEffectItem
{
    CGPoint pt = CGPointMake(self.collectionView.contentOffset.x + self.collectionView.contentInset.left - 20 , self.collectionView.center.y);
    
    NSIndexPath *idxPath = [self.collectionView indexPathForItemAtPoint:pt];
    AliyunMagicCameraEffectCell *cell = (AliyunMagicCameraEffectCell *)[self.collectionView cellForItemAtIndexPath:idxPath];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(focusItemIndex:cell:)]) {
        [self.delegate focusItemIndex:idxPath.row cell:cell];
    }
}


- (void)hiddenScroll:(BOOL)hidden
{
    self.collectionView.hidden = hidden;
}

- (void)resetCircleView
{
    [self.pressCircleView reset];
}

@end











