//
//  AppDelegate.m
//  drawRectangle
//
//  Created by benjaminlmz@qq.com on 2020/3/9.
//  Copyright © 2020 Tony. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    _window.opaque = YES;
    TestViewController *vc = [[TestViewController alloc]init];
    vc.view.backgroundColor = [UIColor whiteColor];
    _window.rootViewController = vc;
    [_window makeKeyAndVisible];
    
    return YES;
}


@end
