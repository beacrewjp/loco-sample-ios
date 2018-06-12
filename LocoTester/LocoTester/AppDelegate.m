//
//  AppDelegate.m
//  LocoTester
//
//  Created by Y.Sekimoto on 2018/06/01.
//  Copyright 2018 Beacrew Inc.
//

#import "AppDelegate.h"
#import <MQTTClient/MQTTLog.h>

@implementation AppDelegate

// SDK SECRETの初期値をセット
static NSString *kSDKSecret = @"<ENTER YOUR SDK SECRET>";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 通知の許可を得る
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionSound|UNAuthorizationOptionAlert
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                      }];
    
    // SDK SECRETをUserDefaultsに保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud registerDefaults:@{@"SDK_SECRET": kSDKSecret}];

    // MQTTのログレベルを設定
    [MQTTLog setLogLevel:DDLogLevelWarning];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
