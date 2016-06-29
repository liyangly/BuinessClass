//
//  AppDelegate.m
//  BusinessClass
//
//  Created by 李阳 on 16/6/29.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImage+LV.h"
#import "VersionUtil.h"
#import "FirstViewController.h"

@interface AppDelegate () {
    UIAlertView *versionalert;
    NSString *_appurl;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self customizeInterface];
    [self initRootViewControllerForWindow];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    
    //这里程序被唤醒，一般会有一些操作，比如执行手势锁操作
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -- Private Method
- (void)initRootViewControllerForWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UIViewController *rootVC = [[FirstViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self.window makeKeyAndVisible];
}

//设置导航栏
- (void)customizeInterface{
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat navHeight = 64.0;
    CGSize  imageSize = CGSizeMake(screenWidth, navHeight);
    UIImage *image = [UIImage imageNamed:@"ic_navHead.png"];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        
        backgroundImage = [UIImage scaleToSize:image size:imageSize];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage scaleToSize:image size:imageSize];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor whiteColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    navigationBarAppearance.tintColor = [UIColor whiteColor];
    
    //更改状态栏
    //1.工程对应的 info.plist 里面加上View controller-based status bar appearance  BOOL值设为NO，即把控制器控制状态栏的权限给禁了，用UIApplication来控制。但是这种做法在iOS9不建议使用了，然后设置target ~> general ~> development info 状态栏是否需要设置成light （设置应用是否横屏也在这）
    //2.不修改plist文件，我们只需要在控制器里写如下方法
    //    - (UIStatusBarStyle)preferredStatusBarStyle {
    //        return UIStatusBarStyleLightContent;
    //    }
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
}

//版本升级
- (void)findversion {
    
    [VersionUtil findVersionwithurl:@"" success:^(NSDictionary *dict) {
        
        _appurl = [dict valueForKeyPath:@"appUrl"];
        NSString *alertTitle = [dict valueForKeyPath:@"alertTitle"];
        NSString *alertInfo = [dict valueForKeyPath:@"alertInfo"];
        if (_appurl == nil) {
            return ;
        }
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            
            UIAlertController *alertctrl = [UIAlertController alertControllerWithTitle:alertTitle message:alertInfo preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"马上升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:_appurl];
                [[UIApplication sharedApplication] openURL:url];
            }];
            [alertctrl addAction:cancelAction];
            [alertctrl addAction:sureAction];
            
        }else {
            
            versionalert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertInfo delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"马上升级", nil];
            [versionalert show];
            
        }
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == versionalert && buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:_appurl];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

@end
