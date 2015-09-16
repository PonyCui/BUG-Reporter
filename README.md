# BUG-Reporter

这是一个基于Worktile API开发的iOS应用BUG提交SDK

使用此SDK，测试人员可以快捷地在手机上提交BUG至worktile中，每一个BUG的提交过程不超过1分钟。

## BUG提交过程演示

* 手指在任何时候，于手机屏幕右侧向左划动，即可调起BUG提交界面。

![](https://raw.githubusercontent.com/PonyCui/BUG-Reporter/master/screenshot/issue_commit.gif)

![](https://raw.githubusercontent.com/PonyCui/BUG-Reporter/master/screenshot/worktile_detail.png)

## 安装及配置

### 安装

#### CocoaPods

```pod 'BUG-Reporter', :podspec => 'https://raw.githubusercontent.com/PonyCui/BUG-Reporter/master/BUG-Reporter.podspec'```

#### 手动安装

将 Source 下所有文件添加到自己的工程文件即可

### 配置

无须任何配置，即可开始使用BUG-Reporter。

如果需要自定义自己的环境参数 ```[[[BUGCore sharedCore] envManager] setUserEnvParams:@{@"API环境": @"生产环境"}];```
