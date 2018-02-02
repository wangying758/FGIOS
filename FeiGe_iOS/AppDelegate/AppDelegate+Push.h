//
//  AppDelegate+Push.h
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/1.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Push)

- (void)registerRemoteNotifications;

- (void)getAndSaveDeviceToken:(NSData *)deviceToken;

@end
