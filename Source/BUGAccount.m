//
//  BUGAccount.m
//  BUG Reporter
//
//  Created by 崔 明辉 on 15/9/16.
//  Copyright © 2015年 PonyCui. All rights reserved.
//

#import "BUGCore.h"
#import "BUGAccount.h"

@interface BUGAccount ()<UIWebViewDelegate>

@property (nullable, nonatomic, readwrite) NSString *accessToken;

@property (nullable, nonatomic, readwrite) NSDate *accessTokenExpiresDate;

@property (nonnull, nonatomic, strong) UIViewController *authorizeViewController;

@property (nonnull, nonatomic, strong) UIBarButtonItem *closeButtonItem;

@property (nonnull, nonatomic, strong) UIWebView *webView;

@end

@implementation BUGAccount

- (void)dealloc
{
    _webView.delegate = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self readToken];
    }
    return self;
}

- (BOOL)isAuthorized {
    return self.accessToken != nil;
}

- (void)showAuthorizeWebView {
    if (self.isAuthorized) {
        return;
    }
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:self.authorizeViewController];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:navigationController animated:YES completion:^{
         [self.webView loadRequest:[self authorizeRequest]];
    }];
}

- (NSURLRequest *)authorizeRequest {
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://open.worktile.com/oauth2/authorize?client_id=%@&redirect_uri=%@", WORKTILE_APPKEY, WORKTILE_CALLBACK_URL]]];
}

#pragma mark - Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] absoluteString] hasPrefix:WORKTILE_CALLBACK_URL]) {
        
        NSString *codePrefix = [NSString stringWithFormat:@"%@?code=", WORKTILE_CALLBACK_URL];
        NSString *codeString = [[[request URL] absoluteString]
                                stringByReplacingOccurrencesOfString:codePrefix withString:@""];
        NSString *tokenRequestURLString = [NSString stringWithFormat:@"https://api.worktile.com/oauth2/access_token"];
        NSMutableURLRequest *tokenRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tokenRequestURLString]];
        [tokenRequest setHTTPMethod:@"POST"];
        NSString *bodyString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", WORKTILE_APPKEY, WORKTILE_APPSECRET, codeString];
        [tokenRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        [NSURLConnection sendAsynchronousRequest:tokenRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (data != nil) {
                NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
                if ([JSONObject isKindOfClass:[NSDictionary class]] &&
                    [JSONObject[@"access_token"] isKindOfClass:[NSString class]] &&
                    [JSONObject[@"expires_in"] isKindOfClass:[NSNumber class]]) {
                    self.accessToken = JSONObject[@"access_token"];
                    self.accessTokenExpiresDate = [NSDate dateWithTimeIntervalSinceNow:[JSONObject[@"expires_in"] floatValue]];
                    [self updateToken];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.authorizeViewController dismissViewControllerAnimated:YES
                                                                         completion:nil];
                    });
                }
            }
        }];
        return NO;
    }
    return YES;
}

#pragma mark - Request

- (void)requestProjectsWithCompletionBlock:(BUGRequestBlock)completionBlock {
    NSString *URLString = @"https://api.worktile.com/v1/projects";
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:URLString]];
    [request setValue:self.accessToken forHTTPHeaderField:@"access_token"];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         if (data != nil) {
             NSArray *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
             if ([JSONObject isKindOfClass:[NSArray class]]) {
                 NSMutableArray<NSString *> *pids = [NSMutableArray array];
                 NSMutableDictionary<NSString *, NSString *> *maps = [NSMutableDictionary dictionary];
                 [JSONObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([obj isKindOfClass:[NSDictionary class]]) {
                         NSString *pid = obj[@"pid"];
                         NSString *name = obj[@"name"];
                         if ([pid isKindOfClass:[NSString class]] &&
                             [name isKindOfClass:[NSString class]]) {
                             [pids addObject:pid];
                             [maps setObject:name forKey:pid];
                         }
                     }
                 }];
                 completionBlock([pids copy], [maps copy]);
             }
         }
    }];
}

- (void)requestEntriesWithPid:(NSString *)pid completionBlock:(BUGRequestBlock)completionBlock {
    NSString *URLString = [NSString stringWithFormat:@"https://api.worktile.com/v1/entries?pid=%@", pid];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:URLString]];
    [request setValue:self.accessToken forHTTPHeaderField:@"access_token"];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         if (data != nil) {
             NSArray *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
             if ([JSONObject isKindOfClass:[NSArray class]]) {
                 NSMutableArray<NSString *> *eids = [NSMutableArray array];
                 NSMutableDictionary<NSString *, NSString *> *maps = [NSMutableDictionary dictionary];
                 [JSONObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     if ([obj isKindOfClass:[NSDictionary class]]) {
                         NSString *eid = obj[@"entry_id"];
                         NSString *name = obj[@"name"];
                         if ([eid isKindOfClass:[NSString class]] &&
                             [name isKindOfClass:[NSString class]]) {
                             [eids addObject:eid];
                             [maps setObject:name forKey:eid];
                         }
                     }
                 }];
                 completionBlock([eids copy], [maps copy]);
             }
         }
     }];
}

- (void)composeWithPid:(NSString *)pid
               entryId:(NSString *)entryId
            issueTitle:(NSString *)issueTitle
           issueImages:(nullable NSArray<NSData *> *)issueImages
       completionBlock:(void (^)())completionBlock
          failureBlock:(void (^)())failureBlock {
    NSString *URLString = [NSString stringWithFormat:@"https://api.worktile.com/v1/task?pid=%@", pid];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:self.accessToken forHTTPHeaderField:@"access_token"];
    NSString *bodyString = [NSString stringWithFormat:@"name=%@&entry_id=%@", issueTitle, entryId];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         if (connectionError == nil) {
             if (data != nil) {
                 NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
                 if ([JSONObject isKindOfClass:[NSDictionary class]] &&
                     [JSONObject[@"tid"] isKindOfClass:[NSString class]]) {
                     NSString *tid = JSONObject[@"tid"];
                     [self sendEnvParamsWithIssueID:tid andPid:pid];
                     [self updateImagesWithIssueID:tid andPid:pid issueImages:issueImages];
                 }
             }
             if (completionBlock) {
                 completionBlock();
             }
         }
         else {
             if (failureBlock) {
                 failureBlock();
             }
         }
     }];
}

- (void)sendEnvParamsWithIssueID:(NSString *)issueID andPid:(NSString *)pid {
    NSString *URLString = [NSString stringWithFormat:@"https://api.worktile.com/v1/tasks/%@/comment?pid=%@",
                           issueID,
                           pid];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:self.accessToken forHTTPHeaderField:@"access_token"];
    NSMutableString *messageString = [NSMutableString string];
    [[[[BUGCore sharedCore] envManager] allEnvParams] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [messageString appendFormat:@"%@ : %@\n", key, obj];
    }];
    NSString *bodyString = [NSString stringWithFormat:@"message=%@", [messageString copy]];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
    }];
}

- (void)updateImagesWithIssueID:(NSString *)issueID andPid:(NSString *)pid issueImages:(nullable NSArray<NSData *> *)issueImages {
    [issueImages enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://1.bugreporter.applinzi.com/"]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:obj];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (connectionError == nil) {
                NSString *fileURLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *URLString = [NSString stringWithFormat:@"https://api.worktile.com/v1/tasks/%@/comment?pid=%@",
                                       issueID,
                                       pid];
                NSMutableURLRequest *request = [NSMutableURLRequest
                                                requestWithURL:[NSURL URLWithString:URLString]];
                [request setHTTPMethod:@"POST"];
                [request setValue:self.accessToken forHTTPHeaderField:@"access_token"];
                NSString *fileString = [NSString stringWithFormat:@"![](%@)", fileURLString];
                NSString *bodyString = [NSString stringWithFormat:@"message=%@", fileString];
                [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                    
                }];
            }
        }];
    }];
}

#pragma mark - Token Store 

- (void)readToken {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"BUGReporter.accessToken"];
    NSDate *accessTokenExpiresDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"BUGReporter.accessTokenExpiresDate"];
    if ([accessTokenExpiresDate timeIntervalSinceNow] > 0) {
        self.accessToken = accessToken;
        self.accessTokenExpiresDate = accessTokenExpiresDate;
    }
}

- (void)updateToken {
    if (self.accessToken != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:@"BUGReporter.accessToken"];
    }
    if (self.accessTokenExpiresDate != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:self.accessTokenExpiresDate forKey:@"BUGReporter.accessTokenExpiresDate"];
    }
    
}

#pragma mark - Getter

- (UIViewController *)authorizeViewController {
    if (_authorizeViewController == nil) {
        _authorizeViewController = [[UIViewController alloc] init];
        _authorizeViewController.navigationItem.rightBarButtonItem = self.closeButtonItem;
        _authorizeViewController.title = @"授权";
        [_authorizeViewController.view addSubview:self.webView];
        self.webView.frame = _authorizeViewController.view.bounds;
    }
    return _authorizeViewController;
}

- (UIBarButtonItem *)closeButtonItem {
    if (_closeButtonItem == nil) {
        _closeButtonItem = [[UIBarButtonItem alloc]
                            initWithTitle:@"关闭"
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(handleCloseButtonTapped)];
    }
    return _closeButtonItem;
}

- (void)handleCloseButtonTapped {
    [self.authorizeViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _webView;
}


@end
