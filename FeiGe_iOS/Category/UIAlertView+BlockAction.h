//
//  UIAlertView+BlockAction.h
//  TuliuBroker
//
//  Created by zzc on 16/8/19.
//  Copyright © 2016年 tuliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock) (NSInteger buttonIndex);//0表示左边按钮 1表示右边按钮

@interface UIAlertView (BlockAction)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showWithCompleteBlock:(CompleteBlock) block;

@end
