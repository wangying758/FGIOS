//
//  UITableView+SelectedIndex.m
//  MeiyeCommon
//
//  Created by Lisai on 2017/10/23.
//  Copyright © 2017年 yunhuachen. All rights reserved.
//

#import "UITableView+SelectedIndex.h"
#import <objc/runtime.h>

@implementation UITableView (SelectedIndex)

- (NSIndexPath *)selectedIndexPath {
    return objc_getAssociatedObject(self, @selector(selectedIndexPath));
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    objc_setAssociatedObject(self, @selector(selectedIndexPath), selectedIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self reloadData];
}

- (NSIndexPath *)preSelectIndexPath {
    return objc_getAssociatedObject(self, @selector(preSelectIndexPath));
}

- (void)setPreSelectIndexPath:(NSIndexPath *)preSelectIndexPath {
    objc_setAssociatedObject(self, @selector(preSelectIndexPath), preSelectIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self reloadData];
}


- (BOOL)isSelectedIndexPath:(NSIndexPath *)indexPath {
    if(self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row) {
        return YES;
    }
    return NO;
}

- (BOOL)isSelectedZeroIndexPath {
    if(self.selectedIndexPath.section == 0 && self.selectedIndexPath.row == 0) {
        return YES;
    }
    return NO;
}

@end
