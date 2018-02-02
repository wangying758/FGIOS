//
//  UIImage+WLTScaleImage.h
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/21.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WLTScaleImage)

+(UIImage *)scaleImage:(UIImage *)image toKb:(NSInteger)kb;

+(NSData *)scaleImage:(UIImage *)image toKB:(NSInteger)kb;

@end
