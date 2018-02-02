//
//  UIControl+ActionBlock.h
//  TimeButton
//
//  Created by 曾照成 on 16/8/11.
//  Copyright © 2016年 曾照成. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionHandler)(void);

@interface UIControl (ActionBlock)

/**
 *  以block形式返回控件动作
 */
-(void)addActionForEvent:(UIControlEvents)event respond:(CompletionHandler)completion;

@end
