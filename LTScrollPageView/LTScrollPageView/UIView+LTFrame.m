//
//  UIView+LTFrame.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "UIView+LTFrame.h"

@implementation UIView (LTFrame)

#pragma mark -----getter------
- (CGFloat)lt_x {
    return self.frame.origin.x;
}

- (CGFloat)lt_y {
    return self.frame.origin.y;
}

- (CGFloat)lt_centerX {
    return self.center.x;
}

- (CGFloat)lt_centerY {
    return self.center.y;
}

- (CGFloat)lt_width {
    return self.frame.size.width;
}

- (CGFloat)lt_height {
    return self.frame.size.height;
}

#pragma mark -----setter------
- (void)setLt_centerX:(CGFloat)lt_centerX {
    CGPoint center = self.center;
    center.x = lt_centerX;
    self.center = center;
}

- (void)setLt_centerY:(CGFloat)lt_centerY {
    CGPoint center = self.center;
    center.y = lt_centerY;
    self.center = center;
}

- (void)setLt_x:(CGFloat)lt_x {
    CGRect rect = self.frame;
    rect.origin.x = lt_x;
    self.frame = rect;
}

- (void)setLt_y:(CGFloat)lt_y {
    CGRect rect = self.frame;
    rect.origin.y = lt_y;
    self.frame = rect;
}

- (void)setLt_width:(CGFloat)lt_width {
    CGRect rect = self.frame;
    rect.size.width = lt_width;
    self.frame = rect;
}

- (void)setLt_height:(CGFloat)lt_height {
    CGRect rect = self.frame;
    rect.size.height = lt_height;
    self.frame = rect;
}

@end
