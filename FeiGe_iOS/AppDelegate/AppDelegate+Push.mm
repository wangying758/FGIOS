//
//  AppDelegate+Push.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/1.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "AppDelegate+Push.h"


@implementation AppDelegate (Push)

- (void)registerRemoteNotifications {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 10.0) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            
        } else if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
            [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge) categories:nil]];
            
            [[UIApplication sharedApplication]registerForRemoteNotifications];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
        }
    });
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)getAndSaveDeviceToken:(NSData *)deviceToken {
    
    NSString *apns = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    apns = [apns stringByReplacingOccurrencesOfString:@" " withString:@""];
    LSLog(@"%@",apns);
    if(apns.length){
        [[NSUserDefaults standardUserDefaults] setObject:apns forKey:DeviceToken];
    }
}

@end
