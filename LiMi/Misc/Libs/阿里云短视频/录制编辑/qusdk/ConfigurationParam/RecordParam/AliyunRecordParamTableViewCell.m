//
//  AliyunRecordParamTableViewCell.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordParamTableViewCell.h"

@interface AliyunRecordParamTableViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) AliyunRecordParamCellModel *cellModel;

@end

@implementation AliyunRecordParamTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = 2;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        if ([reuseIdentifier isEqualToString:@"cellInput"]) {
            [self setupInputView];
        }else if([reuseIdentifier isEqualToString:@"switch"]){
            [self setupSwitchView];
        }else {
            [self setupSliderView];
        }
    }
    return self;
}

- (void)setupInputView {
    _inputView = [[UITextField alloc] init];
    _inputView.borderStyle = UITextBorderStyleRoundedRect;
    _inputView.textAlignment = 1;
    _inputView.font = [UIFont systemFontOfSize:14];
    _inputView.textColor = RGBToColor(136, 136, 136);
    _inputView.keyboardType = UIKeyboardTypeNumberPad;
    [_inputView addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_inputView];
}

- (void)setupSwitchView{
    _switcher = [[UISwitch alloc] init];
    _switcher.on = NO;
    [_switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switcher];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.textAlignment = 0;
    _infoLabel.textColor = RGBToColor(136, 136, 136);
    _infoLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_infoLabel];
}

- (void)setupSliderView {
    _slider = [[UISlider alloc] init];
    [_slider addTarget:self action:@selector(silderValueDidChanged) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_slider];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.textAlignment = 0;
    _infoLabel.textColor = RGBToColor(136, 136, 136);
    _infoLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_infoLabel];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat midY  = CGRectGetMidY(self.contentView.bounds);
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    _titleLabel.frame = CGRectMake(8, midY - 10, 72, 20);
    if ([self.reuseIdentifier isEqualToString:@"cellInput"]) {
        _inputView.frame = CGRectMake(90, midY - 15, width - 120, 30);
    }else if ([self.reuseIdentifier isEqualToString:@"switch"]){
        _switcher.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame) + 20, midY - 15, 50, 30);
        _infoLabel.frame = CGRectMake(width - 70, midY - 10, 70, 20);
    }else {
        _infoLabel.frame = CGRectMake(width - 70, midY - 10, 70, 20);
        _slider.frame = CGRectMake(90, midY - 15, width - 170, 30);
    }
}

- (void)configureCellModel:(AliyunRecordParamCellModel *)cellModel {
    _cellModel = cellModel;
    _titleLabel.text = cellModel.title;
    _inputView.placeholder = cellModel.placeHolder;
    _infoLabel.text = cellModel.placeHolder;
    _slider.value = cellModel.defaultValue;
}

- (void)textFieldEditingChanged {
    CGFloat r = [_inputView.text intValue];
    _cellModel.valueBlock(r);
}

- (void)silderValueDidChanged {
    CGFloat v = _slider.value;
    if ([_cellModel.title isEqualToString:@"视频质量"]) {
        int f = 1;
        if (v < 1 / 6.0) {
            _infoLabel.text = @"极高";
            f = 0;
        } else if (v < 2/6.0) {
            _infoLabel.text = @"高";
            f = 1;
        } else if (v < 3/6.0) {
            _infoLabel.text = @"中";
            f = 2;
        } else if (v < 4 / 6.0) {
            _infoLabel.text = @"低";
            f = 3;
        } else if (v < 5 / 6.0) {
            f = 4;
            _infoLabel.text = @"较低";
        } else if (v <= 1.0) {
            f = 5;
            _infoLabel.text = @"极低";
        }
        _cellModel.valueBlock(f);
    } else if ([_cellModel.title isEqualToString:@"分辨率"]) {
        CGFloat videoWidth = 360;
        if (v < 1 / 4.0) {
            _infoLabel.text = @"360P";
            videoWidth = 360;
        } else if (v < 2/4.0) {
            _infoLabel.text = @"480P";
            videoWidth = 480;
        } else if (v < 3/4.0) {
            _infoLabel.text = @"540P";
            videoWidth = 540;
        } else if (v <= 1) {
            _infoLabel.text = @"720P";
            videoWidth = 720;
        }
        _cellModel.sizeBlock(videoWidth);
    } else {
        
        CGFloat videoRatio = 1.0;
        if (v < 1 / 3.0) {
            _infoLabel.text = @"9:16";
            videoRatio = 9.0/16.0;
        } else if (v < 2/3.0) {
            _infoLabel.text = @"3:4";
            videoRatio = 3.0/4.0;
        } else if (v < 3/3.0) {
            _infoLabel.text = @"1:1";
            videoRatio = 1.0;
        }
        _cellModel.ratioBack(videoRatio);
    }
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _infoLabel.text = @"硬编";
    }else {
        _infoLabel.text = @"软编";
    }
    _cellModel.switchBlock(isButtonOn);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

@implementation AliyunRecordParamCellModel


@end
