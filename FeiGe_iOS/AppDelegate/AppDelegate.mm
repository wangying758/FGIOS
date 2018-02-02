 //
//  AppDelegate.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/7/27.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Others.h"
#import "AppDelegate+Push.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#if TARGET_IPHONE_SIMULATOR  //模拟器

#elif TARGET_OS_IPHONE      //真机
#import "AppDelegate+VideoCall.h"
#endif
#import "NetworkStatusMonitor.h"
#import "CloudManager+Endpoint.h"
#import "LoginInfo.h"
#import "AppDelegate+Message.h"

#import "AppDelegate+Push.h"
#import "AppDelegate+Contacter.h"

@interface AppDelegate ()<BMKGeneralDelegate,NetworkStatusObserver>

@property (strong, nonatomic) BMKMapManager *mapManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // APP启动首先登录服务器
    [self connectSocketServer];
    
    [self makeWindowOrderFront];
    
    [self configRootViewController];
    
    [self configNetworkMonitorr];
    
    [self configFps];
    
    //[self configYYTextDebugMode];
    
    [self configMJDownload];
    
    [self preloadDataBaseData];
    
    [self registerBaiduMap];
    
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    /*
    [self startHexmeetSdk];
    
    [self loginExampleAccount];
    
    [self receiveNotification];
    
    [self registerMicphoneRight];
     */
    
#endif

    [self setupNetworkStatusMonitor];
    
    [self registerRemoteNotifications];
    
    [self registerMessageNothification];
    
    [self addContacterNotification];
    
    return YES;
}

- (void)setupNetworkStatusMonitor {
    NetworkStatusMonitor *networkMonitor = [NetworkStatusMonitor getInstance];
    [networkMonitor addNetworkStatusObserver:self];
}

-(void)updateNetworkStatus:(NetworkStatus)curStatus {
    NetworkStatus netStatus = [[NetworkStatusMonitor getInstance] getNetworkStatus];
    if(netStatus == 0)
    {
        [CloudManager sharedInstance].networkType = 0;
    }
    else
    {
#if TARGET_IPHONE_SIMULATOR  //模拟器
        
#elif TARGET_OS_IPHONE      //真机
        
        LoginInfo *loginInfo = [CloudManager sharedInstance].currentLoginInfo;
        if(loginInfo.isLogined) {
            [[CloudManager sharedInstance] setSipServerAddress:nil];
            [[CloudManager sharedInstance] setSipServerNetWork:nil];
            [CloudManager sharedInstance].networkType = (netStatus == 1 ? 2 : 1);
            [[CloudManager sharedInstance] quickRegister];
            [[CloudManager sharedInstance] updateCallSpeed];
        }
        else {
            if([[HexmeetManager instance] isSipRegisterOk]) {
                [[HexmeetManager instance] unregister];
            }
        }
        
#endif
    }
    

}

- (void)applicationWillResignActive:(UIApplication *)application {
    
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    //[HexmeetManager.instance appResignActive];
#endif
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
   
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // APP启动首先登录服务器
    [self fastConnectToServer];
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    
    //[HexmeetManager.instance appBecomeActive];
    //if ([HexmeetManager.instance isIncomingCallReceived]) {
        /* new call recieved, show incoming call */
    //    [self showIncomingCall];
    //}
#endif
    
}


- (void)applicationWillTerminate:(UIApplication *)application {

}

#pragma mark - apns

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self getAndSaveDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    LSLog(@"%@",error);
}

-(void)Pub_configRootViewController
{
    [self configRootViewController];
}


- (void)registerBaiduMap {
    _mapManager = [[BMKMapManager alloc]init];
    
    BOOL ret = [_mapManager start:@"OCaXnf69nIg92oXbRajvMviIpruiRW6X"  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError{
    NSLog(@"验证代码%d",iError);
}

@end
