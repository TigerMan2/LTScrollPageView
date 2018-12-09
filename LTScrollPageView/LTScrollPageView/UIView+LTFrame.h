//
//  UIView+LTFrame.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LTFrame)

@property (nonatomic, assign) CGFloat lt_centerX;   //self.center.x
@property (nonatomic, assign) CGFloat lt_centerY;   //self.center.y

@property (nonatomic, assign) CGFloat lt_width;     //self.frame.size.width
@property (nonatomic, assign) CGFloat lt_height;    //self.frame.size.height
@property (nonatomic, assign) CGFloat lt_x;         //self.frame.origin.x
@property (nonatomic, assign) CGFloat lt_y;         //self.frame.origin.y

@end
