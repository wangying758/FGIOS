//
//  AppDelegate+VideoCall.h
//  FeiGe_iOS
//
//  Created by Lisai on 2017/10/13.
//  Copyright © 2017年 yunhuachen. All rights reserved.
//

#import "AppDelegate.h"
#if TARGET_IPHONE_SIMULATOR  //模拟器

#elif TARGET_OS_IPHONE      //真机
#import "HexmeetManager.h"
#endif
#import "UserInfor.h"
#import "MessageContentViewController+VideoVoiceCall.h"

@interface AppDelegate (VideoCall)

- (void)startHexmeetSdk;

- (void)loginExampleAccount;

- (void)receiveNotification;

- (void)showIncomingCall;

- (void)registerMicphoneRight;

@end
