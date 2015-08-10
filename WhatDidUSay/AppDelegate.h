//
//  AppDelegate.h
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{    UIWindow *window;

    NSString *relinkUserId;
    ViewController *viewController;
    UINavigationController *navigationController;

}
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;


@end

