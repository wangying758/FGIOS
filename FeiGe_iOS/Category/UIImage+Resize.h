//
//  UIImage+Resize.h
//  ElectronicCar
//
//  Created by 曾照成 on 17/4/8.
//  Copyright © 2017年 易通星云. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

/**
 *改变图片尺寸
 */
- (UIImage*)scaledToSize:(CGSize)newSize;

- (UIImage *)resizableImage;


@end
