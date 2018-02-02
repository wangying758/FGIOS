//
//  NSString+Extension.m
//  WeChat
//
//  Created by zhengwenming on 2017/9/21.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
/**
 * 计算文字高度，可以处理计算带行间距的
 */
- (CGSize)boundingRectWithSize:(CGSize)size paragraphStyle:(NSMutableParagraphStyle *)paragraphStyle font:(UIFont*)font
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.length)];
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.length)];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    CGRect rect = [attributeString boundingRectWithSize:size options:options context:nil];
    
    //    NSLog(@"size:%@", NSStringFromCGSize(rect.size));
    
    //文本的高度减去字体高度小于等于行间距，判断为当前只有1行
    if ((rect.size.height - font.lineHeight) <= paragraphStyle.lineSpacing) {
        if ([self containChinese:self]) {  //如果包含中文
            rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-paragraphStyle.lineSpacing);
        }
    }
    
    
    return rect.size;
}



/**
 * 计算文字高度，可以处理计算带行间距的
 */
- (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.length)];
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.length)];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    CGRect rect = [attributeString boundingRectWithSize:size options:options context:nil];
    
    //    NSLog(@"size:%@", NSStringFromCGSize(rect.size));
    
    //文本的高度减去字体高度小于等于行间距，判断为当前只有1行
    if ((rect.size.height - font.lineHeight) <= paragraphStyle.lineSpacing) {
        if ([self containChinese:self]) {  //如果包含中文
            rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-paragraphStyle.lineSpacing);
        }
    }
    
    
    return rect.size;
}



/**
 *  计算最大行数文字高度,可以处理计算带行间距的
 */
- (CGFloat)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing maxLines:(NSInteger)maxLines{
    
    if (maxLines <= 0) {
        return 0;
    }
    
    CGFloat maxHeight = font.lineHeight * maxLines + lineSpacing * (maxLines - 1);
    
    CGSize orginalSize = [self boundingRectWithSize:size font:font lineSpacing:lineSpacing];
    
    if ( orginalSize.height >= maxHeight ) {
        return maxHeight;
    }else{
        return orginalSize.height;
    }
}

/**
 *  计算是否超过一行
 */
- (BOOL)isMoreThanOneLineWithSize:(CGSize)size font:(UIFont *)font lineSpaceing:(CGFloat)lineSpacing{
    
    if ( [self boundingRectWithSize:size font:font lineSpacing:lineSpacing].height > font.lineHeight  ) {
        return YES;
    }else{
        return NO;
    }
}
//判断是否包含中文
- (BOOL)containChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}

/**
 *  1970年以来的毫秒数转化成聊天时间
 *
 *  @param type IMTimeTypeMessageUI 消息界面时间,
 IMTimeTypeChatUI    聊天界面时间
 *
 *  @return 时间字符串
 */
- (NSString *)translateToIMTimeWithType:(IMTimeType)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeInterval time = [self longLongValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    if ([PublicMethod isDateToday:date]) {
        int hour = [PublicMethod hour:date];
        [dateFormatter setDateFormat:@"HH:mm"];
        if (hour >=0 && hour < 6) {
            return [NSString stringWithFormat:@"凌晨 %@",[dateFormatter stringFromDate:date]];
        }
        else if (hour >=6 && hour < 12) {
            return [NSString stringWithFormat:@"上午 %@",[dateFormatter stringFromDate:date]];
        }
        else if (hour >=12 && hour < 18) {
            return [NSString stringWithFormat:@"下午 %@",[dateFormatter stringFromDate:date]];
        }
        else {
            return [NSString stringWithFormat:@"晚上 %@",[dateFormatter stringFromDate:date]];
        }
    }
    else if ([PublicMethod isDateYesterday:date]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:date]];
    }
    else if ([PublicMethod isDateThisWeek:date]) {
        if (type == IMTimeTypeMessageUI) {
            [dateFormatter setDateFormat:@"EEEE"];
        }
        else {
            [dateFormatter setDateFormat:@"EEEE HH:mm"];
        }
        return [dateFormatter stringFromDate:date];
    }
    else if ([PublicMethod isDateThisYear:date]) {
        if (type == IMTimeTypeMessageUI) {
            [dateFormatter setDateFormat:@"MM/dd"];
        }
        else {
            [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm"];
        }
        return [dateFormatter stringFromDate:date];
    }
    else {
        if (type == IMTimeTypeMessageUI) {
            [dateFormatter setDateFormat:@"yyyy"];
        }
        else {
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        }
        return [dateFormatter stringFromDate:date];
    }
}

@end
