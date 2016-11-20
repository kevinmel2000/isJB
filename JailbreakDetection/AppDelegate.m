//
//  AppDelegate.m
//  JailbreakDetection
//
//  Created by Augusta Bogie on 2/13/16.
//  Copyright © 2016 Augusta Bogie. All rights reserved.
//

#import "AppDelegate.h"
#import "JBDetect.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *vc = [[ViewController alloc] init];
    vc.view.frame = self.window.frame;
    vc.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    vc.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = [UIImage imageNamed:@"Hi"];
    img.backgroundColor = [UIColor whiteColor];
    img.center = vc.view.center;
    [vc.view addSubview:img];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor greenColor];
    button.frame = CGRectMake(0, 0, 260, 44);
    button.layer.cornerRadius = 5.0;
    button.layer.borderWidth = 3;
    button.layer.borderColor = [UIColor greenColor].CGColor;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    button.center = self.window.center;
    [button addTarget:vc action:@selector(checkSSLPinning:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Chcek SSL Pinning" forState:UIControlStateNormal];
    [vc.view addSubview:button];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.window.hidden = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.window.hidden = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:[UIAlertView class]]) {
            [(UIAlertView *)view dismissWithClickedButtonIndex:[(UIAlertView *)view cancelButtonIndex] animated:YES];
        }
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    CFUUIDRef udid = CFUUIDCreate(NULL);
    NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
    
    NSString *composedMessage = [NSString stringWithFormat:@"OS : %@\nUDID : \n%@\nIs JailBreak : %@\nIs Cracked : %@\nIs Appstore Version : %@", [[UIDevice currentDevice] systemVersion], udidString, (isJB()? @"YES":@"NO"), (isCracked()? @"YES":@"NO"), (isAppStore()? @"YES":@"NO")];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device information" message:composedMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
