//
//  ViewController.m
//  WhatDidUSay
//
//  Created by Marshall Epie on 11/04/2015.
//  Copyright (c) 2015 Marshall Epie. All rights reserved.
//

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    tblView.delegate = self;
    tblView.dataSource = self;
    
    tblView.hidden = FALSE;
    tblView.allowsMultipleSelectionDuringEditing = NO;
    
    
    btnStop.enabled = TRUE;
    btnStore.enabled = TRUE;
    
    arrFiles = [[NSMutableArray alloc] init];
    audioPlayer = [[AVAudioPlayer alloc] init];
    
    
    //Making the buttons in center
    btnStore.center = CGPointMake(self.view.frame.size.width/2, btnStore.frame.origin.y);
    btnDisplay.center = CGPointMake(self.view.frame.size.width/2, btnDisplay.frame.origin.y);
    btnStop.center = CGPointMake(self.view.frame.size.width/2, btnStop.frame.origin.y);
    btnStart.center = CGPointMake(self.view.frame.size.width/2, btnStart.frame.origin.y);
    
    
    actView.hidden = TRUE;
    [actView stopAnimating];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UIButton Methods

- (IBAction)btnStart_clicked:(id)sender
{
    //Start button method. Hiding animations.
    actView.hidden = TRUE;
    [actView stopAnimating];
    
    btnStart.enabled = FALSE;
    btnStop.enabled = TRUE;
    btnStore.enabled = TRUE;
    
    //Taking current date and time.
    int timestamp = [[NSDate date] timeIntervalSince1970];
    dateString = [NSString stringWithFormat:@"%d", timestamp];
    
    [self startRecording];
    
    
}

- (IBAction)btnStop_clicked:(id)sender
{
    
    
    btnStart.enabled = TRUE;
    btnStop.enabled = TRUE;
    btnStore.enabled = TRUE;
    [self stopRecording];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    //Loading the stored files into array.
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"StoredFiles"])
    {
        arrFiles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"StoredFiles"]];
    }
}


- (IBAction)btnStore_clicked:(id)sender
{
    
    actView.hidden = FALSE;
    [actView startAnimating];
    [recorder stop];
    [self fnStopRecordingAndSave];
    
}

// This is the function for Store Recording button which will store the recording and save it in the file.
- (void) fnStopRecordingAndSave
{
    @try {
        
        NSString *strURL = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, dateString] ;
        
        
        NSURL *url = [NSURL URLWithString:strURL];
        
        //Calculating the duration of the current recording.
        audioPlayer =   [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
        [audioPlayer setDelegate:self];
        
        
        float duration = audioPlayer.duration;
        NSLog(@" fnStopRecordingAndSave Duration here::: %f", audioPlayer.duration);
        
     
        
        if(duration < 10.0)
        
        
        {
        
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Recording needs to be of minimum 10 seconds" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [actView stopAnimating];
            actView.hidden = TRUE;
            return;
        
        }
    
       
        
        
        //Creating its Asset.
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:strURL] options:nil];
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
        
        Float64 startTimeInSeconds = audioPlayer.duration-10;
        Float64 durationInSeconds = 10;
          
        
        
        //Reducing the duration by 10 seconds
        CMTime start = CMTimeMakeWithSeconds(startTimeInSeconds, 600);
        CMTime duration1 = CMTimeMakeWithSeconds(durationInSeconds, 600);
        
        
        
        //Storing the saved file with a different name Saved_
        NSString *strURLT = [NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, dateString] ;
        exportSession.outputURL = [NSURL fileURLWithPath:strURLT];
        
        exportSession.outputFileType=AVFileTypeAppleM4A;
        exportSession.timeRange = CMTimeRangeMake(start, duration1);
        
        
        
        
        //Starting the recording again.
        [self performSelector:@selector(fnStartRecordingAgain) withObject:nil afterDelay:3.0];
        
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            [actView stopAnimating];
            actView.hidden = TRUE;
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export Failed: %@", [exportSession error] );
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export Canceled");
                    
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export COMPLETED...");
                    
                    
                    //Making sure that file has been created
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, dateString]];
                    
                    if(fileExists)
                    {
                        // Adding the files in array.
                        if(arrFiles.count > 0)
                        {
                            for(int i = 0; i<arrFiles.count;i++)
                            {
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", arrFiles];
                                BOOL result = [predicate evaluateWithObject:dateString];
                                
                                if(result == FALSE)
                                    [arrFiles addObject:dateString];
                            }
                        }
                        else
                            [arrFiles addObject:dateString];
                        
                        
                    }
                    
                    //Storing array in User Defaults
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoredFiles"];
                    [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [tblView reloadData];
                    
                    
                    
                    
                    
                    
                    break;
                default:
                    NSLog(@"Export Failed");
                    break;
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
}

- (void) fnStartRecordingAgain
{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    dateString = [NSString stringWithFormat:@"%d", timestamp];
    [self startRecording];
}


- (IBAction)btnDisplay_clicked:(id)sender
{
    if(tblView.hidden == TRUE)
    {
        tblView.hidden = FALSE;
        [tblView reloadData];
    }
    else
        tblView.hidden = TRUE;
}


#pragma mark - UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrFiles.count>0?arrFiles.count:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(arrFiles.count > 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [arrFiles objectAtIndex:indexPath.row]];
    }
    else
    {
        cell.textLabel.text = @"No files found.";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(arrFiles.count > 0)
    {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil]; // To play audio from speaker
        NSString *strURL = [NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, [arrFiles objectAtIndex:indexPath.row]] ;
        NSURL *url = [NSURL URLWithString:strURL];
        audioPlayer =   [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
        [audioPlayer setDelegate:self];
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [arrFiles removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView reloadData];
        
    }
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        
        NSLog(@"Successful!");
    }
}




// This is called when user click on Start Recording button or when called from Store Recording button's second process.
- (void) startRecording
{
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@  %@", [err domain], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@  %@", [err domain], [[err userInfo] description]);
        return;
    }
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    
    
    
    
    recorderFilePath = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, dateString] ;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
    
    
    if(!recorder){
        NSLog(@"recorder: %@ %@", [err domain], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable =  audioSession.inputAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    [recorder record];
    
}

- (void) stopRecording{
    
    //actView.hidden = FALSE;
    //[actView startAnimating];
    [recorder stop];
    //[self saveRecording];
    
}

- (void) saveRecording
{
    
    @try {
        
        NSString *strURL = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, dateString] ;
        
        
        NSURL *url = [NSURL URLWithString:strURL];
        
        
        audioPlayer =   [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
        [audioPlayer setDelegate:self];
        
        float duration = audioPlayer.duration;
        NSLog(@"Duration here::: %f", audioPlayer.duration);
        
        if(duration < 10.0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Recording needs to be of minimum 10 seconds" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [actView stopAnimating];
            actView.hidden = TRUE;
            return;
        }
        
        
        
        
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:strURL] options:nil];
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
        
        Float64 startTimeInSeconds = audioPlayer.duration-10;
        Float64 durationInSeconds = 10;
        
        CMTime start = CMTimeMakeWithSeconds(startTimeInSeconds, 600);
        CMTime duration1 = CMTimeMakeWithSeconds(durationInSeconds, 600);
        
        
        
        
        NSString *strURLT = [NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, dateString] ;
        exportSession.outputURL = [NSURL fileURLWithPath:strURLT];
        
        exportSession.outputFileType=AVFileTypeAppleM4A;
        exportSession.timeRange = CMTimeRangeMake(start, duration1);
        
        
        
        
        
        
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            [actView stopAnimating];
            actView.hidden = TRUE;
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export Failed: %@", [exportSession error] );
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export Canceled");
                    
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export COMPLETED...");
                    
                    
                    
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, dateString]];
                    
                    if(fileExists)
                    {
                        if(arrFiles.count > 0)
                        {
                            for(int i = 0; i<arrFiles.count;i++)
                            {
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", arrFiles];
                                BOOL result = [predicate evaluateWithObject:dateString];
                                
                                if(result == FALSE)
                                    [arrFiles addObject:dateString];
                            }
                        }
                        else
                            [arrFiles addObject:dateString];
                        
                        
                    }
                    
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoredFiles"];
                    [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    [tblView reloadData];
                    
                    
                    break;
                default:
                    NSLog(@"Export Failed");
                    break;
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
    
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
