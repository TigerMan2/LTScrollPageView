//
//  LTTitleView.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSegmentStyle.h"

@interface LTTitleView : UIView

@property (nonatomic, assign) TitleImagePosition imagePosition;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (assign, nonatomic) CGFloat currentTransformSx;

/** 下面的属性推荐在代理里面设置 */
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *label;


- (void)adjustSubviewFrame;
- (CGFloat)titleViewWidth;

@end
