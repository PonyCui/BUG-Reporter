//
//  BUGEnvManager.h
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BUGEnvManager : NSObject

@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *userEnvParams;

- (NSDictionary<NSString *, NSString *> *)allEnvParams;

@end
