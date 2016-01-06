//
//  FolderViewController.m
//  WhatDidUSay
//
//  Created by dotmac4 on 28/12/15.
//  Copyright © 2015 xxx. All rights reserved.
//

#import "FolderViewController.h"
#import "ViewController.h"

@interface FolderViewController ()<UIAlertViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation FolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    folderNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getFolderNameFromDocumentDirectory];
    //NSLog(@"folderNameArray  == %@", folderNameArray);
    //folderNameArray = [[NSMutableArray alloc]initWithObjects:@"Default", nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFolderNameFromDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    [folderNameArray removeAllObjects];
    for (NSString *s in fileList) {
        if (![s containsString:@".m4a"]&& ![s containsString:@".DS_Store"]) {
            [folderNameArray addObject:s];
        }
    }
}

- (BOOL)deleteFolderNameFromDocumentDirectory:(NSString*)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:folderName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return folderNameArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    NSString *folderName = [folderNameArray objectAtIndex:indexPath.row];
    if ([folderName containsString:@"$_&"]) {
        folderName = [folderName stringByReplacingOccurrencesOfString:@"$_&" withString:@" "];
    }
    cell.textLabel.text = folderName;
    cell.imageView.image = [UIImage imageNamed:@"folder"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController * controller = (ViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    controller.folderName = [folderNameArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
    //[self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure, you want to delete this folder?" message:@"\n" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag=1001+indexPath.row;
        [alert show];
    }
}

- (IBAction)createFolderButtonAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Folder name" message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].delegate = self;
    alert.tag=113;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag==113) {
        if(buttonIndex==1) {
            UITextField *field = [alertView textFieldAtIndex:0];
            [field resignFirstResponder];
            if([[field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]!=0) {
                NSString *folderName = field.text;
                if ([folderName containsString:@" "]) {
                    folderName = [folderName stringByReplacingOccurrencesOfString:@" " withString:@"$_&"];
                }
                NSString *dataPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",folderName]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
                [self getFolderNameFromDocumentDirectory];
                [tblFolder reloadData];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message!" message:@"Please enter folder." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    } else {
        if(buttonIndex==1) {
            if ([self deleteFolderNameFromDocumentDirectory:[folderNameArray objectAtIndex:alertView.tag-1001]]) {
                [folderNameArray removeObjectAtIndex:alertView.tag-1001];
                [tblFolder reloadData];
            }
        } else {
            [tblFolder endEditing:YES];
            [tblFolder reloadData];
        }
    }
}

@end
