//
//  BUGReporter.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "BUGReporter.h"
#import "BUGCore.h"

@interface BUGReporter ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, BUGImageEditorDelegate>

@property (nullable, nonatomic, strong) UIImage *lastScreenShot;

@property (nonnull, nonatomic, strong) UIViewController *reporterViewController;

@property (nonnull, nonatomic, strong) UIBarButtonItem *closeButtonItem;

@property (nonnull, nonatomic, strong) UIBarButtonItem *sendButtonItem;

@property (nonnull, nonatomic, strong) UITableView *reporterTableView;

@property (nullable, nonatomic, copy) NSString *issueTitle;

@property (nonnull, nonatomic, strong) UIAlertView *issueTitleAlertView;

@property (nullable, nonatomic, copy) NSArray<NSData *> *issueImages;

@property (nullable, nonatomic, copy) NSArray<NSString *> *pids;

@property (nullable, nonatomic, copy) NSString *pid;

@property (nonnull, nonatomic, strong) UIActionSheet *pidActionSheet;

@property (nullable, nonatomic, copy) NSArray<NSString *> *entryids;

@property (nullable, nonatomic, copy) NSString *entryid;

@property (nonnull, nonatomic, strong) UIActionSheet *entryActionSheet;

@property (nullable, nonatomic, copy) NSDictionary<NSString *, NSString *> *maps;

@end

@implementation BUGReporter

static UIWindow *window;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maps = @{};
    }
    return self;
}

- (void)makeScreenShot {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.lastScreenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)showReporterViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelNormal + 1;
    });
    if (self.lastScreenShot != nil) {
        NSData *lastScreenShotData = UIImageJPEGRepresentation(self.lastScreenShot, 0.8);
        if (lastScreenShotData != nil) {
            self.issueImages = @[lastScreenShotData];
        }
        else {
            self.issueImages = @[];
        }
    }
    else {
        self.issueImages = @[];
    }
    self.issueTitle = nil;
    self.reporterViewController.navigationItem.rightBarButtonItem.enabled = YES;
    [self.reporterTableView reloadData];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:self.reporterViewController];
    navigationController.navigationBar.translucent = NO;
    window.rootViewController = navigationController;
    window.hidden = NO;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [self theProjectCell];
        }
        else if (indexPath.row == 1) {
            return [self theGroupCell];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [self theIssueTitleCell];
        }
        else if (indexPath.row == 1) {
            return [self theIssueScreenShot];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)theProjectCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = @"项目";
    cell.detailTextLabel.text = @"请选择";
    if (self.pid != nil) {
        NSString *pName = self.maps[self.pid];
        if (pName != nil) {
            cell.detailTextLabel.text = pName;
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)theGroupCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = @"列表";
    cell.detailTextLabel.text = @"请选择";
    if (self.entryid != nil) {
        NSString *eName = self.maps[self.entryid];
        if (eName != nil) {
            cell.detailTextLabel.text = eName;
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)theIssueTitleCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = @"主题";
    cell.detailTextLabel.text = @"[空]";
    if (self.issueTitle != nil) {
        cell.detailTextLabel.text = self.issueTitle;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)theIssueScreenShot {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = @"附件";
    cell.detailTextLabel.text = @"[空]";
    if ([self.issueImages count] > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu张图片", [self.issueImages count]];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"报告目标";
    }
    else if (section == 1) {
        return @"问题描述";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44.0;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 70.0;
        }
        else if (indexPath.row == 1) {
            return 70.0;
        }
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        [[[BUGCore sharedCore] account] requestProjectsWithCompletionBlock:^(NSArray<NSString *> * _Nullable ids, NSDictionary<NSString *,NSString *> * _Nullable maps) {
            self.pids = ids;
            NSMutableDictionary<NSString *, NSString *> *mutableMaps = [self.maps mutableCopy];
            [maps enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [mutableMaps setObject:obj forKey:key];
            }];
            self.maps = mutableMaps;
            [self updatePidActionSheet];
            [self.pidActionSheet showInView:self.reporterViewController.view];
        }];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        [[[BUGCore sharedCore] account] requestEntriesWithPid:_pid completionBlock:^(NSArray<NSString *> * _Nullable ids, NSDictionary<NSString *,NSString *> * _Nullable maps) {
            self.entryids = ids;
            NSMutableDictionary<NSString *, NSString *> *mutableMaps = [self.maps mutableCopy];
            [maps enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [mutableMaps setObject:obj forKey:key];
            }];
            self.maps = mutableMaps;
            [self updateEntryActionSheet];
            [self.entryActionSheet showInView:self.reporterViewController.view];
        }];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [[self.issueTitleAlertView textFieldAtIndex:0] setText:self.issueTitle];
        [self.issueTitleAlertView show];
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        [[[BUGCore sharedCore] imageEditor] setDelegate:self];
        [[[BUGCore sharedCore] imageEditor]
         showEditorViewControllerWithImages:self.issueImages
         navigationController:self.reporterViewController.navigationController];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.pidActionSheet) {
        if (buttonIndex - 1 < [self.pids count]) {
            self.pid = self.pids[buttonIndex - 1];
            [self.reporterTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if (actionSheet == self.entryActionSheet) {
        if (buttonIndex - 1 < [self.entryids count]) {
            self.entryid = self.entryids[buttonIndex - 1];
            [self.reporterTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.issueTitleAlertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            self.issueTitle = [[alertView textFieldAtIndex:0] text];
            [self.reporterTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]]
                                          withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - BUGImageEditorDelegate

- (void)imageEditorDidChangedImages:(NSArray<NSData *> *)images {
    self.issueImages = images;
    [self.reporterTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]]
                                  withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Getter

- (UIViewController *)reporterViewController {
    if (_reporterViewController == nil) {
        _reporterViewController = [[UIViewController alloc] init];
        _reporterViewController.title = @"报告问题";
        _reporterViewController.navigationItem.leftBarButtonItem = self.closeButtonItem;
        _reporterViewController.navigationItem.rightBarButtonItem = self.sendButtonItem;
        self.reporterTableView.frame = _reporterViewController.view.bounds;
        [_reporterViewController.view addSubview:self.reporterTableView];
    }
    return _reporterViewController;
}

- (UIBarButtonItem *)closeButtonItem {
    if (_closeButtonItem == nil) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(handleCloseButtonTapped)];
    }
    return _closeButtonItem;
}

- (void)handleCloseButtonTapped {
    window.hidden = YES;
}

- (UIBarButtonItem *)sendButtonItem {
    if (_sendButtonItem == nil) {
        _sendButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(handleSendButtonTapped)];
    }
    return _sendButtonItem;
}

- (void)handleSendButtonTapped {
    self.sendButtonItem.enabled = NO;
    [[[BUGCore sharedCore] account]
     composeWithPid:self.pid
     entryId:self.entryid
     issueTitle:self.issueTitle
     issueImages:self.issueImages
     completionBlock:^{
         window.hidden = YES;
     } failureBlock:^{
         window.hidden = YES;
         self.sendButtonItem.enabled = YES;
         NSLog(@"发送失败");
     }];
}

- (UITableView *)reporterTableView {
    if (_reporterTableView == nil) {
        _reporterTableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStyleGrouped];
        _reporterTableView.delegate = self;
        _reporterTableView.dataSource = self;
    }
    return _reporterTableView;
}

- (UIAlertView *)issueTitleAlertView {
    if (_issueTitleAlertView == nil) {
        _issueTitleAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入反馈主题" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        _issueTitleAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    return _issueTitleAlertView;
}

- (UIActionSheet *)pidActionSheet {
    if (_pidActionSheet == nil) {
        _pidActionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择项目"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil, nil];
    }
    return _pidActionSheet;
}

- (void)updatePidActionSheet {
    _pidActionSheet = nil;
    [self.pids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *buttonTitle = self.maps[obj];
        if (buttonTitle != nil) {
            [self.pidActionSheet addButtonWithTitle:buttonTitle];
        }
    }];
}

- (UIActionSheet *)entryActionSheet {
    if (_entryActionSheet == nil) {
        _entryActionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择列表"
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil, nil];
    }
    return _entryActionSheet;
}

- (void)updateEntryActionSheet {
    _entryActionSheet = nil;
    [self.entryids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *buttonTitle = self.maps[obj];
        if (buttonTitle != nil) {
            [self.entryActionSheet addButtonWithTitle:buttonTitle];
        }
    }];
}

@end
