//
//  ViewController.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "ViewController.h"
#import "BUGCore.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[BUGCore sharedCore] envManager] setUserEnvParams:@{@"API环境": @"生产环境"}];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.kootv.com/"]]];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end