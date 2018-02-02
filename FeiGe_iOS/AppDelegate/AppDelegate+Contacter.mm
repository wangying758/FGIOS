//
//  AppDelegate+Contacter.m
//  FeiGe_iOS
//
//  Created by ittest on 2018/1/17.
//  Copyright © 2018年 yunhuachen. All rights reserved.
//

#import "AppDelegate+Contacter.h"
#import "ContactModel.h"
#import "NewFriendModel.h"
#import "RHSocketManager.h"
#import "Roster.pbobjc.h"
#import "WCDBManager.h"
#import "ContactDataHelper.h"
#import "ContactGroupModel.h"
#import "UIImage+GroupIcon.h"

@implementation AppDelegate (Contacter)

-(void)addContacterNotification
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receieveNotification:) name:kNotificationSocketRosterResponse object:nil];

    // 花名册离线消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketRosterOffline:) name:kNotificationSocketRosterOffline object:nil];
    
    //群组消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketMucResponse:) name:kNotificationSocketMucResponse object:nil];
    
}

//群组消息
-(void)kNotificationSocketMucResponse:(NSNotification *)notification
{
    NSMutableArray *dataArray = [NSMutableArray array];
    MucMessage *message = notification.object;
    
    for (NSInteger i = 0; i < message.itemArray.count; i++) {
        MucItem *item = message.itemArray[i];
        ContactGroupModel *model = [ContactGroupModel new];
        model.name = item.mucname;
        model.mucid = item.mucid;
        model.subject = item.subject;
        model.needConfirm = item.needConfirm;
        model.memberCount = item.memberCount;
        model.noDisturb = item.pConfig.noDisturb;
        model.chatBg = item.pConfig.chatBg;
        model.mucusernick = item.pConfig.mucusernick;
        model.role = item.pConfig.role;
        NSMutableArray *contactModels = [NSMutableArray array];
        NSMutableArray *headImages = [NSMutableArray array];
        for (MucMemberItem *memberItem in item.membersArray) {
            NSInteger index = [item.membersArray indexOfObject:memberItem];
            ContactModel *contactModel = [ContactModel new];
            contactModel.name = memberItem.usernick.length ? memberItem.usernick : memberItem.mucusernick;
            contactModel.userid = memberItem.username;
            contactModel.role = memberItem.role;
            contactModel.mucUsername = memberItem.mucusernick;
            contactModel.inviter = memberItem.inviter;
            contactModel.portraitUrl = memberItem.avatar;
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:contactModel.portraitUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                [headImages addObject:image ? image : ImageFromName(@"head")];
                if (index == item.membersArray.count - 1) {
                    UIImage *groupIcon = [UIImage groupIconWith:headImages bgColor:[UIColor colorWithHexString:@"eeeeee"]];
                    NSData *imageData = UIImagePNGRepresentation(groupIcon);
                    [[SDImageCache sharedImageCache] storeImage:groupIcon forKey:model.mucid toDisk:YES completion:nil];
                }
            }];
            [contactModels addObject:contactModel];
        }
        model.membersArray = [contactModels yy_modelToJSONString];
        [dataArray addObject:model];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSaveSuccess = [WCDBManager insertOrReplaceObjects:dataArray into:ContactGroupModelTable];
        NSLog(@"");
    });
}

//花名册离线消息
-(void)kNotificationSocketRosterOffline:(NSNotification *)notification
{
    NSArray *arr = notification.object;
    RosterMessage *message = [arr firstObject];
    switch (message.code) {
        case 400:
        {
            //收到离线邀请
            //收到好友添加邀请
            NSMutableArray *changeArr = [NSMutableArray array];
            for(RosterItem *rosterItem in message.itemArray){
                NewFriendModel *model = [NewFriendModel new];
                model.name = rosterItem.usernick;
                model.userid = rosterItem.username;
                model.portraitUrl = [NSString stringWithFormat:@"%@HnlensImage/Users/%@/Avatar/headimage.png",BaseUrl,rosterItem.username];
                model.addDate = [ContactDataHelper returnCurrentTimeString];
                [changeArr addObject:model];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL isSuccess =  [WCDBManager insertObjects:changeArr into:NewFriendModelTable];
                NSLog(@"");
            });
            
            [self updateNewFriendCellNumberWithNum:changeArr.count];
        }
            break;
            
        case 402:
        {
            //同意了好友邀请
            [self acceptFriendInvitingWithMessage:message];
        }
            break;
            
        default:
            break;
    }
}

-(void)receieveNotification:(NSNotification *)notify
{
    NSLog(@"%@",notify.object);
    RosterMessage *message = notify.object;
    
    switch (message.code) {
        case 400:
        {
            //收到好友添加邀请
            NSMutableArray *changeArr = [NSMutableArray array];
            for(RosterItem *rosterItem in message.itemArray){
                NewFriendModel *model = [NewFriendModel new];
                model.name = rosterItem.usernick;
                model.userid = rosterItem.username;
                model.portraitUrl = [NSString stringWithFormat:@"%@HnlensImage/Users/%@/Avatar/headimage.png",BaseUrl,rosterItem.username];
                model.addDate = [ContactDataHelper returnCurrentTimeString];
                [changeArr addObject:model];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL isSuccess =  [WCDBManager insertObjects:changeArr into:NewFriendModelTable];
                NSLog(@"");
            });
            
            [self updateNewFriendCellNumberWithNum:changeArr.count];
        }
            break;
            
        case 402:
        {
            //同意了好友邀请
            [self acceptFriendInvitingWithMessage:message];
        }
            break;
            
        case 410:
        {
            //查询成功
            [self querySuccessOperationWithMessage:message];
        }
            break;
            
        default:
            break;
    }
}

-(void)querySuccessOperationWithMessage:(RosterMessage *)message
{
    NSMutableArray *contactArray = [NSMutableArray array];
    for(RosterItem *rosteritem in message.itemArray){
        
        NSString *userID = rosteritem.username;
        NSString *name = rosteritem.usernick;
        
        //有实名认证 显示真实姓名
        if(![PublicMethod isBlankString:rosteritem.empName])
            name = rosteritem.empName;
        
        //没有昵称显示工号
        if(!name)
            name = userID;
        
        ContactModel *model = [ContactModel new];
        model.name = name;
        model.userid = userID;
        model.chatBg = rosteritem.chatBg;
        model.noDisturb = rosteritem.isBlock;
        model.portraitUrl = rosteritem.avatar;//头像

        if(DEBUG) {
            model.sex = @"1";
            model.isVetified = YES;//是否实名认证
            model.department = @"IT";//部门
            model.workArea = @"XS";//园区
            model.remarkContent = nil;
            model.workPosition = @"IOS开发";
            model.isStar = YES;
            model.isQuit = NO;
            model.state = @"1";
        }else
        {
            model.sex = rosteritem.sex;
            model.isVetified = rosteritem.isvalid;//是否实名认证
            model.department = rosteritem.dptName;//部门
            model.workArea = rosteritem.workAddress;//园区
        }
        [contactArray addObject:model];
    }
    
    if (contactArray.count > 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSaveSuccess = [WCDBManager insertOrReplaceObjects:contactArray into:ContactModelTable];
        LSLog(@"%@",@(isSaveSuccess));
            
        });
    }
    
}

-(void)updateNewFriendCellNumberWithNum:(NSInteger)num
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *numString = [NSString stringWithFormat:@"%ld",num];
    BOOL didClickNewFriendCell = [[NSUserDefaults standardUserDefaults] boolForKey:@"didClickNewFriendCell"];
    if (didClickNewFriendCell) {
        //已点击
        [userDefault setBool:NO forKey:@"didClickNewFriendCell"];
        [userDefault setObject:numString forKey:@"newFriendNum"];
        [userDefault synchronize];
        
    }else
    {
        //未点击
        NSString *originalNum = [userDefault objectForKey:@"newFriendNum"];
        NSInteger newNum = [originalNum integerValue] + num;
        [userDefault setObject:[NSString stringWithFormat:@"%ld",newNum] forKey:@"newFriendNum"];
        [userDefault synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"allContactVCReload" object:nil];
}


-(void)acceptFriendInvitingWithMessage:(RosterMessage *)message
{
    NSMutableArray *contactArray = [NSMutableArray array];
    for(RosterItem *rosteritem in message.itemArray){
        
        NSString *userID = rosteritem.username;
        NSString *name = rosteritem.usernick;
        
        //有实名认证 显示真实姓名
        if(![PublicMethod isBlankString:rosteritem.empName])
            name = rosteritem.empName;
        
        //没有昵称显示工号
        if(!name)
            name = userID;
        
        ContactModel *model = [ContactModel new];
        model.name = name;
        model.userid = userID;
        model.isVetified = rosteritem.isvalid;//是否实名认证
        model.department = rosteritem.dptName;//部门
        model.portraitUrl = rosteritem.avatar;//头像
        model.workArea = rosteritem.workAddress;//园区
        model.chatBg = rosteritem.chatBg;
        model.noDisturb = rosteritem.isBlock;
        
        [contactArray addObject:model];
    }
    
    if (contactArray.count > 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL isSaveSuccess = [WCDBManager insertOrReplaceObjects:contactArray into:ContactModelTable];
            LSLog(@"%@",@(isSaveSuccess));
        });
        
        ContactModel *model = [contactArray firstObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptInvited" object:nil userInfo:@{@"model":model}];
    }
    
}

@end
