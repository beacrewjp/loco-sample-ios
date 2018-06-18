//
//  AppDelegate.m
//  LocoTutorial
//
//  Created by Y.Sekimoto on 2018/06/12.
//  Copyright © 2018 Beacrew Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <MQTTClient/MQTTLog.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 通知の許可を得る
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    notificationCenter.delegate = self;
    [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionSound|UNAuthorizationOptionAlert
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                      }];
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
