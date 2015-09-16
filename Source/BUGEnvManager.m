//
//  BUGEnvManager.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUGEnvManager.h"

@implementation BUGEnvManager

- (NSDictionary<NSString *,NSString *> *)allEnvParams {
    NSMutableDictionary<NSString *, NSString *> *envParams = [NSMutableDictionary dictionary];
    [self.userEnvParams enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [envParams setObject:obj forKey:key];
    }];
    [envParams setObject:[[UIDevice currentDevice] systemVersion] forKey:@"iOS Version"];
    [envParams setObject:[[UIDevice currentDevice] model] forKey:@"Device Model"];
    return [envParams copy];
}

@end
