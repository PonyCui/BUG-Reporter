//
//  BUGCore.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "BUGCore.h"

@interface BUGCore ()

@property (nonatomic, strong) BUGAccount *account;

@property (nonatomic, strong) BUGReporter *reporter;

@property (nonatomic, strong) BUGImageEditor *imageEditor;

@property (nonatomic, strong) BUGEnvManager *envManager;

@end

@implementation BUGCore

+ (void)load {
    [[BUGCore sharedCore] installGesture];
}

+ (BUGCore *)sharedCore {
    static BUGCore *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BUGCore alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _account = [[BUGAccount alloc] init];
        _reporter = [[BUGReporter alloc] init];
        _imageEditor = [[BUGImageEditor alloc] init];
        _envManager = [[BUGEnvManager alloc] init];
    }
    return self;
}

- (void)installGesture {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] keyWindow] == nil) {
            [self installGesture];
            return ;
        }
        UIScreenEdgePanGestureRecognizer *gesture = [[UIScreenEdgePanGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(handleScreenGestureTrigger:)];
        gesture.edges = UIRectEdgeRight;
        gesture.minimumNumberOfTouches = 1;
        [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:gesture];
    });
}

- (void)handleScreenGestureTrigger:(UIScreenEdgePanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (!self.account.isAuthorized) {
            [self.account showAuthorizeWebView];
        }
        else {
            [self.reporter makeScreenShot];
            [self.reporter showReporterViewController];
        }
    }
}

@end
