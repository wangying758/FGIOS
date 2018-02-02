//
//  UIControl+ActionBlock.m
//  TimeButton
//
//  Created by 曾照成 on 16/8/11.
//  Copyright © 2016年 曾照成. All rights reserved.
//

#import "UIControl+ActionBlock.h"
#import <objc/runtime.h>

const char * blockKey = "actionBlock";

@implementation UIControl (ActionBlock)

-(void)addActionForEvent:(UIControlEvents)event respond:(CompletionHandler)completion{
    [self addTarget:self action:@selector(Action) forControlEvents:event];
    void (^block)(void) = ^{
        completion();
    };
    objc_setAssociatedObject(self, blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void)Action{
    void (^block)(void) = objc_getAssociatedObject(self, blockKey);
    block();
}

@end
