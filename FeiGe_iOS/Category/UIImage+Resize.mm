//
//  UIImage+Resize.m
//  ElectronicCar
//
//  Created by 曾照成 on 17/4/8.
//  Copyright © 2017年 易通星云. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

/*
 Method 1: Using UIKit
 This method is very simple, and works great. It will also deal with the UIImageOrientation for you, meaning that you don't have to care whether the camera was sideways when the picture was taken.However, this method is not thread safe, and since thumbnailing is a relatively expensive operation (approximately ~2.5s on a 3G for a 1600 x 1200 pixel image), this is very much an operation you may want to do in the background, on a separate thread.
 */
- (UIImage*)scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)resizableImage {
    CGFloat capWidth =  floorf(self.size.width / 2);
    CGFloat capHeight =  floorf(self.size.height / 2);
    UIImage *capImage = [self resizableImageWithCapInsets:
                         UIEdgeInsetsMake(capHeight, capWidth, capHeight, capWidth)];
    
    return capImage;
}



@end
