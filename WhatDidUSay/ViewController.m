//
//  ViewController.m
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import <DropboxSDK/DropboxSDK.h>
#import <objc/runtime.h>
#import "SettingViewController.h"
#import "InfoViewController.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate> {
    
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
    
    NSMutableArray *recordedArray;
    NSIndexPath    *clickIndex;
    
    NSMutableArray *playingStateArray;
    
    NSTimer        *playTimer;
    int             count;
    NSIndexPath    *selectedIndex;
    NSString *audioFile;
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *settingButton;
    NSMutableDictionary *boolArray;
    NSString *newName;
}

@property (nonatomic, strong) DBRestClient* restClient;
-(IBAction)deleteAction:(id)sender;
-(IBAction)settingAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *recordTableView;

@end

@implementation ViewController
const char MyConstantKey;

@synthesize recordTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 0;
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    // Do any additional setup after loading the view, typically from a nib.
    recordTableView.delegate = self;
    recordTableView.dataSource = self;
    
    recordTableView.hidden = FALSE;
    recordTableView.allowsMultipleSelectionDuringEditing = NO;
    
    boolArray=[[NSMutableDictionary alloc]init];
    stopBtn.enabled = FALSE;
    whatSayBtn.enabled = FALSE;
    
    arrFiles = [[NSMutableArray alloc] init];
    dateArray = [[NSMutableArray alloc] init];
    timeArray = [[NSMutableArray alloc] init];
    playingStateArray = [[NSMutableArray alloc] init];
    fileNameArray=[[NSMutableArray alloc] init];
    
    audioPlayer = [[AVAudioPlayer alloc] init];
    
    actView.hidden = TRUE;
    [actView stopAnimating];
    
    UINib *countryNib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
    [self.recordTableView registerNib:countryNib forCellReuseIdentifier:@"customCell"];
    
    //Long Gesture
    longGesture = [[UILongPressGestureRecognizer alloc]
                   initWithTarget:self action:@selector(handleLongPress:)];
    longGesture.minimumPressDuration = 1.0; //seconds
    longGesture.delegate = self;
    [recordTableView addGestureRecognizer:longGesture];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
}

#pragma mark- Long gesture
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:recordTableView];
    NSIndexPath *indexPath = [recordTableView indexPathForRowAtPoint:p];
    if (indexPath == nil)
        NSLog(@"long press on table view but not on a row");
    else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
            // getImageforPost=  [[arrTableCount objectAtIndex:indexPath.row]valueForKey:@"Image"];
            audioFile=[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, [arrFiles objectAtIndex:indexPath.row]];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Export your Recording" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Mail",@"Text",@"DropBox", nil];
            actionSheet.tag=1;
            [actionSheet showInView:self.view];
        }
    }
}

#pragma mark -Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag==1) {
        if (buttonIndex == 0){
            NSMutableArray *arr1=[[NSMutableArray alloc]init];
            for(int i =0;i<[boolArray count];i++) {
                NSString *dic=[arrFiles objectAtIndex:i];
                BOOL checked=[[boolArray objectForKey:dic]boolValue];
                if(checked){
                    [arr1 addObject:[arrFiles objectAtIndex:i]];
                }
            }

            if (arr1.count==0) {
                [[[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please select file to mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [self mailMultipleFiles];
            }
            //NSURL *url = [[NSURL alloc]initFileURLWithPath:audioFile];
            //NSData *soundFile = [[NSData alloc] initWithContentsOfURL:url];
            
            
        }
        else if(buttonIndex == 1){
            //MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            if([MFMessageComposeViewController canSendAttachments] &&
               [MFMessageComposeViewController canSendText] &&
               [MFMessageComposeViewController isSupportedAttachmentUTI:@"com.apple.coreaudio-​format"]) {
                NSMutableArray *arr1=[[NSMutableArray alloc]init];
                for(int i =0;i<[boolArray count];i++) {
                    NSString *dic=[arrFiles objectAtIndex:i];
                    BOOL checked=[[boolArray objectForKey:dic]boolValue];
                    if(checked){
                        [arr1 addObject:[arrFiles objectAtIndex:i]];
                    }
                }
                
                if (arr1.count==0) {
                    [[[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please select file to message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    [self messageMulitpleFiles];
                }
                /*controller.body = @"Dummy Text";
                NSURL *url = [[NSURL alloc]initFileURLWithPath:audioFile];
                [controller addAttachmentURL:url withAlternateFilename:nil]; //.caf file
                controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:nil];*/
            } else {
                
            }
        }
        else if(buttonIndex==2){
            if (![[DBSession sharedSession] isLinked]){
                [[DBSession sharedSession] linkFromController:self];
            }
            else {
                [self uploadFileDropBox];
            }
        }
    }
}
- (void)messageMulitpleFiles {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendAttachments] &&
       [MFMessageComposeViewController canSendText] &&
       [MFMessageComposeViewController isSupportedAttachmentUTI:@"com.apple.coreaudio-​format"]) {
        controller.body = @"Dummy Text";
        //NSURL *url = [[NSURL alloc]initFileURLWithPath:audioFile];
        //[controller addAttachmentURL:url withAlternateFilename:nil]; //.caf file
        for(int i =0;i<[boolArray count];i++) {
            NSString *dic=[arrFiles objectAtIndex:i];
            BOOL checked=[[boolArray objectForKey:dic]boolValue];
            if(checked) {
                NSURL *url = [[NSURL alloc]initFileURLWithPath:[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, [arrFiles objectAtIndex:i]]];
                //NSData *soundFile = [[NSData alloc] initWithContentsOfURL:url];
                [controller addAttachmentURL:url withAlternateFilename:nil];
            }
        }
        controller.recipients = [NSArray arrayWithObjects:@"1(234)567-8910", nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}
- (void)mailMultipleFiles {
    MFMailComposeViewController *controller =
    [[MFMailComposeViewController alloc]init];
    controller.mailComposeDelegate = self;
    for(int i =0;i<[boolArray count];i++) {
        NSString *dic=[arrFiles objectAtIndex:i];
        BOOL checked=[[boolArray objectForKey:dic]boolValue];
        if(checked) {
            NSURL *url = [[NSURL alloc]initFileURLWithPath:[NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, [arrFiles objectAtIndex:i]]];
            NSData *soundFile = [[NSData alloc] initWithContentsOfURL:url];
            [controller addAttachmentData:soundFile mimeType:@"audio/mpeg" fileName:@""];
        }
    }
    //[controller addAttachmentData:soundFile mimeType:@"audio/mpeg" fileName:@""];
    [controller setSubject:@"Demo Audio File"];
    [controller setMessageBody:@"Dummy Text" isHTML:NO];
    [self presentViewController:controller animated: YES completion:nil];
}

- (IBAction)infoButtonAction:(id)sender {
    InfoViewController *infoViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"InfoViewController"];
    [self.navigationController pushViewController:infoViewController animated:YES];
}

//File upload to dropBox
-(void)uploadFileDropBox {
    NSString *text = @"Hello world.";
    NSString *filename = @"AudioFile";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:audioFile];
}
#pragma mark - DBRestClient Delegate
- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Messsage!" message:@"File uploaded successfully to DropBox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Messsage!" message:@"File uploaded failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
          
#pragma mark - Mail Delagate
- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    if (result==MFMailComposeResultSent){
        NSLog(@"Mail Sent");
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Message Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController     willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

- (void)buyButtonTapped:(id)sender {
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    NSLog(@"Buying %@...", product.productIdentifier);
    [[RageIAPHelper sharedInstance] buyProduct:product];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    //Loading the stored files into array.
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"StoredFiles"]) {
        arrFiles = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"StoredFiles"]];
        
        //NSLog(@"Files %@", arrFiles);
        if (arrFiles.count == 0) {
            recordTableView.hidden = YES;
            stateLbl.hidden = NO;
            deleteButton.hidden = YES;
        } else {
            recordTableView.hidden = NO;
            stateLbl.hidden = YES;
            deleteButton.hidden=NO;
            for (int i = 0; i < arrFiles.count; i++) {
                [playingStateArray addObject:@"No"];
                NSString *str=[arrFiles objectAtIndex:i];
                [boolArray setValue:[NSNumber numberWithBool:NO] forKey:str];
            }
        }
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DateArray"]){
        dateArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DateArray"]];
        NSLog(@"DateArray %@", dateArray);
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"TimeArray"]){
        timeArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimeArray"]];
        NSLog(@"DateArray %@", timeArray);
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"FileNameArray"]){
        fileNameArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"FileNameArray"]];
        NSLog(@"DateArray %@", fileNameArray);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (arrFiles.count > 0) {
            [arrFiles removeObjectAtIndex:indexPath.row];
            [dateArray removeObjectAtIndex:indexPath.row];
            [timeArray removeObjectAtIndex:indexPath.row];
            
            [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
            [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
            [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [recordTableView reloadData];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark table view delegates and data source methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BOOL isPlay;
    isPlay = FALSE;
    
    NSLog(@"Playing %@", playingStateArray);
    if(arrFiles.count > 0){
        for (int i = 0; i < indexPath.row; i++) {
            if ([[playingStateArray objectAtIndex:i] isEqualToString:@"Yes"]) {
                isPlay = TRUE;
                break;
            }
        }
        
        for (NSInteger j = indexPath.row + 1; j < playingStateArray.count; j++) {
            if ([[playingStateArray objectAtIndex:j] isEqualToString:@"Yes"]) {
                isPlay = TRUE;
                break;
            }
        }
        
        if (isPlay == TRUE){
        }
        else{
            if ([[playingStateArray objectAtIndex:indexPath.row] isEqualToString:@"Yes"]) {
                [playingStateArray replaceObjectAtIndex:indexPath.row withObject:@"No"];
                [recordTableView reloadData];
                [audioPlayer stop];
            } else {
                [playingStateArray replaceObjectAtIndex:indexPath.row withObject:@"Yes"];
                [recordTableView reloadData];
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil]; // To play audio from speaker
                NSString *strURL = [NSString stringWithFormat:@"%@/Saved_%@.m4a", DOCUMENTS_FOLDER, [arrFiles objectAtIndex:indexPath.row]] ;
                NSURL *url = [NSURL URLWithString:strURL];
                
                audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                audioPlayer.numberOfLoops = 0;
                [audioPlayer setDelegate:self];
                [audioPlayer prepareToPlay];
                [audioPlayer play];
            }
        }
    }
}

- (void)playTimerAction{
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (arrFiles.count == 0) {
        recordTableView.hidden = YES;
        stateLbl.hidden = NO;
        deleteButton.hidden=YES;
    }
    else{
        recordTableView.hidden = NO;
        stateLbl.hidden = YES;
        deleteButton.hidden= NO;
    }
    return arrFiles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"customCell";
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if([[fileNameArray objectAtIndex:indexPath.row] isEqualToString:@"Snippet"]){
        //test
        int a=0;
        BOOL isSaved;
        do{
            isSaved=[self saveFile:[fileNameArray objectAtIndex:indexPath.row] value:a index:(int)indexPath.row];
            a=a+1; 
        } while (!isSaved);

        [cell.numberLbl setTitle:[fileNameArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    } else {
        [cell.numberLbl setTitle:[NSString stringWithFormat:@"%@",[fileNameArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
    }
    cell.tag=indexPath.row;
    cell.dateLbl.text = [NSString stringWithFormat:@"%@", [dateArray objectAtIndex:indexPath.row]];
    cell.timeLineLbl.text = [NSString stringWithFormat:@"00:%@", [timeArray objectAtIndex:indexPath.row]];
    
    if ([[playingStateArray objectAtIndex:indexPath.row] isEqualToString:@"No"]) {
        cell.stateImg.image=[UIImage imageNamed:@"WDUS-play.png"];
    }
    else{
        cell.stateImg.image=[UIImage imageNamed:@"WDUS-pause.png"];
    }
    cell.delegate=self;
    
    NSString *value=[arrFiles objectAtIndex:indexPath.row];
    BOOL checked=false;

    checked = [[boolArray objectForKey:value] boolValue];
    UIImage *image = (checked) ? [UIImage imageNamed:@"Pass_check.png"] : [UIImage imageNamed:@"Pass_Uncheck.png"];
    [cell.selectedBtn setImage:image forState:UIControlStateNormal];

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(BOOL)saveFile:(NSString*)filePath value:(int)x index:(int)intValue{
    NSString *finalPath;
    if(x==0){
        finalPath=filePath;
    } else {
        NSString *str = [[filePath componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
 
        NSString *name  = [str stringByAppendingString:[NSString stringWithFormat:@"-%d", x]];
        finalPath = @"";
        finalPath = [NSString stringWithFormat:@"%@", name];
    }
    
    NSLog(@"%@",fileNameArray);
    if([fileNameArray containsObject:finalPath]) {
        newName=finalPath;
        [fileNameArray replaceObjectAtIndex:intValue withObject:newName];
        [[NSUserDefaults standardUserDefaults] setObject:fileNameArray forKey:@"FileNameArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    } else {
        newName=finalPath;
        [fileNameArray replaceObjectAtIndex:intValue withObject:newName];
        [[NSUserDefaults standardUserDefaults] setObject:fileNameArray forKey:@"FileNameArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}
//Method for deleting multiple row
-(IBAction)deleteAction:(id)sender{
    NSMutableArray *arr1=[[NSMutableArray alloc]init];
    for(int i =0;i<[boolArray count];i++) {
        NSString *dic=[arrFiles objectAtIndex:i];
        BOOL checked=[[boolArray objectForKey:dic]boolValue];
        if(checked){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [arr1 addObject:indexPath];
        }
    }
    
    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    for (NSIndexPath *selectionIndex in arr1){
        [indicesOfItemsToDelete addIndex:selectionIndex.row];
    }
    [arrFiles removeObjectsAtIndexes:indicesOfItemsToDelete];
    [dateArray removeObjectsAtIndexes:indicesOfItemsToDelete];
    [timeArray removeObjectsAtIndexes:indicesOfItemsToDelete];
    [fileNameArray removeObjectsAtIndexes:indicesOfItemsToDelete];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
    [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
    [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
    [[NSUserDefaults standardUserDefaults] setObject:fileNameArray forKey:@"FileNameArray"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [boolArray removeAllObjects];
    for(int i=0; i<arrFiles.count; i++){
        NSString *str=[arrFiles objectAtIndex:i];
        [boolArray setValue:[NSNumber numberWithBool:NO] forKey:str];
    }
    [recordTableView reloadData];
    
}
-(void)useButton:(id)sender{
    NSString *dic=[arrFiles objectAtIndex:[sender tag]];
    BOOL  checked1 = [[boolArray objectForKey:dic] boolValue];
    [boolArray setValue:[NSNumber numberWithBool:!checked1] forKey:dic];
    [recordTableView reloadData];
}

-(void)useButton_label:(id)sender{
    int ab=(int)[sender tag];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Filename" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].delegate = self;
    alert.tag=1;
    [alert show];
    
    objc_setAssociatedObject(alert, &MyConstantKey, [NSNumber numberWithInt:ab], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSNumber *indexPath = objc_getAssociatedObject(alertView, &MyConstantKey);

    if(alertView.tag==1){
        if(buttonIndex==1){
            UITextField *field = [alertView textFieldAtIndex:0];
            [field resignFirstResponder];
            if([[field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]!=0) {
                if([fileNameArray containsObject:field.text]){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message!" message:@"Filename already exist." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else{
                    [fileNameArray replaceObjectAtIndex:[indexPath intValue] withObject:field.text];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:fileNameArray forKey:@"FileNameArray"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [recordTableView reloadData];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message!" message:@"Enter Filename." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
}

- (IBAction)startBtnClicked:(id)sender {
    recordLbl.text = @"Monitoring";
    
    //Start button method. Hiding animations.
    actView.hidden = TRUE;
    [actView stopAnimating];
    
    startBtn.enabled = FALSE;
    stopBtn.enabled = TRUE;
    whatSayBtn.enabled = TRUE;
    
    //Taking current date and time.
    int timestamp = [[NSDate date] timeIntervalSince1970];
    dateString = [NSString stringWithFormat:@"%d", timestamp];
    
    [self startRecording];
}

- (IBAction)recBtnClicked:(id)sender {
    actView.hidden = FALSE;
    [actView startAnimating];
    [recorder stop];
    [self fnStopRecordingAndSave];
}

// This is the function for Store Recording button which will store the recording and save it in the file.
- (void) fnStopRecordingAndSave {
    @try {
        NSString *strURL = [NSString stringWithFormat:@"%@/%@.m4a", DOCUMENTS_FOLDER, dateString];
        NSURL *url = [NSURL URLWithString:strURL];
        
        //Calculating the duration of the current recording.
        audioPlayer =   [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        audioPlayer.numberOfLoops = 0;
        [audioPlayer setDelegate:self];
        
        float duration = audioPlayer.duration;
        NSLog(@"fnStopRecordingAndSave Duration here::: %f", audioPlayer.duration);
        NSLog(@"SliderValueChanged Duration here::: %d", (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"]);
        
        if(duration < (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"]) {
            recordLbl.text = @"Storing...";
            //Creating its Asset.
            AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:strURL] options:nil];
            AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
            
            Float64 startTimeInSeconds = 0;
            Float64 durationInSeconds = audioPlayer.duration;
            
            CMTime start = CMTimeMakeWithSeconds(startTimeInSeconds, 600);
            CMTime duration1 = CMTimeMakeWithSeconds(durationInSeconds, 600);
            
            //Storing the saved file with a different name Saved
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
                        if(fileExists) {
                            if(arrFiles.count > 0){
                                [boolArray removeAllObjects];
                                
                                for(int i = 0; i<arrFiles.count;i++){
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", arrFiles];
                                    BOOL result = [predicate evaluateWithObject:dateString];
                                    
                                    if(result == FALSE){
                                        [arrFiles addObject:dateString];
                                        
                                        NSDate *currentTime = [NSDate date];
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                        NSString *date = [dateFormatter stringFromDate:currentTime];
                                        
                                        [dateArray addObject:date];
                                        [playingStateArray addObject:@"No"];
                                        [boolArray setValue:[NSNumber numberWithBool:NO] forKey:[arrFiles objectAtIndex:i]];
                                        
                                        NSString *timeline = [NSString stringWithFormat:@"0%d", (int)audioPlayer.duration];
                                        [timeArray addObject:timeline];
                                        
                                        NSString *str=[NSString stringWithFormat:@"Snippet"];
                                        [fileNameArray addObject:str];
                                    }
                                }
                            }
                            else {
                                [arrFiles addObject:dateString];
                                
                                NSDate *currentTime = [NSDate date];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                NSString *date = [dateFormatter stringFromDate:currentTime];
                                
                                [dateArray addObject:date];
                                [playingStateArray addObject:@"No"];
                                [boolArray setValue:[NSNumber numberWithBool:NO] forKey:[arrFiles objectAtIndex:0]];
                                NSString *timeline = [NSString stringWithFormat:@"0%d", (int)audioPlayer.duration];
                                [timeArray addObject:timeline];
                                
                                NSString *str=[NSString stringWithFormat:@"Snippet"];
                                [fileNameArray addObject:str];
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoredFiles"];
                        [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DateArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:fileNameArray forKey:@"FileNameArray"];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [recordTableView reloadData];
                        
                        recordLbl.text = @"Monitoring";
                        
                        //                        if([recordLbl.text isEqualToString:@"Saved"]){
                        //                            [self showAlert];
                        //                        }
                        break;
                    default:
                        NSLog(@"Export Failed");
                        break;
                }
            }];
        } else {
            recordLbl.text = @"Storing...";
            //Creating its Asset.
            AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:strURL] options:nil];
            AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];
            
            //Float64 startTimeInSeconds = audioPlayer.duration-10;
            //Float64 durationInSeconds = 10;
            Float64 startTimeInSeconds = audioPlayer.duration-(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"];
            Float64 durationInSeconds = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"];
            //Reducing the duration by 10 seconds
            CMTime start = CMTimeMakeWithSeconds(startTimeInSeconds, 600);
            CMTime duration1 = CMTimeMakeWithSeconds(durationInSeconds, 600);
            
            //Storing the saved file with a different name Saved
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
                        if(fileExists) {
                            if(arrFiles.count > 0) {
                                [boolArray removeAllObjects];
                                for(int i = 0; i<arrFiles.count;i++) {
                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", arrFiles];
                                    BOOL result = [predicate evaluateWithObject:dateString];
                                    if(result == FALSE){
                                        [arrFiles addObject:dateString];
                                        
                                        NSDate *currentTime = [NSDate date];
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                        NSString *date = [dateFormatter stringFromDate:currentTime];
                                        
                                        [dateArray addObject:date];
                                        [playingStateArray addObject:@"No"];
                                        [boolArray setValue:[NSNumber numberWithBool:NO] forKey:[arrFiles objectAtIndex:i]];
                                        
                                        //[timeArray addObject:@"10"];//Add slider time here
                                        [timeArray addObject:[NSString stringWithFormat:@"%d",(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"]]];
                                        NSString *str=[NSString stringWithFormat:@"Snippet"];
                                        [fileNameArray addObject:str];
                                    }
                                }
                            }
                            else {
                                [arrFiles addObject:dateString];
                                
                                NSDate *currentTime = [NSDate date];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"dd/MM/yyyy, hh:mm:ss a"];// here set format which you want...
                                NSString *date = [dateFormatter stringFromDate:currentTime];
                                
                                [dateArray addObject:date];
                                [playingStateArray addObject:@"No"];
                                [boolArray setValue:[NSNumber numberWithBool:NO] forKey:[arrFiles objectAtIndex:0]];
                                //[timeArray addObject:@"10"];
                                [timeArray addObject:[NSString stringWithFormat:@"%d",(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"SliderValueChanged"]]];
                                NSString *str=[NSString stringWithFormat:@"Snippet"];
                                [fileNameArray addObject:str];
                            }
                        }
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StoredFiles"];
                        [[NSUserDefaults standardUserDefaults] setObject:arrFiles forKey:@"StoredFiles"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DateArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:dateArray forKey:@"DateArray"];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TimeArray"];
                        [[NSUserDefaults standardUserDefaults] setObject:timeArray forKey:@"TimeArray"];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:fileNameArray forKey:@"FileNameArray"];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [recordTableView reloadData];
                        recordLbl.text = @"Monitoring";
                        //                        if([recordLbl.text isEqualToString:@"Saved"]){
                        //                            [self showAlert];
                        //                        }
                        break;
                    default:
                        NSLog(@"Export Failed");
                        break;
                }
            }];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
}

-(void)fnStartRecordingAgain{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    dateString = [NSString stringWithFormat:@"%d", timestamp];
    [self startRecording];
}

-(IBAction)stopBtnClicked:(id)sender{
    recordLbl.text = @"Off";
    
    startBtn.enabled = TRUE;
    stopBtn.enabled = FALSE;
    whatSayBtn.enabled = FALSE;
    
    [self stopRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (flag) {
        NSLog(@"Successful!");
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [audioPlayer stop];
    for (int i=0; i<playingStateArray.count; i++) {
        [playingStateArray replaceObjectAtIndex:i withObject:@"No"];
    }
    [recordTableView reloadData];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning" message: [err localizedDescription]delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (void) stopRecording {
    [recorder stop];
}

-(IBAction)settingAction:(id)sender{
    SettingViewController *setting  = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self presentViewController:setting animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
