//
//  AppDelegate+VideoCall.m
//  FeiGe_iOS
//
//  Created by Lisai on 2017/10/13.
//  Copyright © 2017年 yunhuachen. All rights reserved.
//

#import "AppDelegate+VideoCall.h"
#import <AVFoundation/AVAudioSession.h>
#import "CloudManager+Endpoint.h"
#import "CloudManager.h"
#import "NetworkStatusMonitor.h"
#import "VideoViewController.h"
#import "AudioOnlyViewController.h"
#import "ConferenceModel.h"
#import "SVCLayoutManager.h"
#import "LSMultVideoViewController.h"

@implementation AppDelegate (VideoCall)



- (void)startHexmeetSdk {
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    [HexmeetManager.instance startHexmeetSdk];
#endif
}

- (void)loginExampleAccount {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[CloudManager sharedInstance] loginWithAccount:kAccountios01 password:@"1234" server:@"10.3.7.48" error:nil];
    });
    [self initVideoView];
}

- (void)logOff {
    [[CloudManager sharedInstance] asyncLogoff];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        
#if TARGET_IPHONE_SIMULATOR  //模拟器
        
#elif TARGET_OS_IPHONE      //真机
        [HexmeetManager.instance hangupCall];
#endif
    });
}

- (void)initVideoView {
    //Create and add video main view.
    if ([CloudManager sharedInstance].videosLayoutVC == nil) {
        [CloudManager sharedInstance].videosLayoutVC = [[VideosLayoutViewController alloc] initWithNibName:@"VideosLayoutViewController" bundle:nil];
    }
    
    //Set views to SDK.
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    for (VideoViewController *videoVC in [CloudManager sharedInstance].videosLayoutVC.remotePeopleVideoViewList)
    {
        if (videoVC.videoView != nil) {
            [viewArray addObject:videoVC.videoView];
        }
    }
    [WCDBManager deleteAllObjectsFromTable:NSStringFromClass(ConferenceModel.class)];
}

- (void)receiveNotification {
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callUpdate:) name:kSdkCallUpdate object:nil];
#endif
}

- (void)callUpdate:(NSNotification *)notif {
    
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    HexmeetCallState state = (HexmeetCallState)[[notif.userInfo objectForKey:@"state"] integerValue];
    switch (state) {
        case HexmeetCallIncomingReceived:
        case HexmeetCallIncomingEarlyMedia: {
            [self showIncomingCall];
            
            break;
        }
        case HexmeetCallOutgoingInit: {
            break;
        }
        case HexmeetCallOutgoingRinging: {
            break;
        }
        case HexmeetCallConnected:
            [self callConnected:notif];
            break;
        case HexmeetCallStreamsRunning: {
            //send content
            if ([HexmeetManager.instance isReceivingContent]) {
//                [videosLayoutVC hideVideoBtns];
//                [self onIncomingContent:notif];
            } else {
//                [videosLayoutVC showLocalVideo];
//                [videosLayoutVC showRemoteVideo];
//                [self onIncomingContentClosed:notif];
            }
            break;
        }
        case HexmeetCallUpdatedByRemote: {
            break;
        }
        case HexmeetCallError: {
//            [self displayCallError];
            break;
        }
        case HexmeetCallEnd:
            [self callReleased:notif];
            break;
        case HexmeetCallEarlyUpdatedByRemote:
            break;
        case HexmeetCallEarlyUpdating:
            break;
        case HexmeetCallIdle:
            break;
        case HexmeetCallOutgoingEarlyMedia:
            break;
        case HexmeetCallOutgoingProgress:
            break;
        case HexmeetCallPaused:
            break;
        case HexmeetCallPausing:
            break;
        case HexmeetCallRefered:
            break;
        case HexmeetCallReleased:
            [self callReleased:notif];
            break;
        case HexmeetCallResuming:
            break;
        case HexmeetCallUpdating:
            break;
    }
#endif
}

- (void)showIncomingCall {
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    [[PublicMethod getCurrentVC] dismissViewControllerAnimated:NO completion:nil];
    FarendUserInfo* farendUser = [HexmeetManager.instance getFarendInfo];
    BOOL callMode = [HexmeetManager.instance isCurrentCallVideoEnabled];
    ConnectModel *connectModel = [[ConnectModel alloc] init];
    connectModel.name = farendUser.displayName;
    connectModel.callNumber = farendUser.callNumber;
    [self showConnectingView:YES withDisplayModel:connectModel withVideo:callMode];
#endif
}

-(void)showConnectingView:(BOOL)isIncoming withDisplayModel:(ConnectModel *)connectModel withVideo:(BOOL)isVideoMode
{
   
    if (![CloudManager sharedInstance].currentLoginInfo.isLogined) {
        return;
    }
    ConnectingViewController *connectingViewController = [[ConnectingViewController alloc] initWithNibName:@"ConnectingViewController" bundle:nil];
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    [[HexmeetManager instance] playSound:ringback];
#endif
  
    
    float height = KDeviceHeight > KDeviceWidth ? KDeviceHeight : KDeviceWidth;
    float width = KDeviceHeight > KDeviceWidth ? KDeviceWidth : KDeviceHeight;
    connectingViewController.view.frame = CGRectMake(0, 0, height, width);
    [[PublicMethod getCurrentVC] presentViewController:connectingViewController animated:NO completion:nil];
    [connectingViewController viewDidShow:isIncoming displayModel:connectModel withVideo:isVideoMode];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

#pragma mark - callrelease

- (void)callReleased:(NSNotification*)notification
{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (!UIDeviceOrientationIsLandscape(deviceOrientation)) {
//        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
//        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//    }
#if TARGET_IPHONE_SIMULATOR  //模拟器
    
#elif TARGET_OS_IPHONE      //真机
    [HexmeetManager.instance stopSound:all];
#endif
    //LOGI(@"[UI] call closed\n");
    [[PublicMethod getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
    
    //    [self closeVideoView];
}

- (void)callConnected:(NSNotification*)notification
{
    [self showTalkingView];
    dispatch_async(dispatch_get_main_queue(), ^(){
        
#if TARGET_IPHONE_SIMULATOR  //模拟器
        
#elif TARGET_OS_IPHONE      //真机
        BOOL callMode = [HexmeetManager.instance isCurrentCallVideoEnabled];
        if (callMode) {
            if ([CloudManager sharedInstance].multVideoType == LSMultVideoTypeNone) {
                [self openVideoView];
            } else {
                
            }
        }else{
            FarendUserInfo* farendUser = [HexmeetManager.instance getFarendInfo];
            ConnectModel *connectModel = [[ConnectModel alloc] init];
            connectModel.name = farendUser.displayName;
            connectModel.callNumber = farendUser.callNumber;
            [self showAudioOnlyCallView:connectModel];
        }
#endif
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //模拟发送refresh layout event
#if TARGET_IPHONE_SIMULATOR  //模拟器
        
#elif TARGET_OS_IPHONE      //真机
        [[HexmeetManager instance] stopSound:ringing];
#endif
        SVCRefreshLayoutNotification *refreshLayouNtf = [[SVCRefreshLayoutNotification alloc] init];
        refreshLayouNtf.activeSpeakerViewId = 0;
        refreshLayouNtf.chanNum = 1;
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:refreshLayouNtf,NTF_SVC_REFRESH_LAYOUT, nil ];
        [[NSNotificationCenter defaultCenter] postNotificationName:NTF_SVC_REFRESH_LAYOUT
                                                            object:nil
                                                          userInfo:userInfo];
        
        //模拟发送channel status change event
        SVCChannelStatusChangedNotification* channelStatusNtf = [[SVCChannelStatusChangedNotification alloc ] init];
        channelStatusNtf.viewId = 0;
        channelStatusNtf.ssrcId = 0;
        channelStatusNtf.displayName = [NSString stringWithUTF8String: ""];
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:channelStatusNtf, NTF_SVC_CHANNEL_STATUS_CHANGED, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NTF_SVC_CHANNEL_STATUS_CHANGED
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

-(void)showAudioOnlyCallView:(ConnectModel*)connectModel
{
    
    [[PublicMethod getCurrentVC] dismissViewControllerAnimated:NO completion:^{
        AudioOnlyViewController *audioOnlyVC = [[AudioOnlyViewController alloc] initWithNibName:@"AudioOnlyViewController" bundle:nil];
        [[PublicMethod getCurrentVC] presentViewController:audioOnlyVC animated:NO completion:nil];
        [audioOnlyVC viewDidShow:connectModel isConf:YES];
    }];
    
}

-(void)showTalkingView
{
    //LOGI(@"[UI] showTalkingView\n");
    
    
    [[SVCLayoutManager getInstance] openLayout];
    [[CloudManager sharedInstance].videosLayoutVC showButtonBar];
}

- (void)openVideoView {
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[PublicMethod getCurrentVC] dismissViewControllerAnimated:NO completion:^{
        LSMultVideoViewController *videoDisplayVC = [[LSMultVideoViewController alloc] initWithNibName:@"LSMultVideoViewController" bundle:nil];
        [[PublicMethod getCurrentVC] presentViewController:videoDisplayVC animated:NO completion:nil];
    }];
    
    
    
//    VideoViewController* remoteViewController = [[CloudManager sharedInstance].videosLayoutVC.remotePeopleVideoViewList objectAtIndex:0];
//    UIView* remoteView = remoteViewController.videoView;
//
//    [HexmeetManager.instance setRemoteVideoView:(__bridge void *)(remoteView)];
//    [HexmeetManager.instance setLocalVideoView:(__bridge void *)([CloudManager sharedInstance].videosLayoutVC.localPeopleVideoView.videoView)];
//    [HexmeetManager.instance setContentVideoView:(__bridge void *)([CloudManager sharedInstance].videosLayoutVC.contentVideoView.videoView)];
//
//    //Show preview.
//    [[CloudManager sharedInstance].videosLayoutVC initShowPreview];
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    [UIView beginAnimations:nil context:context];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationDuration:0.6f];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:videoWindow cache:YES];
    //    [UIView commitAnimations];
//    [self performSelector:@selector(statusBarHidden) withObject:nil afterDelay:1.0f];
}

- (void)registerMicphoneRight {
    //提前获取micphone权限
    if ([[AVAudioSession sharedInstance] recordPermission]!= AVAudioSessionRecordPermissionGranted
        && [[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                LSLog(@"micphone is permitted by user!");
            } else {
                LSLog(@"micphone permission is denied by user, call will not send any audio sample to remote!");
            }
        }];
    }
}

@end
