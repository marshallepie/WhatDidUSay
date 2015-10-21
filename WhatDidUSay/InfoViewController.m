//
//  InfoViewController.m
//  WhatDidUSay
//
//  Created by Dottechnologies on 21/10/15.
//  Copyright (c) 2015 xxx. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()<UIWebViewDelegate>

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [activityIndicator startAnimating];
    activityIndicator.color = [UIColor blackColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(loadInfoOnWebView) withObject:nil afterDelay:0.05];
}
- (void)loadInfoOnWebView {
    NSString *path;
    NSBundle *thisBundle = [NSBundle mainBundle];
    path = [thisBundle pathForResource:@"info" ofType:@"html"];

    NSURL *informationURL = [NSURL fileURLWithPath:path];
    [infoWebView loadRequest:[NSURLRequest requestWithURL:informationURL]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicator stopAnimating];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [activityIndicator stopAnimating];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
