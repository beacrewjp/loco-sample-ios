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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
