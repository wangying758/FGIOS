//
//  UITextField+Awsome.m
//  ElectronicCar
//
//  Created by 曾照成 on 17/4/8.
//  Copyright © 2017年 易通星云. All rights reserved.
//

#import "UITextField+Awsome.h"

@implementation UITextField (Awsome)


-(void)setPlaceholderColor:(UIColor *)color
{
    [self setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}

@end
