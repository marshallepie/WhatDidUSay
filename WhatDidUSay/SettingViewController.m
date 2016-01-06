//
//  SettingViewController.m
//  WhatDidUSay
//
//  Created by Dottechnologies on 13/08/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController () {
    IBOutlet UIButton *backButton;
}

-(IBAction)backAction:(id)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lblDuration.text = [NSString stringWithFormat:@"Duration: %d",(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"]];
    recordingSlider.value = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)backAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)recordingSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;//Get here the slider value and save for recording
    lblDuration.text = [NSString stringWithFormat:@"Duration: %d",(int)slider.value];//Show slider value on label
    [[NSUserDefaults standardUserDefaults] setInteger:slider.value forKey:@"SliderValueChanged"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
