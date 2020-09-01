//
//  AppDelegate.m
//  openadsdk
//
//  Created by Franky Lee on 2020/9/1.
//  Copyright © 2020 Franky Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //创建根视图控制器
    ViewController* rootVC = [[ViewController alloc] init];
    
    //创建UINavigationController，将根视图控制器作为它的根视图
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    //设置window的根视图控制器为UINavigationController
    self.window.rootViewController = navVC;
    
    //显示Window
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
