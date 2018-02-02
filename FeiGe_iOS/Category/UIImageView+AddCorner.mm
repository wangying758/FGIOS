//
//  UIImageView+AddCorner.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/4.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "UIImageView+AddCorner.h"
#import "UIImage+ImageRoundedCorner.h"

@implementation UIImageView (AddCorner)

/**
 *高效的给imageView添加圆角，每次给imageView设置新的image后，请务必调用该方法。
 */
-(void)addCornerWithRadius:(CGFloat)radius size:(CGSize)size
{
    UIImage * image = self.image;
    image = [image imageWithRoundedCornerRadius:radius andSize:size];
    self.image = image;
}

@end
