//
//  ViewController.h
//  WhatDidUSay
//
//  Created by Marshall Epie on 11/04/2015.
//  Copyright (c) 2015 Marshall Epie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UIButton *btnStart, *btnStore, *btnStop, *btnDisplay;
    IBOutlet UITableView *tblView;
    
    IBOutlet UIActivityIndicatorView *actView;
    
    NSString *recorderFilePath, *dateString;
    
    NSMutableArray *arrFiles;
    
    NSMutableDictionary *recordSetting;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer  *audioPlayer;
    
}

@end

