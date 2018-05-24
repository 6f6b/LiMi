//
//  TestViewController.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/17.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "TestViewController.h"
#import "AliyunMagicCameraViewController.h"

@interface TestViewController ()
{
    UITextField *_tfw;
    UITextField *_tfh;
}

@end


@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    _tfw = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _tfw.placeholder = @"分辨率宽：默认 360";
    _tfw.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tfw];
    _tfw.center = CGPointMake(ScreenWidth / 2 - 40, 100);
    
    _tfh = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _tfh.placeholder = @"分辨率宽：默认 640";
    _tfh.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tfh];
    _tfh.center = CGPointMake(ScreenWidth / 2 - 40, 200);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"confirm" forState:UIControlStateNormal];

    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.center = CGPointMake(ScreenWidth /2 + 110, 150);
    [self.view addSubview:btn];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    lbl.text = @"本页面为底层调试分辨率页面";
    lbl.center = CGPointMake(ScreenWidth / 2, ScreenHeight - 60);
    lbl.backgroundColor = [UIColor yellowColor];
    lbl.textColor = [UIColor redColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbl];
    
    UILabel *beautyLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 240, 52, 40)];
    beautyLbl.text = @"美颜：";
    beautyLbl.backgroundColor = [UIColor whiteColor];
    beautyLbl.textColor = [UIColor blackColor];
    [self.view addSubview:beautyLbl];
    
    UISwitch *beautySwitch = [[UISwitch alloc] init];
    beautySwitch.frame = CGRectMake(74, 245, 0, 0);
    [self.view addSubview:beautySwitch];
    [beautySwitch addTarget:self action:@selector(beautySwitchClick:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL beauty = [[NSUserDefaults standardUserDefaults] boolForKey:@"beauty"];
    beautySwitch.on = beauty;
    
    
    UILabel *stLbl = [[UILabel alloc] initWithFrame:CGRectMake(160, 240, 52, 40)];
    stLbl.text = @"商汤：";
    stLbl.backgroundColor = [UIColor whiteColor];
    stLbl.textColor = [UIColor blackColor];
    [self.view addSubview:stLbl];
    
    UISwitch *stSwitch = [[UISwitch alloc] init];
    stSwitch.frame = CGRectMake(214, 245, 0, 0);
    [self.view addSubview:stSwitch];
    [stSwitch addTarget:self action:@selector(stSwitchClick:) forControlEvents:UIControlEventTouchUpInside];

    BOOL st = [[NSUserDefaults standardUserDefaults] boolForKey:@"faceTrack"];
    stSwitch.on = st;
}

- (void)beautySwitchClick:(UISwitch *)swt
{
    [[NSUserDefaults standardUserDefaults] setBool:[swt isOn] forKey:@"beauty"];
}

- (void)stSwitchClick:(UISwitch *)swt
{
    [[NSUserDefaults standardUserDefaults] setBool:[swt isOn] forKey:@"faceTrack"];
}

- (void)nextPage:(id)sender
{
    int w = [_tfw.text isEqualToString:@""] ? 360: [_tfw.text intValue];
    int h = [_tfh.text isEqualToString:@""] ? 640:[_tfh.text intValue];
    
    AliyunMagicCameraViewController *mcv = [[AliyunMagicCameraViewController alloc] init];
    [mcv setVideoSize:CGSizeMake((CGFloat)w, (CGFloat)h)];
    mcv.beauty = [[NSUserDefaults standardUserDefaults] boolForKey:@"beauty"];
    mcv.faceTrack = [[NSUserDefaults standardUserDefaults] boolForKey:@"faceTrack"];
    
    [self.navigationController pushViewController:mcv animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
