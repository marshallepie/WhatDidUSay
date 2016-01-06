//
//  AppDelegate.m
//  WhatDidUSay
//
//  Created by iOS on 18/07/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ViewController.h"
#import "RageIAPHelper.h"

@interface AppDelegate ()<DBSessionDelegate, DBNetworkRequestDelegate>
@end

@implementation AppDelegate
@synthesize navigationController;
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    sleep(1);
    [RageIAPHelper sharedInstance];
    NSString *dropBoxAppKey = @"e5pwc7gq7s6s881";
    NSString *dropBoxAppSecret = @"mdsexprr4uc7xwr";
    NSString *root = kDBRootDropbox;
    DBSession* session = [[DBSession alloc] initWithAppKey:dropBoxAppKey appSecret:dropBoxAppSecret root:root];
    session.delegate = self;
    [DBSession setSharedSession:session];
    [DBRequest setNetworkRequestDelegate:self];
    
    NSString *dataPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Default"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isApplicationLaunchedFirstTime"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"SliderValueChanged"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isApplicationLaunchedFirstTime"];
    }
    if ([[DBSession sharedSession] isLinked]) {
        self.navigationController.viewControllers =
        [NSArray arrayWithObjects:viewController, nil];
    }
    [window addSubview:navigationController.view];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //[UITabBar appearance].backgroundImage = [UIImage imageNamed:@"TabBarBg-new.png"];

    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"TabBarBg2.png"]];
    [window makeKeyAndVisible];
    return YES;
}

//Method for open URL
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [viewController uploadFileDropBox];
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
    [[[UIAlertView alloc] initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil] show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    if (index != alertView.cancelButtonIndex) {
        [[DBSession sharedSession] linkUserId:relinkUserId fromController:viewController];
    }
    relinkUserId = nil;
}

#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


@end
