//
//  BUGImageEditer.h
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BUGImageEditorDelegate <NSObject>

- (void)imageEditorDidChangedImages:(NSArray<NSData *> *)images;

@end

@interface BUGImageEditor : NSObject

@property (nonatomic, weak) id<BUGImageEditorDelegate> delegate;

- (void)showEditorViewControllerWithImages:(NSArray<NSData *> *)images
                      navigationController:(UINavigationController *)navigationController;

@end
