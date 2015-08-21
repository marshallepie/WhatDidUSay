//
//  SettingViewController.h
//  WhatDidUSay
//
//  Created by Dottechnologies on 13/08/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController {
    
    IBOutlet UILabel *lblDuration;
    IBOutlet UISlider *recordingSlider;
}
- (IBAction)recordingSliderValueChanged:(id)sender;

@end
