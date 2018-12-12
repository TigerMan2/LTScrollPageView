//
//  LTSegmentStyle.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TitleImagePosition) {
    TitleImagePositionTop,
    TitleImagePositionLeft,
    TitleImagePositionRight,
    TitleImagePositionCenter,
};

@interface LTSegmentStyle : NSObject

@property (nonatomic, assign) TitleImagePosition imagePosition;

/** 是否显示滚动条 默认是NO */
@property (nonatomic, assign, getter=isShowLine) BOOL showLine;
/** 是否显示遮盖 默认是NO */
@property (nonatomic, assign, getter=isShowCover) BOOL showCover;
/** 是否显示图片 默认是NO */
@property (nonatomic, assign, getter=isShowImage) BOOL showImage;
/** 是否缩放标题 默认是NO */
@property (nonatomic, assign, getter=isScaleTitle) BOOL scaleTitle;
/** 标题的View的弹性 默认是YES */
@property (nonatomic, assign, getter=isSegmentViewBounces) BOOL segmentViewBounces;
/** 标题颜色是否渐变 默认是NO */
@property (nonatomic, assign, getter=isGradualChangeTitleColor) BOOL gradualChangeTitleColor;
/** 标题是否可滚动 默认是YES*/
@property (nonatomic, assign, getter=isScrollTitle) BOOL scrollTitle;
/** 是否自动调整标题的宽度 默认是NO*/
@property (nonatomic, assign, getter=isAutoAdjustTitlesWidth) BOOL autoAdjustTitlesWidth;
/** 是否自动调整遮盖的宽度 默认是NO*/
@property (assign, nonatomic, getter=isAdjustCoverOrLineWidth) BOOL adjustCoverOrLineWidth;
/** 内容的View的弹性 默认是YES */
@property (nonatomic, assign, getter=isContentViewBounces) BOOL contentViewBounces;
/** 内容的View是否可以滑动 默认是YES */
@property (nonatomic, assign, getter=isScrollContentView) BOOL scrollContentView;
/** 是否在开始滚动的时候就调整标题栏 默认为NO */
@property (assign, nonatomic, getter=isAdjustTitleWhenBeginDrag) BOOL adjustTitleWhenBeginDrag;


/** 滚动条的颜色 */
@property (nonatomic, strong) UIColor *scrollLineColor;
/** 遮盖的背景颜色 */
@property (nonatomic, strong) UIColor *coverBackgroundColor;
/** 遮盖的圆角 默认是14*/
@property (nonatomic, assign) CGFloat coverCornerRadius;
/** 标题的字体 默认是14 */
@property (nonatomic, strong) UIFont *titleFont;
/** 标题默认的颜色 */
@property (nonatomic, strong) UIColor *normalTitleColor;
/** 滚动条的高度 默认是2 */
@property (nonatomic, assign) CGFloat scrollLineHeight;
/** 标题之间的间距 默认是15.0 */
@property (nonatomic, assign) CGFloat titleMargin;
/** 标题缩放的比例 默认是1.3 */
@property (nonatomic, assign) CGFloat titleBigScale;
/** 选中标题的颜色 */
@property (nonatomic, strong) UIColor *selectedTitleColor;
/** 遮盖的高度 默认是28 */
@property (nonatomic, assign) CGFloat coverHeight;

@end
