//
//  ViewController.h
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "CustomTableViewCell.h"

@interface ViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate,UIGestureRecognizerDelegate, UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate,ButtonDelegate,UIAlertViewDelegate,UITextFieldDelegate>

{
    IBOutlet UIButton *whatSayBtn;
    IBOutlet UIButton *startBtn;
    IBOutlet UIButton *stopBtn;
    __weak IBOutlet UIButton *btnRestore;
    IBOutlet UIActivityIndicatorView *actView;
    IBOutlet UILabel *stateLbl;
    UILongPressGestureRecognizer *longGesture;

    IBOutlet UILabel *recordLbl;
    
    NSString *recorderFilePath, *dateString;
    NSMutableArray *arrFiles;
    NSMutableArray *dateArray;
    NSMutableArray *timeArray;
    NSMutableArray *fileNameArray;
    
    NSMutableDictionary *recordSetting;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer  *audioPlayer;
}

@property (nonatomic ,retain) NSString *folderName;
@property (nonatomic, strong) NSMutableArray *inAppCountArray;
@property (nonatomic, strong) NSMutableArray *audioCountArray;

- (IBAction)infoButtonAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (void)uploadFileDropBox;

@end

