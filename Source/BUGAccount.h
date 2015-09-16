//
//  BUGAccount.h
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^BUGRequestBlock)(NSArray<NSString *> * __nullable ids,
                               NSDictionary<NSString *, NSString *> * __nullable maps);

@interface BUGAccount : NSObject

@property (nullable, nonatomic, readonly) NSString *accessToken;

- (BOOL)isAuthorized;

- (void)showAuthorizeWebView;

- (void)requestProjectsWithCompletionBlock:(nonnull BUGRequestBlock)completionBlock;

- (void)requestEntriesWithPid:(nonnull NSString *)pid completionBlock:(nonnull BUGRequestBlock)completionBlock;

- (void)composeWithPid:(nonnull NSString *)pid
               entryId:(nonnull NSString *)entryId
            issueTitle:(nonnull NSString *)issueTitle
           issueImages:(nullable NSArray<NSData *> *)issueImages
       completionBlock:(nullable void (^)())completionBlock
          failureBlock:(nullable void (^)())failureBlock;

@end
