//
//  BUGCore.h
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BUGAccount.h"
#import "BUGReporter.h"

#define WORKTILE_APPKEY @"330fa04d407848db935a0c106034b9a5"
#define WORKTILE_APPSECRET @"9cae921e877b47419efcad4dbcdcd27b"
#define WORKTILE_CALLBACK_URL @"http://bug.snh48.com/response"

@interface BUGCore : NSObject

+ (BUGCore *)sharedCore;

@property (nonatomic, readonly) BUGAccount *account;

@property (nonatomic, readonly) BUGReporter *reporter;

@end
