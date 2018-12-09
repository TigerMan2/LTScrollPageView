//
//  LTSegmentView.h
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSegmentStyle.h"
#import "LTScrollPageViewDelegate.h"


@interface LTSegmentView : UIView

/** 所有标题的titles */
@property (nonatomic, strong) NSArray *titles;

/** 所有标题的设置 */
@property (nonatomic, strong) LTSegmentStyle *segmentStyle;

@property (nonatomic, weak) id<LTSegmentViewDelegate> delegate;


/** 实例方法 */
- (instancetype)initWithFrame:(CGRect)frame
                 segmentStyle:(LTSegmentStyle *)segmentStyle
                       titles:(NSArray *)titles;
/** 实例方法---推荐 */
- (instancetype)initWithFrame:(CGRect)frame
                 segmentStyle:(LTSegmentStyle *)segmentStyle
                     delegate:(id<LTSegmentViewDelegate>)delegate
                       titles:(NSArray *)titles;

/** 切换下标的时候，根据progress设置UI */
- (void)adjustUIWithProgress:(CGFloat)progress
                    oldIndex:(NSInteger)oldIndex
                currentIndex:(NSInteger)currentIndex;
/** 让选中的标题居中 */
- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)currentIndex;
/** 设置选中的下标 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
/** 重置标题的内容 */
- (void)reloadTitlesWithNewTitles:(NSArray *)titles;

@end
