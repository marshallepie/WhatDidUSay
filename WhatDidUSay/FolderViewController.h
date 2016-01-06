//
//  FolderViewController.h
//  WhatDidUSay
//
//  Created by dotmac4 on 28/12/15.
//  Copyright © 2015 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderViewController : UIViewController {
    NSMutableArray *folderNameArray;
    __weak IBOutlet UITableView *tblFolder;
    //NSMutableArray *inAppCountArray;
}
- (IBAction)createFolderButtonAction:(id)sender;

@end
