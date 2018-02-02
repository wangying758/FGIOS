//
//  AppDelegate+Others.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/7/27.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "AppDelegate+Others.h"
#import "BaseTabBarController.h"
#import "LoginViewController.h"
#import "WCDBManager.h"
#import "MJDownload.h"
#import "RHSocketManager.h"
#import "ContactDataHelper.h"
#import "LSUserInfoManager.h"
#import "LSChatSelectImageModel.h"
//#import "PPNetworkHelper.h"
#if defined(DEBUG)||defined(_DEBUG)
#import "JPFPSStatus.h"//查看fps
#endif

@implementation AppDelegate (Others)




// 设置主窗口
- (void)makeWindowOrderFront
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = WhiteColor;
    [self.window makeKeyAndVisible];
}

//开启YYText的debug模式，可以清楚的看到文本的绘制情况
- (void)configYYTextDebugMode
{
    YYTextDebugOption *debugOptions = [YYTextDebugOption new];
    debugOptions.baselineColor = [UIColor redColor];
    debugOptions.CTFrameBorderColor = [UIColor redColor];
    debugOptions.CTLineFillColor = [UIColor colorWithRed:0.000 green:0.463 blue:1.000 alpha:0.180];
    debugOptions.CGGlyphBorderColor = [UIColor colorWithRed:1.000 green:0.524 blue:0.000 alpha:0.200];
    [YYTextDebugOption setSharedDebugOption:debugOptions];
    
}

//设置MJDownload最大同时下载数
- (void)configMJDownload
{
    /**最大同时下载数*/
    [MJDownloadManager defaultManager].maxDownloadingCount = 1;
}

//配置根控制器
- (void)configRootViewController
{
    //用户第一次登陆
    if ([UserInfor sharedInstance].password.length == 0) {
        BaseNavigationController * navVC = [[BaseNavigationController alloc]initWithRootViewController:[LoginViewController customInit]
        ];
        self.window.rootViewController = navVC;
    }else{//用户已经登陆过
        self.window.rootViewController = [[BaseTabBarController alloc] init];
        [self openDB];
        [self createTabels];
        [UserInfor sharedInstance].userName = [LSUserInfoManager sharedInstance].userInfoModel.usernick;
        
    }
    [self setupBgImageData];
}

- (void)setupBgImageData {
    NSMutableArray *imageArr = [NSMutableArray array];
    [imageArr addObjectsFromArray:[WCDBManager getAllObjectsOfClass:LSChatSelectImageModel.class fromTable:LSChatSelectImageModelTable]];
    if (!imageArr.count) {
        for (int i = 0; i < 11; i++) {
            LSChatSelectImageModel *selectModel = [[LSChatSelectImageModel alloc] init];
            selectModel.imageName = [NSString stringWithFormat:@"background_%@",@(i)];
            selectModel.imageId = [NSString stringWithFormat:@"%@",@(i + 10000)];
            selectModel.isSelect = NO;
            [imageArr addObject:selectModel];
        }
        [WCDBManager insertObjects:imageArr into:LSChatSelectImageModelTable];
    }
}


//配置FPS监听器
- (void)configFps
{
#if defined(DEBUG)||defined(_DEBUG)
    [[JPFPSStatus sharedInstance] open];
#endif
}

//开始监听网络
- (void)configNetworkMonitorr
{
    //[PPNetworkCache removeAllHttpCache];
//    NSLog(@"网络缓存大小cache = %.2fKB",[PPNetworkCache getAllHttpCacheSize]/1024.f);
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                LSLog(@"*********未知网络*********");
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:
            {
                LSLog(@"*********无网络*********");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                LSLog(@"*********手机网络*********");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                LSLog(@"*********WIFI*********");
                break;
            }
            default:
                break;
        }
    }];
}

/**
 * 创建或者打开数据库
 */
- (void)openDB
{
    [WCDBManager shareDatabaseWithUserid:[UserInfor sharedInstance].userId];
}

/**
 * 创建数据库表
 */
- (void)createTabels
{
    [WCDBManager createTableAndIndexesOfName:MessageListTabel withClass:NSClassFromString(@"MessageListModel")];
    [WCDBManager createTableAndIndexesOfName:MessageContentTable withClass:NSClassFromString(@"MessageModel")];
    [WCDBManager createTableAndIndexesOfName:WorkCenterTable withClass:NSClassFromString(@"CenterModel")];
    [WCDBManager createTableAndIndexesOfName:MoreWorkCenterTable withClass:NSClassFromString(@"CenterModel")];
    [WCDBManager createTableAndIndexesOfName:ContactTable withClass:NSClassFromString(@"Contact")];
    [WCDBManager createTableAndIndexesOfName:InformationsTable withClass:NSClassFromString(@"Informations")];
    [WCDBManager createTableAndIndexesOfName:ConferenceModelTable withClass:NSClassFromString(@"ConferenceModel")];
    [WCDBManager createTableAndIndexesOfName:ConfCalendarTable withClass:NSClassFromString(@"ConfCalendar")];
    [WCDBManager createTableAndIndexesOfName:ConfUserTable withClass:NSClassFromString(@"ConfUser")];
    [WCDBManager createTableAndIndexesOfName:AttendeeTable withClass:NSClassFromString(@"Attendee")];
    [WCDBManager createTableAndIndexesOfName:ContactModelTable withClass:NSClassFromString(@"ContactModel")];
    [WCDBManager createTableAndIndexesOfName:LSFuncModelTable withClass:NSClassFromString(@"LSFuncModel")];
    [WCDBManager createTableAndIndexesOfName:LSUserInfoModelTable withClass:NSClassFromString(@"LSUserInfoModel")];
    [WCDBManager createTableAndIndexesOfName:LSChatSelectImageModelTable withClass:NSClassFromString(@"LSChatSelectImageModel")];
    [WCDBManager createTableAndIndexesOfName:ContactGroupModelTable withClass:NSClassFromString(@"ContactGroupModel")];
    [WCDBManager createTableAndIndexesOfName:GroupMessageTable withClass:NSClassFromString(@"MessageModel")];
    [WCDBManager createTableAndIndexesOfName:NewFriendModelTable withClass:NSClassFromString(@"NewFriendModel")];
    [WCDBManager createTableAndIndexesOfName:LSGIFAndPictureEditModelTable withClass:NSClassFromString(@"LSGIFAndPictureEditModel")];
}

/**
 * 预加载所需数据库数据
 */
- (void)preloadDataBaseData
{
    [ContactDataHelper getFriendListFromDataBaseWithBlock:^(NSArray *array) {
        [UserInfor sharedInstance].allContactArray = array;
    }];
}

@end
