//
//  NSString+StringFrame.m
//  FeiGe_iOS
//
//  Created by lensit on 2017/8/7.
//  Copyright © 2017年 lensit. All rights reserved.
//

#import "NSString+StringFrame.h"

@implementation NSString (StringFrame)

/**
 *  @brief  根据字符串的宽(或高)和字体的大小计算字符串的size
 *  @param  size 给定字符串的宽或高
 *  @param  font 字体属性
 *  @return 字符串的宽和高
 */
- (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont *)font;
{
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize reSize = [self boundingRectWithSize:size
                                       options:
                     NSStringDrawingTruncatesLastVisibleLine |
                     NSStringDrawingUsesLineFragmentOrigin |
                     NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil].size;
    
    return reSize;
}

/**
 *  @brief  根据字符串字体的大小(和最大宽度)计算字符串的size
 *  @param  size        给定字符串的(最小)高
 *  @param  font        字体属性
 *  @param  maxWidth    字符串最大的宽度
 *  @return 字符串的宽和高
 */
- (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    NSArray *array = [self componentsSeparatedByString:@"\n"];
    array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *str1 = obj1;
        NSString *str2 = obj2;
        
        NSComparisonResult result;
        
        if (str1.length > str2.length)
        {
            result = NSOrderedAscending;
        }
        else if (str1.length < str2.length)
        {
            result = NSOrderedDescending;
        }
        else
        {
            result = NSOrderedSame;
        }
        
        return result;
    }];
    
    CGSize reSize = [array[0] boundingRectWithSize:size font:font];
    
    if (reSize.width > maxWidth)
    {
        reSize = [self boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) font:font];
    }
    else
    {
        reSize = [self boundingRectWithSize:CGSizeMake(reSize.width, MAXFLOAT) font:font];
    }
    
    return reSize;
}


@end
