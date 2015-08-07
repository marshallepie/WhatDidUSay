//
//  CustomTableViewCell.h
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ButtonDelegate<NSObject>
@optional
-(void)useButton:(id)sender;
@end

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLineLbl;
@property (weak, nonatomic) IBOutlet UIImageView *stateImg;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;
@property(strong,nonatomic)id<ButtonDelegate> delegate;
-(IBAction)selectedAction:(id)sender;
@end
