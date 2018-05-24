//
//  AliyunPasterView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2015 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterView.h"
#import "AliyunPasterTextView.h"
#import "AliyunPaseterAnimationView.h"
#import <AliyunVideoSDKPro/AliyunEffectPasterFrameItem.h>



typedef NS_ENUM(NSInteger, AliyunPasterActionType) {
    AliyunPasterActionTypeMove,
    AliyunPasterActionTypeScaleAndRotate,
    AliyunPasterActionTypeNone
};

struct AliyunBoxBounds {
    CGFloat left;
    CGFloat right;
    CGFloat top;
    CGFloat bottom;
};
typedef struct AliyunBoxBounds Box;

CG_INLINE Box AliyunBoxMake(CGFloat left, CGFloat right, CGFloat top, CGFloat bottom) {
    Box box;
    box.left = left;
    box.right = right;
    box.top = top;
    box.bottom = bottom;
    
    return box;
}


@interface AliyunPasterView ()

@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *scaleButton;
@property (nonatomic, strong) UIButton *mirrorButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) AliyunPasterTextView *pasterTextView;
@property (nonatomic, strong) AliyunPaseterAnimationView *pasterAnimationView;
@property (nonatomic, assign) AliyunPasterActionType pasterActionType;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat originSizeRatio;
@property (nonatomic, assign) AliyunPasterEffectType type;
@property (nonatomic, assign) BOOL mirror;

@end

@implementation AliyunPasterView
{
    CGFloat _xRatio;
    CGFloat _yRatio;
    CGFloat _wRatio;
    CGFloat _hRatio;
}

#pragma mark - init -

- (id)initWithPasterController:(AliyunPasterController *)pasterController
{
    CGRect pasterFrame = pasterController.pasterFrame;
    self.type = pasterController.pasterType;
    
    if (self = [super initWithFrame:pasterFrame]) {
        self.nativeDisplaySize = pasterController.displaySize;
        self.renderedMediaSize = pasterController.outputSize;
        if (self.type == AliyunPasterEffectTypeSubtitle || self.type == AliyunPasterEffectTypeCaption) {
            self.text = pasterController.subtitle;
        }
        
        [self addSubviewsWithController:pasterController];
        if (self.type == AliyunPasterEffectTypeCaption) {
            //记录这些变量主要是用来计算pasterView的大小变化的时候，字幕应该显示的位置大小
            CGRect textFrame = pasterController.subtitleFrame;
            _xRatio = (textFrame.origin.x + textFrame.size.width / 2) / pasterFrame.size.width;
            _yRatio = (textFrame.origin.y + textFrame.size.height / 2) / pasterFrame.size.height;
            _wRatio = textFrame.size.width / pasterFrame.size.width;
            _hRatio = textFrame.size.height / pasterFrame.size.height;
        }
        if (self.type == AliyunPasterEffectTypeSubtitle || self.type == AliyunPasterEffectTypeCaption) {
            [self needsUpdate];
        }
    }
    return self;
}

- (void)setEditStatus:(BOOL)editStatus
{
    _editStatus = editStatus;
    [self subviewsHiddenWithEditStatus:_editStatus];
}

- (void)subviewsHiddenWithEditStatus:(BOOL)isEdit
{
    self.borderView.hidden = !isEdit;
    self.closeButton.hidden = !isEdit;
    self.editButton.hidden = !isEdit;
    self.mirrorButton.hidden = !isEdit;
    self.scaleButton.hidden = !isEdit;
    if (isEdit) {
        [self.pasterAnimationView run];
    } else {
        [self.pasterAnimationView stop];
    }
}

- (void)setTextColor:(AliyunColor *)textColor
{
    _textColor = textColor;
    
    _pasterTextView.isStroke = textColor.isStroke;
    _pasterTextView.strokeColor = [UIColor colorWithRed:textColor.sR / 255 green:textColor.sG / 255 blue:textColor.sB / 255 alpha:1];
    _pasterTextView.textColor = [UIColor colorWithRed:textColor.tR / 255 green:textColor.tG / 255 blue:textColor.tB / 255 alpha:1];

    [self needsUpdate];
}

- (void)setTextFontName:(NSString *)textFontName
{
    _textFontName = textFontName;
    _pasterTextView.fontName = textFontName;
    [self needsUpdate];
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.pasterTextView.text = _text;
}

#pragma mark - UI init -

- (void)addSubviewsWithController:(AliyunPasterController *)pasterController
{
    CGRect pasterRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    self.borderView = [[UIView alloc] initWithFrame:pasterRect];
    [self addSubview:self.borderView];
    self.borderView.autoresizingMask = 0b111111;
    self.borderView.layer.masksToBounds = YES;
    self.borderView.layer.borderColor = [UIColor colorWithRed:239.0 / 255 green:75.0 / 255 blue:129.0 / 255 alpha:1].CGColor;
    self.borderView.layer.borderWidth = 1.5;
    self.borderView.layer.cornerRadius = 4.0;
    
    if (_type == AliyunPasterEffectTypeSubtitle) {
        self.pasterTextView = [[AliyunPasterTextView alloc] initWithFrame:pasterRect];
        self.pasterTextView.text = self.text;
        [self addSubview:self.pasterTextView];
        self.pasterTextView.autoresizingMask = 0b111111;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneClick:)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
    } else if (_type == AliyunPasterEffectTypeNormal) {
        self.pasterAnimationView = [[AliyunPaseterAnimationView alloc] initWithFrame:pasterRect];
        self.pasterAnimationView.userInteractionEnabled = YES;
        [self addSubview:self.pasterAnimationView];
        self.pasterAnimationView.autoresizingMask = 0b111111;
        NSMutableArray *picPaths = [[NSMutableArray alloc] init];
        NSArray *frames = pasterController.frames;
        
        for (int idx = 0; idx < frames.count; idx++) {
            AliyunEffectPasterFrameItem *frameItem = [frames objectAtIndex:idx];
            [picPaths addObject:frameItem.picPath];
        }
        [self.pasterAnimationView setupImages:picPaths duration:pasterController.originDuration];
        [self.pasterAnimationView run];
        
    } else {
        self.pasterAnimationView = [[AliyunPaseterAnimationView alloc] initWithFrame:pasterRect];
        self.pasterAnimationView.userInteractionEnabled = YES;
        [self addSubview:self.pasterAnimationView];
        self.pasterAnimationView.autoresizingMask = 0b111111;
        NSMutableArray *picPaths = [[NSMutableArray alloc] init];
        NSArray *frames = pasterController.frames;
        
        for (int idx = 0; idx < frames.count; idx++) {
            AliyunEffectPasterFrameItem *frameItem = [frames objectAtIndex:idx];
            [picPaths addObject:frameItem.picPath];
        }
        
        self.pasterTextView = [[AliyunPasterTextView alloc] initWithFrame:pasterController.subtitleFrame];
        [self addSubview:self.pasterTextView];
        self.pasterTextView.text = self.text;
        self.pasterTextView.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
        self.pasterAnimationView.textAppearanceBlock = ^(BOOL isAppear) {
            weakSelf.pasterTextView.hidden = !isAppear;
        };
       
        [self.pasterAnimationView setupImages:picPaths duration:pasterController.originDuration textBeginTime:pasterController.originTextBeginTime textDuration:pasterController.originTextDuration];
        [self.pasterAnimationView run];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneClick:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    
    self.closeButton.bounds = CGRectMake(0, 0, 40, 40);
    [self addSubview:self.closeButton];
    self.closeButton.center = CGPointMake(0, 0);
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    if (_type != AliyunPasterEffectTypeSubtitle) {
        self.mirrorButton.bounds = CGRectMake(0, 0, 40, 40);
        [self addSubview:self.mirrorButton];
        self.mirrorButton.center = CGPointMake(0, CGRectGetHeight(self.bounds));
        self.mirrorButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.scaleButton.bounds = CGRectMake(0, 0, 40, 40);
    [self addSubview:self.scaleButton];
    self.scaleButton.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.scaleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self subviewsHiddenWithEditStatus:self.editStatus];
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.userInteractionEnabled = NO;
        [_closeButton setImage:[AliyunImage imageNamed:@"paster_edit_delete"] forState:UIControlStateNormal];
    }
    
    return _closeButton;
}

- (UIButton *)scaleButton
{
    if (!_scaleButton) {
        _scaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _scaleButton.userInteractionEnabled = NO;
        [_scaleButton setImage:[AliyunImage imageNamed:@"paster_edit_scale"] forState:UIControlStateNormal];
    }
    return _scaleButton;
}

- (UIButton *)mirrorButton
{
    if (!_mirrorButton) {
        _mirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mirrorButton.userInteractionEnabled = NO;
        [_mirrorButton setImage:[AliyunImage imageNamed:@"paster_edit_mirror"] forState:UIControlStateNormal];
    }
    return _mirrorButton;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _editButton;
}
#pragma mark - Private Methods -

- (void)oneClick:(id)sender
{
    [self.actionTarget oneClick:self];
}

- (void)move:(CGPoint)fp to:(CGPoint)tp
{
    CGPoint cp = self.center;
    CGPoint np = CGPointZero;
    
    np.x = tp.x - fp.x + cp.x;
    np.y = tp.y - fp.y + cp.y;
    
    Box box = [self boxBounds];
    if (np.x < box.left) {
        np.x = box.left;
    }
    if (np.x > box.right) {
        np.x = box.right;
    }
    if (np.y < box.top) {
        np.y = box.top;
    }
    if (np.y > box.bottom) {
        np.y = box.bottom;
    }
    self.center = np;
}

- (void)rotate:(CGPoint)fp to:(CGPoint)tp
{
    if (self.rotateAngle == 0.0) {
        [self calculateRotateButtonAngle];
    }
    
    CGPoint cp = self.center; //center point
    CGPoint op = CGPointMake(cp.x + 600, cp.y);//offset point
    float angle = [self angleFromTriangleThreePointsAp:cp Bp:op Cp:tp];
    if (tp.y < cp.y) {
        angle = M_PI*2 - (self.rotateAngle + angle);
    } else {
        angle = angle - self.rotateAngle;
    }
    
    float cps = sqrtf(powf((tp.x - cp.x),2.0) + powf((tp.y - cp.y),2.0)) / self.originSizeRatio;
    
    float w = cps * cos(self.rotateAngle) * 2;
    float h = cps * sin(self.rotateAngle) * 2;
    CGRect newRect = CGRectMake(0, 0, w, h);
    
    self.bounds = newRect;
    
    CGAffineTransform transfrom = CGAffineTransformMakeRotation(angle);
    self.transform = transfrom;
}

- (void)calculateRotateButtonAngle
{
    CGPoint rp = self.scaleButton.center; //rotate button center point
    CGPoint cp =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint op = CGPointMake(cp.x + 100, cp.y);
    self.rotateAngle = [self angleFromTriangleThreePointsAp:cp Bp:rp Cp:op];
    
    
    CGFloat a1 = sqrtf(powf((rp.x - cp.x),2.0) + powf((rp.y - cp.y),2.0));
    CGPoint mp = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGFloat a2 = sqrtf(powf((mp.x - cp.x),2.0) + powf((mp.y - cp.y),2.0));
    self.originSizeRatio = a1 / a2;
}

//cosA = (a^2 + c^2 - c^2) / 2ac
- (float)angleFromTriangleThreePointsAp:(CGPoint)Ap Bp:(CGPoint)Bp Cp:(CGPoint)Cp
{
    float BC = powf((Cp.x - Bp.x),2.0) + powf((Cp.y - Bp.y),2.0);
    float AC = powf((Cp.x - Ap.x),2.0) + powf((Cp.y - Ap.y),2.0);
    float AB = powf((Bp.x - Ap.x),2.0) + powf((Bp.y - Ap.y),2.0);
    
    return acosf((AC + AB - BC)/(2 * sqrtf(AC) * sqrtf(AB)));
}

- (void)needsUpdate
{
    [self.pasterTextView setNeedsDisplay];
}

- (void)needsUpdateTextFrame
{
    if (self.type != AliyunPasterEffectTypeCaption) {
        return;
    }
    CGFloat xp = self.bounds.size.width * _xRatio;
    CGFloat yp = self.bounds.size.height * _yRatio;
    CGFloat w = self.bounds.size.width * _wRatio;
    CGFloat h = self.bounds.size.height * _hRatio;
    CGRect bounds = CGRectMake(0, 0, w, h);
    self.pasterTextView.bounds = bounds;
    self.pasterTextView.center = CGPointMake(xp, yp);
}

- (void)setDelegate:(id<AliyunPasterUIEventProtocol>)delegate
{
    _delegate = delegate;
}

#pragma mark - Public Methods -
- (BOOL)touchPoint:(CGPoint)point fromView:(UIView *)view {
    CGPoint localPoint = [self convertPoint:point fromView:view];
    BOOL isPointInside = [self pointInside:localPoint withEvent:nil];
    
    CGPoint closePoint = [self.closeButton convertPoint:localPoint fromView:self];
    CGPoint mirrorPoint = [self.mirrorButton convertPoint:localPoint fromView:self];
    CGPoint scalePoint = [self.scaleButton convertPoint:localPoint fromView:self];
    
    BOOL pointInCloseButton = [self.closeButton pointInside:closePoint withEvent:nil];
    BOOL pointInMirrorButton = [self.mirrorButton pointInside:mirrorPoint withEvent:nil];
    BOOL pointInScaleButton = [self.scaleButton pointInside:scalePoint withEvent:nil];

    if (pointInCloseButton) {
        isPointInside = YES;
        [self.delegate eventPasterViewClosed:self];
    } else if (pointInMirrorButton) {
        isPointInside = YES;
        self.mirror = !self.mirror;
        [self flipPasterImageView];
        [self.delegate eventMirrorChanged:self.mirror];
    } else if (pointInScaleButton) {
        isPointInside = YES;
        self.pasterActionType = AliyunPasterActionTypeScaleAndRotate;
    } else {
        self.pasterActionType = AliyunPasterActionTypeMove;
    }
    
    return isPointInside;
}

- (void)touchMoveFromPoint:(CGPoint)fp to:(CGPoint)tp {
    if (CGPointEqualToPoint(fp, tp)) {
        return;
    }
    if (self.pasterActionType == AliyunPasterActionTypeMove) {
        [self move:fp to:tp];
    } else if (self.pasterActionType == AliyunPasterActionTypeScaleAndRotate) {
        [self rotate:fp to:tp];
        [self needsUpdateTextFrame];
    }
}

- (void)touchEnd {
    self.pasterActionType = AliyunPasterActionTypeNone;
    CGFloat radians = atan2f(self.transform.b, self.transform.a); //warning: 底层接口逆时针旋转为正 顺时针旋转为负
    [self.pasterTextView setNeedsDisplay];
    [self.delegate eventBoundsDidChanged:self.bounds];
    [self.delegate eventCenterDidChanged:self.center];
    [self.delegate eventRotateDidChanged:-radians];
    [self.delegate eventMirrorChanged:self.mirror];
    
    if (self.type == AliyunPasterEffectTypeCaption) {
        [self.delegate eventTextBoundsDidChanged:self.pasterTextView.bounds];
        [self.delegate eventTextCenterDidChanged:self.pasterTextView.center];
    }
}

- (UIImage *)textImage {
    //fix:对于文字模糊的问题 特定进行的优化
    return [self.pasterTextView captureImage:self.nativeDisplaySize outputSize:self.renderedMediaSize];
}

- (void)flipPasterImageView {
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DRotate(t, self.mirror ? M_PI : 0, 0, 1, 0);
    self.pasterAnimationView.transform = CATransform3DGetAffineTransform(t);
}

- (Box)boxBounds {
    CGFloat hdlt = CGRectGetMidX(self.bounds) - 40;
    CGFloat vdlt = CGRectGetMidY(self.bounds) - 40;
    
    
    return AliyunBoxMake(-hdlt, CGRectGetWidth(self.superview.bounds) + hdlt, -vdlt, CGRectGetHeight(self.superview.bounds) + vdlt);
}

- (UIColor *)contentColor {
    UIColor *color = [UIColor colorWithRed:self.textColor.tR / 255 green:self.textColor.tG / 255 blue:self.textColor.tB / 255 alpha:1];
    return color;
}

- (UIColor *)strokeColor {
    UIColor *color = [UIColor colorWithRed:self.textColor.sR / 255 green:self.textColor.sG / 255 blue:self.textColor.sB / 255 alpha:1];
    return color;
}

@end
