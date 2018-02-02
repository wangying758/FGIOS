//
//  AppDelegate+Message.m
//  FeiGe_iOS
//
//  Created by Lisai on 2017/11/3.
//  Copyright © 2017年 yunhuachen. All rights reserved.
//

#import "AppDelegate+Message.h"
#import "RHSocketManager.h"
#import "MessageModel.h"
#import <fingerChat/ShareObject.h>
#import "PrivateChat.pbobjc.h"
#import "MessageContentModel.h"
#import "MessageListViewController.h"
#import "MessageListModel.h"
#import "WCDBManager.h"
#import "NSDate+Date.h"
#import "Register.pbobjc.h"
#import "AppDelegate+Others.h"
#import "LSFuncModel.h"
#import "LSUserInfoModel.h"
#import "PhotoModel.h"
#import "ContactModel.h"
#import "MessageContentViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LSUserInfoManager.h"

// 需要快速重连的情况: 1. 心跳包报错

@implementation AppDelegate (Message)

// socket服务器操作
- (void)connectSocketServer {
    RHSocketManager *socketManager = [RHSocketManager sharedInstance];
    [socketManager connectServer_WithConnectParam];
}

- (void)registerMessageNothification {
    //连接服务器通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketManagerServer:) name:kNotificationSocketManagerServer object:nil];
    
    //收到单聊离线消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketPrivateChatOffline:) name:kNotificationSocketPrivateChatOffline object:nil];
    
    //登陆返回用户信息的消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketLoginUserinfo:) name:kNotificationSocketLoginUserinfo object:nil];
    
    // 群聊离线消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketGroupChatOffline:) name:kNotificationSocketGroupChatOffline object:nil];
    
    // 花名册离线消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketRosterOffline:) name:kNotificationSocketRosterOffline object:nil];
    
    // 登录冲突消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketLoginConflict:) name:kNotificationSocketLoginConflict object:nil];
    
    // action notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNotificationSocketMucNotice:) name:kNotificationSocketMucNotice object:nil];
}

- (void)kNotificationSocketMucNotice:(NSNotification *)notifi {
    MucAction *action = notifi.object;
    ContactGroupModel *groupModel = [WCDBManager getOneObjectOfClass:ContactGroupModel.class fromTable:ContactGroupModelTable where:ContactGroupModel.mucid == action.mucid];
    if (action.action == MOption_Destory) {
        groupModel.groupStatus = LSGroupStatusTypeDestory;
        MessageListModel *listModel = [WCDBManager getOneObjectOfClass:MessageListModel.class fromTable:MessageListTabel where:MessageListModel.mucid == action.mucid];
        if (listModel) {
            [WCDBManager updateRowsInTable:ContactGroupModelTable onProperty:ContactGroupModel.groupStatus withObject:groupModel where:ContactGroupModel.mucid == action.mucid];
        } else {
            [WCDBManager deleteObjectsFromTable:ContactGroupModelTable where:ContactGroupModel.mucid == action.mucid];
        }
    } else if (action.action == MOption_Leave) {
        
    } else if (action.action == MOption_Kick) {
        for (MucMemberItem *item in action.usernamesArray) {
            [self insertKickMessageWithKickItem:item fromMemberItem:action.from groupModel:groupModel];
        }
    } else if (action.action == MOption_Join) {
        
    } else if (action.action == MOption_Invite) {
        LSLog(@"MOption_Invite");
        [self insertInviteMessage:action groupModel:groupModel];
    } else if (action.action == MOption_UpdateConfig) {
        if (action.updateOption == UpdateOption_Uname) {
            groupModel.name = action.item.mucname;
            [WCDBManager updateRowsInTable:ContactGroupModelTable onProperty:ContactGroupModel.name withObject:groupModel where:ContactGroupModel.mucid == action.mucid];
            MessageListModel *listModel = [WCDBManager getOneObjectOfClass:MessageListModel.class fromTable:MessageListTabel where:MessageListModel.mucidAndUserId == action.mucid];
            if (!listModel) {
                listModel = [MessageListModel new];
                listModel.mucid = groupModel.mucid;
                listModel.mucidAndUserId = listModel.mucid;
                listModel.userName = groupModel.name;
                listModel.type = MessagePropertyTypeGroup;
                listModel.lastContent = [self changeGroupName:action groupModel:groupModel];
                listModel.time = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            } else {
                listModel.userName = groupModel.name;
                listModel.lastContent = [self changeGroupName:action groupModel:groupModel];
            }
            [self refreshMessageListVCWithModel:listModel];
            [self insertModifyGroupNameMessage:action groupModel:groupModel];
        } else if (action.updateOption == UpdateOption_Usubject) {
            groupModel.subject = [NSString stringWithFormat:@"[群公告] %@",action.item.subject];
            [WCDBManager updateRowsInTable:ContactGroupModelTable onProperty:ContactGroupModel.subject withObject:groupModel where:ContactGroupModel.mucid == action.mucid];
            MessageListModel *listModel = [WCDBManager getOneObjectOfClass:MessageListModel.class fromTable:MessageListTabel where:MessageListModel.mucidAndUserId == action.mucid];
            if (listModel) {
                listModel.userName = groupModel.name;
                listModel.lastContent = groupModel.subject;
            } else {
                listModel = [MessageListModel new];
                listModel.mucid = groupModel.mucid;
                listModel.mucidAndUserId = listModel.mucid;
                listModel.userName = groupModel.name;
                listModel.type = MessagePropertyTypeGroup;
                listModel.lastContent = groupModel.subject;
                listModel.time = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            }
            [self refreshMessageListVCWithModel:listModel];
            [self insertReceiveSubjectMessage:action groupModel:groupModel];
        } else if (action.updateOption == UpdateOption_UautoEnter) {
            groupModel.needConfirm = action.item.needConfirm;
            [WCDBManager updateRowsInTable:ContactGroupModelTable onProperty:ContactGroupModel.needConfirm withObject:groupModel where:ContactGroupModel.mucid == action.mucid];
        }
    }
}


- (void)insertInviteMessage:(MucAction *)action groupModel:(ContactGroupModel *)groupModel {
    NSString *inviteNames = @"";
    for (MucMemberItem *memberItem in action.usernamesArray) {
        NSInteger index = [action.usernamesArray indexOfObject:memberItem];
        if (index) {
            if ([memberItem.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
                inviteNames = [NSString stringWithFormat:@"%@、%@",inviteNames,@"你"];
            } else {
                inviteNames = [NSString stringWithFormat:@"%@、%@",inviteNames,memberItem.mucusernick];
            }
        } else {
            if ([memberItem.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
                inviteNames = @"你";
            } else {
                inviteNames = [NSString stringWithFormat:@"%@",memberItem.mucusernick];
            }
        }
    }
    NSString *inviteMessage = [NSString stringWithFormat:@"你邀请\"%@\"加入了群聊",inviteNames];
    if ([action.from.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
        inviteMessage = [NSString stringWithFormat:@"你邀请\"%@\"加入了群聊",inviteNames];
    } else {
        inviteMessage = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入了群聊",action.from.mucusernick,inviteNames];
    }
    MessageListModel *listModel = [WCDBManager getOneObjectOfClass:MessageListModel.class fromTable:MessageListTabel where:MessageListModel.mucidAndUserId == action.mucid];
    if (listModel) {
        listModel.userName = groupModel.name;
        listModel.lastContent = inviteMessage;
    } else {
        listModel = [MessageListModel new];
        listModel.mucid = groupModel.mucid;
        listModel.mucidAndUserId = listModel.mucid;
        listModel.userName = groupModel.name;
        listModel.type = MessagePropertyTypeGroup;
        listModel.lastContent = inviteMessage;
        listModel.time = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    [self refreshMessageListVCWithModel:listModel];
    CGSize textSize = [PublicMethod getLabelHeightWithText:inviteMessage width:BubbleMaxWidth font:14];
    MessageModel * model = [MessageModel new];
    model.id_p = [PublicMethod generateUUID];
    model.insertTime = [PublicMethod timeIntervalSince1970];
    model.receiverUserid = groupModel.mucid;
    model.receiverUserName = groupModel.name;
    model.senderUserid = [UserInfor sharedInstance].userId;
    MessageContentModel *contentModel = [MessageContentModel new];
    contentModel.warnMessageType = LSWarnMessageTypeGroupInvite;
    contentModel.body = inviteMessage;
    contentModel.fromItemStr = [action.from yy_modelToJSONString];
    contentModel.inviteArrStr = [action.usernamesArray yy_modelToJSONString];
    NSString *jsonStr = [contentModel yy_modelToJSONString];
    model.body = jsonStr;
    model.isSender = YES;
    model.isRead = YES;
    model.messageType = MessageType_Notice;
    model.senderUserName = action.from.usernick;
    model.senderUserid = action.from.username;
    model.bubbleWidth = textSize.width + TextLeftMarign + TextRightMarign;
    model.bubbleHeight = textSize.height < 25 ? 25 + 20 : textSize.height + 20;
    model.fontSize = [UserInfor sharedInstance].fontSize;
    MessageModel *lastMessageModel = [WCDBManager getLastObjectsOfClass:MessageModel.class fromTable:GroupMessageTable where:MessageModel.receiverUserid == model.receiverUserid];
    if (lastMessageModel) {
        model.isShowTime = [model minuteOffSetStart:lastMessageModel.insertTime];
    } else if (!lastMessageModel) {
        model.isShowTime = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WCDBManager insertObject:model into:GroupMessageTable];
        dispatch_async(dispatch_get_main_queue(), ^{
            MessageContentViewController *contentVC = (MessageContentViewController *)[PublicMethod getVCByItsClassName:@"MessageContentViewController"];
            [contentVC loadDataFromDataBase];
        });
    });
}

- (NSString *)changeGroupName:(MucAction *)action groupModel:(ContactGroupModel *)groupModel {
    NSString *groupName = @"";
    if ([action.from.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
        groupName = [NSString stringWithFormat:@"你修改群名为\"%@\"",action.item.mucname];
    } else {
        groupName = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"",action.from.mucusernick,action.item.mucname];
    }
    return groupName;
}

- (void)insertKickMessageWithKickItem:(MucMemberItem *)kickItem fromMemberItem:(MucMemberItem *)memberItem groupModel:(ContactGroupModel *)groupModel {
    NSString *nameStr = @"";
    if ([memberItem.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
        nameStr = [NSString stringWithFormat:@"你将\"%@\"移除了群聊",kickItem.mucusernick];
    } else {
        if ([kickItem.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
            nameStr = [NSString stringWithFormat:@"\"%@\"将%@移除了群聊",memberItem.mucusernick,@"你"];
        } else {
            nameStr = [NSString stringWithFormat:@"\"%@\"将\"%@\"移除了群聊",memberItem.mucusernick,kickItem.mucusernick];
        }
    }
    MessageListModel *listModel = [WCDBManager getOneObjectOfClass:MessageListModel.class fromTable:MessageListTabel where:MessageListModel.mucidAndUserId == groupModel.mucid];
    if (!listModel) {
        listModel = [MessageListModel new];
        listModel.mucid = groupModel.mucid;
        listModel.mucidAndUserId = listModel.mucid;
        listModel.userName = groupModel.name;
        listModel.type = MessagePropertyTypeGroup;
        listModel.lastContent = nameStr;
        listModel.time = [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    } else {
        listModel.userName = groupModel.name;
        listModel.lastContent = nameStr;
    }
    [self refreshMessageListVCWithModel:listModel];
    
    CGSize textSize = [PublicMethod getLabelHeightWithText:nameStr width:BubbleMaxWidth font:14];
    MessageModel * model = [MessageModel new];
    model.id_p = [PublicMethod generateUUID];
    model.insertTime = [PublicMethod timeIntervalSince1970];
    model.receiverUserid = groupModel.mucid;
    model.receiverUserName = groupModel.name;
    model.senderUserid = [UserInfor sharedInstance].userId;
    MessageContentModel *contentModel = [MessageContentModel new];
    contentModel.warnMessageType = LSWarnMessageTypeGroupKick;
    contentModel.body = nameStr;
    contentModel.fromItemStr = [memberItem yy_modelToJSONString];
    contentModel.kickItemStr = [kickItem yy_modelToJSONString];
    NSString *jsonStr = [contentModel yy_modelToJSONString];
    model.body = jsonStr;
    model.isSender = YES;
    model.isRead = YES;
    model.messageType = MessageType_Notice;
    model.senderUserName = memberItem.mucusernick;
    model.senderUserid = memberItem.username;
    model.bubbleWidth = textSize.width + TextLeftMarign + TextRightMarign;
    model.bubbleHeight = textSize.height < 25 ? 25 + 20 : textSize.height + 20;
    model.fontSize = [UserInfor sharedInstance].fontSize;
    MessageModel *lastMessageModel = [WCDBManager getLastObjectsOfClass:MessageModel.class fromTable:GroupMessageTable where:MessageModel.receiverUserid == model.receiverUserid];
    if (lastMessageModel) {
        model.isShowTime = [model minuteOffSetStart:lastMessageModel.insertTime];
    } else if (!lastMessageModel) {
        model.isShowTime = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WCDBManager insertObject:model into:GroupMessageTable];
        dispatch_async(dispatch_get_main_queue(), ^{
            MessageContentViewController *contentVC = (MessageContentViewController *)[PublicMethod getVCByItsClassName:@"MessageContentViewController"];
            [contentVC loadDataFromDataBase];
        });
    });
}

- (void)insertReceiveSubjectMessage:(MucAction *)action groupModel:(ContactGroupModel *)groupModel {
    NSString *message = [NSString stringWithFormat:@"[群公告]%@",action.item.subject];
    CGSize textSize = [PublicMethod getLabelHeightWithText:message width:BubbleMaxWidth font:14];
    MessageModel * model = [MessageModel new];
    model.id_p = [PublicMethod generateUUID];
    model.insertTime = [PublicMethod timeIntervalSince1970];
    model.receiverUserid = groupModel.mucid;
    model.receiverUserName = groupModel.name;
    model.senderUserid = [UserInfor sharedInstance].userId;
    MessageContentModel *contentModel = [MessageContentModel new];
    contentModel.warnMessageType = LSWarnMessageTypeGroupSubject;
    contentModel.body = message;
    contentModel.fromItemStr = [action.from yy_modelToJSONString];
    NSString *jsonStr = [contentModel yy_modelToJSONString];
    model.body = jsonStr;
    model.isSender = YES;
    model.isRead = YES;
    model.messageType = MessageType_Notice;
    model.senderUserName = action.from.usernick;
    model.senderUserid = action.from.username;
    model.bubbleWidth = textSize.width + TextRightMarign;
    model.bubbleHeight = textSize.height < 25 ? 25 + 20 : textSize.height + 20;
    model.fontSize = [UserInfor sharedInstance].fontSize;
    MessageModel *lastMessageModel = [WCDBManager getLastObjectsOfClass:MessageModel.class fromTable:GroupMessageTable where:MessageModel.receiverUserid == model.receiverUserid];
    if (lastMessageModel) {
        model.isShowTime = [model minuteOffSetStart:lastMessageModel.insertTime];
    } else if (!lastMessageModel) {
        model.isShowTime = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WCDBManager insertObject:model into:GroupMessageTable];
        dispatch_async(dispatch_get_main_queue(), ^{
            MessageContentViewController *contentVC = (MessageContentViewController *)[PublicMethod getVCByItsClassName:@"MessageContentViewController"];
            [contentVC loadDataFromDataBase];
        });
    });
}

- (void)insertModifyGroupNameMessage:(MucAction *)action groupModel:(ContactGroupModel *)groupModel {
    NSString *message = @"";
    if ([action.from.username isEqualToString:[LSUserInfoManager sharedInstance].userInfoModel.userid]) {
        message = [NSString stringWithFormat:@"你修改群名为\"%@\"",action.item.mucname];
    } else {
        message = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"",action.from.mucusernick,action.item.mucname];
    }
    CGSize textSize = [PublicMethod getLabelHeightWithText:message width:BubbleMaxWidth font:14];
    MessageModel * model = [MessageModel new];
    model.id_p = [PublicMethod generateUUID];
    model.insertTime = [PublicMethod timeIntervalSince1970];
    model.receiverUserid = groupModel.mucid;
    model.receiverUserName = groupModel.name;
    model.senderUserid = [UserInfor sharedInstance].userId;
    MessageContentModel *contentModel = [MessageContentModel new];
    contentModel.warnMessageType = LSWarnMessageTypeGroupName;
    contentModel.body = message;
    contentModel.fromItemStr = [action.from yy_modelToJSONString]; 
    NSString *jsonStr = [contentModel yy_modelToJSONString];
    model.body = jsonStr;
    model.isSender = YES;
    model.isRead = YES;
    model.messageType = MessageType_Notice;
    model.senderUserName = action.from.mucusernick;
    model.senderUserid = action.from.username;
    model.bubbleWidth = textSize.width + TextLeftMarign + TextRightMarign;
    model.bubbleHeight = textSize.height < 25 ? 25 + 20 : textSize.height + 20;
    model.fontSize = [UserInfor sharedInstance].fontSize;
    MessageModel *lastMessageModel = [WCDBManager getLastObjectsOfClass:MessageModel.class fromTable:GroupMessageTable where:MessageModel.receiverUserid == model.receiverUserid];
    if (lastMessageModel) {
        model.isShowTime = [model minuteOffSetStart:lastMessageModel.insertTime];
    } else if (!lastMessageModel) {
        model.isShowTime = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WCDBManager insertObject:model into:GroupMessageTable];
        dispatch_async(dispatch_get_main_queue(), ^{
            MessageContentViewController *contentVC = (MessageContentViewController *)[PublicMethod getVCByItsClassName:@"MessageContentViewController"];
            [contentVC loadDataFromDataBase];
        });
    });
}

/**
 群聊离线消息

 @param notifi 群聊离线消息
 */
- (void)kNotificationSocketGroupChatOffline:(NSNotification *)notifi {
    LSLog(@"%@---%@",@"群聊离线消息",notifi.object);
    
    NSArray <RoomMessage *> *messages = notifi.object;
    for (RoomMessage *message in messages) {
        MessageModel * model = [MessageModel new];
        model.id_p = message.id_p;
        model.type = MessagePropertyTypeGroup;
        model.insertTime = [NSString stringWithFormat:@"%lld",message.time];
        model.receiverUserid = message.mucid;
        model.senderUserid = message.username;
        MessageContentModel *contentModel = [MessageContentModel yy_modelWithJSON:message.content];
        model.secret = contentModel.secret;
        model.body = contentModel.body;
        model.isSender = NO;
        model.messageType = message.type;
        model.senderUserName = contentModel.senderUserName;
        ContactModel *receiver = [WCDBManager getOneObjectOfClass:ContactModel.class fromTable:ContactModelTable where:ContactModel.userid == model.receiverUserid];
        model.receiverUserName = contentModel.revceiverUserName;
        CGSize textSize = [PublicMethod calCulateBubbleTextSize:contentModel.body];
        if (model.secret) {
            model.bubbleHeight = 52;
            model.bubbleWidth = 110;
        } else {
            model.bubbleHeight = contentModel.bubbleHeight;
            model.bubbleWidth = contentModel.bubbleWidth;
        }
        model.locationAddress = contentModel.locationAddress;
        model.locationName = contentModel.locationName;
        model.latitude = contentModel.latitude;
        model.timeLength = contentModel.timeLength;
        model.longitude = contentModel.longitude;
        model.friendId = contentModel.friendId;
        model.friendName = contentModel.friendName;
        model.friendHeader = contentModel.friendHeader;
        model.isValid = contentModel.isValid;
        model.isEnable = contentModel.isEnable;
        model.fontSize = [UserInfor sharedInstance].fontSize;
        model.transitionTitle = contentModel.transitionTitle;
        MessageModel *lastMessageModel = [WCDBManager getLastObjectsOfClass:MessageModel.class fromTable:GroupMessageTable where:MessageModel.receiverUserid == model.receiverUserid];
        if (lastMessageModel) {
            model.isShowTime = [model minuteOffSetStart:lastMessageModel.insertTime];
        }else if (!lastMessageModel) {
            model.isShowTime = YES;
        }
        if (model.messageType == MessageType_Notice) {
            model.isShowTime = NO;
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [WCDBManager insertObject:model into:GroupMessageTable];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshContentVC];
            });
        });
        MessageListModel *listModel = [MessageListModel new];
        listModel.mucid = model.receiverUserid;
        listModel.senderNickName = model.senderUserName;
        listModel.mucidAndUserId = listModel.mucid;
        listModel.userName = model.receiverUserName;
        listModel.type = MessagePropertyTypeGroup;
        listModel.time = [[NSDate dateWithTimeIntervalSince1970:message.time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (contentModel.secret) {
            listModel.lastContent = @"[加密消息]";
        } else {
            if (model.messageType == MessageType_Image) {
                listModel.lastContent = @"[图片消息]";
            } else if (model.messageType == MessageType_Video) {
                listModel.lastContent = @"[视频消息]";
            } else if (model.messageType == MessageType_Vote) {
                listModel.lastContent = @"[投票消息]";
            } else if (model.messageType == MessageType_Voice) {
                listModel.lastContent = @"[语音消息]";
            } else if (model.messageType == MessageType_Map) {
                listModel.lastContent = @"[定位消息]";
            } else if (model.messageType == MessageType_Face) {
                listModel.lastContent = @"[动画表情]";
            } else if (model.messageType == MessageType_Contact) {
                listModel.lastContent = @"[名片消息]";
            } else if (model.messageType == MessageType_Multiple) {
                listModel.lastContent = @"[聊天记录]";
            } else if (model.messageType == MessageType_Card) {
                listModel.lastContent = @"[打卡消息]";
            } else {
                listModel.lastContent = model.body;
            }
        }
        [self refreshMessageListVCWithModel:listModel];
    }
}


- (void)refreshContentVC {
    MessageContentViewController *contentVC = (MessageContentViewController *)[PublicMethod getVCByItsClassName:@"MessageContentViewController"];
    if (contentVC) {
        [contentVC loadDataFromDataBase];
    }
}

/**
 花名册离线消息

 @param notifi 花名册离线消息
 */
- (void)kNotificationSocketRosterOffline:(NSNotification *)notifi {
    
    LSLog(@"%@---%@",@"花名册离线消息",notifi.object);
}

/**
 登录冲突消息
 @param notifi notifi description
 */
- (void)kNotificationSocketLoginConflict:(NSNotification *)notifi {
    LSLog(@"%@---%@",@"登录冲突消息",notifi.object);
}

/**
 返回登录用户信息
 
 @param notif 通知消息
 */
- (void)kNotificationSocketLoginUserinfo:(NSNotification *)notif {
    UserInfo *userInfo = [notif object];

    if(![PublicMethod isBlankString:userInfo.empName])
        [UserInfor sharedInstance].userName = userInfo.empName;//真实姓名
    else if(![PublicMethod isBlankString:userInfo.usernick])
        [UserInfor sharedInstance].userName = userInfo.usernick;//昵称
    else
        [UserInfor sharedInstance].userName = userInfo.username;//账号
    
    [self openDB];
    [self createTabels];
    [self transformUserInfoToLSUserInfo:userInfo];
}

/**
 存储用户信息和工作中心信息
 
 @param user 用户信息
 */
- (void)transformUserInfoToLSUserInfo:(UserInfo *)user {
    LSUserInfoModel *lsUserInfo = [[LSUserInfoModel alloc] init];
    lsUserInfo.userid = user.username;
    lsUserInfo.usernick = user.usernick;
    lsUserInfo.phoneNumber = user.phoneNumber;
    lsUserInfo.workAddress = user.workAddress;
    lsUserInfo.empName = user.empName;
    lsUserInfo.sex = user.sex;
    lsUserInfo.image = user.avatar;
    lsUserInfo.isvalid = user.isvalid;
    lsUserInfo.jobname = user.jobname;
    lsUserInfo.dptNo = user.dptNo;
    lsUserInfo.right = user.right;
    lsUserInfo.empNo = user.empNo;
    lsUserInfo.dptName = user.dptName;
    BOOL success = [WCDBManager insertObject:lsUserInfo into:LSUserInfoModelTable];
    NSMutableArray *funcs = [NSMutableArray array];
    for (Func *funcModel in user.functionArray) {
        LSFuncModel *model = [[LSFuncModel alloc] init];
        model.funcAddress = funcModel.funcAddress;
        model.funcId = funcModel.funcId;
        model.funcIdx = funcModel.funcIdx;
        model.funcLogo = funcModel.funcLogo;
        model.funcName = funcModel.funcName;
        model.funcType = funcModel.funcType;
        model.funcTypeIdx = funcModel.funcTypeIdx;
        model.funcValid = funcModel.funcValid;
        model.typeName = funcModel.typeName;
        model.typeValid = funcModel.typeValid;
        [funcs addObject:model];
    }
    success = [WCDBManager insertObjects:funcs into:LSFuncModelTable];
}

    
- (void)fastConnectToServer {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kAccount] length] && [[[NSUserDefaults standardUserDefaults] objectForKey:kPassword] length]) {
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceToken];
        if(!token)
            token = @"1000001";
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kAccount];
        NSString *sessionId = [ShareObject sharedInstance].sessionid;
        [[RHSocketManager sharedInstance] sendFastConnectMessage:token sessionid:sessionId userid:userId];
    }
}

/**
 连接服务器通知
 
 @param notif 通知内容
 */
- (void)kNotificationSocketManagerServer:(NSNotification *)notif
{
    NSString *message = [notif object];
    if([message isEqualToString:@"连接成功"])
    {
        //App版本
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
        //token值  请获取设备 token
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceToken];
        //模拟器获取不到token, 生成假的Token,避免无法跟服务器握手的Error
        if(!token)
        {
            //int random = arc4random() % 100;
            //token = [NSString stringWithFormat:@"%d",random];
            token = @"1000001";
            
        }
        
        //连接服务器成功 发送握手消息
        [[RHSocketManager sharedInstance] sendHandShakeMessage:token clientVersion:currentVersion];
    }
}


/**
 离线消息通知接收

 @param notif notif description
 */
- (void)kNotificationSocketPrivateChatOffline:(NSNotification *)notif {
    LSLog(@"%@",notif.object);
    NSArray <PrivateMessage *>*messages = notif.object;
    for (PrivateMessage *message in messages) {
        MessageModel * model = [MessageModel new];
        model.id_p = message.id_p;
        model.type = MessagePropertyTypeChat;
        model.insertTime = [NSString stringWithFormat:@"%lld",message.time];
        model.receiverUserid = message.from;
        model.senderUserid = message.to;
        model.userimage = message.avatar;
        MessageContentModel *contentModel = [MessageContentModel yy_modelWithJSON:message.content];
        model.secret = contentModel.secret;
        model.body = contentModel.body;
        model.isSender = NO;
        model.messageType = message.type;
        model.senderUserName = contentModel.revceiverUserName;
        ContactModel *receiver = [WCDBManager getOneObjectOfClass:ContactModel.class fromTable:ContactModelTable where:ContactModel.userid == model.receiverUserid];
        model.receiverUserName = receiver.remarkContent.length ? receiver.remarkContent : contentModel.senderUserName;
        CGSize textSize = [PublicMethod calCulateBubbleTextSize:contentModel.body];
        if (model.secret) {
            model.bubbleHeight = 52;
            model.bubbleWidth = 110;
        } else {
            model.bubbleHeight = contentModel.bubbleHeight;
            model.bubbleWidth = contentModel.bubbleWidth;
        }
        model.locationAddress = contentModel.locationAddress;
        model.locationName = contentModel.locationName;
        model.latitude = contentModel.latitude;
        model.timeLength = contentModel.timeLength;
        model.longitude = contentModel.longitude;
        model.friendId = contentModel.friendId;
        model.friendName = contentModel.friendName;
        model.friendHeader = contentModel.friendHeader;
        model.isValid = contentModel.isValid;
        model.isEnable = contentModel.isEnable;
        model.fontSize = [UserInfor sharedInstance].fontSize;
        model.transitionTitle = contentModel.transitionTitle;
        MessageModel *lastMessageModel = [WCDBManager getLastObjectsOfClass:MessageModel.class fromTable:MessageContentTable where:MessageModel.receiverUserid == model.receiverUserid];
        if (lastMessageModel) {
            model.isShowTime = [model minuteOffSetStart:lastMessageModel.insertTime];
        }else if (!lastMessageModel) {
            model.isShowTime = YES;
        }
        if (model.messageType == MessageType_Notice) {
            model.isShowTime = NO;
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [WCDBManager insertObject:model into:MessageContentTable];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshContentVC];
            });
        });
        MessageListModel *listModel = [MessageListModel new];
        listModel.userId = message.from;
        listModel.mucidAndUserId = listModel.userId;
        listModel.userName = model.receiverUserName;
        listModel.type = MessagePropertyTypeChat;
        listModel.time = [[NSDate dateWithTimeIntervalSince1970:message.time] stringWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (contentModel.secret) {
            listModel.lastContent = @"[加密消息]";
        } else {
            if (model.messageType == MessageType_Image) {
                listModel.lastContent = @"[图片消息]";
            } else if (model.messageType == MessageType_Video) {
                listModel.lastContent = @"[视频消息]";
            } else if (model.messageType == MessageType_Vote) {
                listModel.lastContent = @"[投票消息]";
            } else if (model.messageType == MessageType_Voice) {
                listModel.lastContent = @"[语音消息]";
            } else if (model.messageType == MessageType_Map) {
                listModel.lastContent = @"[定位消息]";
            } else if (model.messageType == MessageType_Face) {
                listModel.lastContent = @"[动画表情]";
            } else if (model.messageType == MessageType_Contact) {
                listModel.lastContent = @"[名片消息]";
            } else if (model.messageType == MessageType_Multiple) {
                listModel.lastContent = @"[聊天记录]";
            } else if (model.messageType == MessageType_Card) {
                listModel.lastContent = @"[打卡消息]";
            } else {
                listModel.lastContent = model.body;
            }
        }
        [self refreshMessageListVCWithModel:listModel];
    }
}

-(void)refreshMessageListVCWithModel:(MessageListModel *)model
{
    static MessageListViewController * listVC = nil;
    if (listVC == nil) {
        listVC = (MessageListViewController *)[PublicMethod getVCByItsClassName:@"MessageListViewController"];
    }
    [listVC refreshTableViewWithModel:model animate:NO];
}

@end
