//
//  UIBarButtonItem+Extension.m
//  美团
//
//  Created by apple on 15/8/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)

//图片转UIBarButtonItem
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(UIImage *)image highImage:(UIImage *)highImage
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:highImage forState:UIControlStateHighlighted];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.size = btn.currentImage.size;
    //btn.width = 60;
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    return item;
}

@end
