//
//  UIAlertView+BlockAction.m
//  TuliuBroker
//
//  Created by zzc on 16/8/19.
//  Copyright © 2016年 tuliu. All rights reserved.
//

#import "UIAlertView+BlockAction.h"
#import <objc/runtime.h>

//static char *key = "NTOAlertView";

@implementation UIAlertView (BlockAction)

- (void)showWithCompleteBlock:(CompleteBlock)block
{
    if (block) {
        ////移除所有关联
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, "NTOAlertView", block, OBJC_ASSOCIATION_COPY);
        ////设置delegate
        self.delegate = self;
    }
    ////show
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ///获取关联的对象，通过关键字。
    CompleteBlock block = objc_getAssociatedObject(self, "NTOAlertView");
    if (block) {
        ///block传值
        block(buttonIndex);
    }
}

@end
