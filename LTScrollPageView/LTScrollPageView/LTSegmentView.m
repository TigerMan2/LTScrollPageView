//
//  LTSegmentView.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTSegmentView.h"
#import "LTTitleView.h"
#import "UIView+LTFrame.h"

@interface LTSegmentView () <UIScrollViewDelegate>
{
    CGFloat _currentWidth;
    NSUInteger _currentIndex;
    NSUInteger _oldIndex;
}

/** 滚动条 */
@property (nonatomic, strong) UIView *scrollLine;
/** 遮盖 */
@property (nonatomic, strong) UIView *coverLayer;
/** 滚动视图 */
@property (nonatomic, strong) UIScrollView *scrollView;
/** 缓存所有标题的label */
@property (nonatomic, strong) NSMutableArray *titleViews;
/** 缓存计算出每个标题的宽度 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

// 用于懒加载计算文字的rgba差值, 用于颜色渐变的时候设置
@property (strong, nonatomic) NSArray *deltaRGBA;
@property (strong, nonatomic) NSArray *selectedColorRGBA;
@property (strong, nonatomic) NSArray *normalColorRGBA;
@end

@implementation LTSegmentView

static CGFloat const xGap = 5.0;
static CGFloat const wGap = 2 * xGap;
static CGFloat const contentSizeXoffset = 20.0;

#pragma mark - lifr cycle
- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(LTSegmentStyle *)segmentStyle titles:(NSArray *)titles {
    return [self initWithFrame:frame segmentStyle:segmentStyle delegate:nil titles:titles];
}
/** 推荐 */
- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(LTSegmentStyle *)segmentStyle delegate:(id<LTSegmentViewDelegate>)delegate titles:(NSArray *)titles {
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.segmentStyle = segmentStyle;
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;
        self.delegate = delegate;
        
        if (!self.segmentStyle.isScrollTitle) { // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好
            
            self.segmentStyle.scaleTitle = !(self.segmentStyle.isShowCover || self.segmentStyle.isShowLine);
        }
        
        if (self.segmentStyle.isShowImage) {
            self.segmentStyle.scaleTitle = NO;
            self.segmentStyle.showCover = NO;
            self.segmentStyle.gradualChangeTitleColor = NO;
        }
        
        [self setupSubviews];
        [self setupUI];
    }
    return self;
}

- (void)setupSubviews {
    [self addSubview:self.scrollView];
    [self addScrollLineOrCover];
    [self setupTitles];
}

- (void)addScrollLineOrCover {
    /** 显示滚动条 */
    if (self.segmentStyle.isShowLine) {
        [self.scrollView addSubview:self.scrollLine];
    }
    
    /** 显示遮盖 */
    if (self.segmentStyle.isShowCover) {
        [self.scrollView insertSubview:self.coverLayer atIndex:0];
    }
}

#pragma mark - private helper
- (void)setupTitles {
    
    if (self.titles.count==0) return;
    
    NSInteger index = 0;
    for (NSString *title in self.titles) {
        LTTitleView *titleView = [[LTTitleView alloc] init];
        titleView.tag = index;
        
        titleView.font = self.segmentStyle.titleFont;
        titleView.text = title;
        titleView.textColor = self.segmentStyle.normalTitleColor;
        titleView.imagePosition = self.segmentStyle.imagePosition;
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelOnClick:)];
        [titleView addGestureRecognizer:tapGes];
        
        CGFloat titleViewWidth = [titleView titleViewWidth];
        
        [self.titleWidths addObject:@(titleViewWidth)];
        [self.scrollView addSubview:titleView];
        [self.titleViews addObject:titleView];
        
        index ++;
        
    }
    
}

- (void)setupUI {
    
    if (self.titles.count==0) return;
    
    self.scrollView.frame = CGRectMake(0.0, 0.0, self.lt_width, self.lt_height);
    //标题
    [self setupTitleViewsPosition];
    //滚动条和遮盖
    [self setupScrollLineAndCover];
    
    if (self.segmentStyle.isScrollTitle) { // 设置滚动区域
        LTTitleView *lastTitleView = (LTTitleView *)self.titleViews.lastObject;
        
        if (lastTitleView) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTitleView.frame) + contentSizeXoffset, 0.0);
        }
    }
}

- (void)setupTitleViewsPosition {
    CGFloat titleX = 0.0;
    CGFloat titleY = 0.0;
    CGFloat titleW = 0.0;
    CGFloat titleH = self.lt_height - self.segmentStyle.scrollLineHeight;
    if (!self.segmentStyle.scrollTitle) {
        //标题不能滚动 平分
        titleW = self.scrollView.lt_width / self.titles.count;
        
        NSInteger index = 0;
        for (LTTitleView *titleView in self.titleViews) {
            titleX = index * titleW;
            titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
            if (self.segmentStyle.isShowImage) {
                [titleView adjustSubviewFrame];
            }
            
            index ++;
        }
    } else {
        NSInteger index = 0;
        CGFloat lastLabelMaxX = self.segmentStyle.titleMargin;
        CGFloat addMargin = 0.0;
        if (self.segmentStyle.isAutoAdjustTitlesWidth) {
            
            CGFloat allTitlesWidth = self.segmentStyle.titleMargin;
            for (int i = 0; i < self.titleWidths.count; i ++) {
                allTitlesWidth = allTitlesWidth + [self.titleWidths[i] floatValue] + self.segmentStyle.titleMargin;
            }
            
            addMargin = allTitlesWidth < self.scrollView.lt_width ? (self.scrollView.lt_width - allTitlesWidth)/self.titleWidths.count : 0;
        }
        
        for (LTTitleView *titleView in self.titleViews) {
            titleW = [self.titleWidths[index] floatValue];
            titleX = lastLabelMaxX + addMargin/2;
            
            lastLabelMaxX += (titleW + addMargin + self.segmentStyle.titleMargin);
            titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
            
            if (self.segmentStyle.isShowImage) {
                [titleView adjustSubviewFrame];
            }
            
            index ++;
        }
        
    }
    
    LTTitleView *currentView = (LTTitleView *)self.titleViews[_currentIndex];
    currentView.currentTransformSx = 1.0;
    if (currentView) {
        /** 缩放 */
        if (self.segmentStyle.isScaleTitle) {
            currentView.currentTransformSx = self.segmentStyle.titleBigScale;
        }
        /** 设置初始状态的文字 */
        currentView.textColor = self.segmentStyle.selectedTitleColor;
        if (self.segmentStyle.isShowImage) {
            currentView.selected = YES;
        }
    }
    
}

- (void)setupScrollLineAndCover {
    
    LTTitleView *firstTitleView = self.titleViews[0];
    
    CGFloat coverX = firstTitleView.lt_x;
    CGFloat coverW = firstTitleView.lt_width;
    CGFloat coverH = self.segmentStyle.coverHeight;
    CGFloat coverY = (self.lt_height - coverH) * 0.5;
    
    //滚动条
    if (self.scrollLine) {
        
        if (self.segmentStyle.isScrollTitle) {
            self.scrollLine.frame = CGRectMake(coverX, self.lt_height - self.segmentStyle.scrollLineHeight, coverW, self.segmentStyle.scrollLineHeight);
        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                coverX = (firstTitleView.lt_width - coverW) * 0.5;
            }
            
            self.scrollLine.frame = CGRectMake(coverX, self.lt_height - self.segmentStyle.scrollLineHeight, coverW, self.segmentStyle.scrollLineHeight);
        }
    }
    
    //遮盖
    if (self.coverLayer) {
        
        if (self.segmentStyle.isScrollTitle) {
            self.coverLayer.frame = CGRectMake(coverX - xGap, coverY, coverW + wGap, coverH);
        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                coverX = (firstTitleView.lt_width - coverW) * 0.5;
            }
            
            self.coverLayer.frame = CGRectMake(coverX, coverY, coverW, coverH);
        }
    }
    
}

#pragma mark - button action
- (void)titleLabelOnClick:(UITapGestureRecognizer *)tapGes {
    LTTitleView *currentLabel = (LTTitleView *)tapGes.view;
    
    if (!currentLabel) {
        return;
    }
    
    _currentIndex = currentLabel.tag;
    
    [self adjustUIWhenBtnOnClickWithAnimate:YES taped:YES];
}

#pragma mark - public helper
- (void)adjustUIWhenBtnOnClickWithAnimate:(BOOL)animated taped:(BOOL)taped {
    
    if (_currentIndex == _oldIndex && taped) return;
    
    LTTitleView *currentTitleView = (LTTitleView *)self.titleViews[_currentIndex];
    LTTitleView *oldTitleView = (LTTitleView *)self.titleViews[_oldIndex];
    
    CGFloat animatedTime = animated ? 0.30 : 0;
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:animatedTime animations:^{
        /** 文字选中和未选中更换 */
        oldTitleView.textColor = weakSelf.segmentStyle.normalTitleColor;
        currentTitleView.textColor = weakSelf.segmentStyle.selectedTitleColor;
        /** 标题选中和未选中更换 */
        oldTitleView.selected = NO;
        currentTitleView.selected = YES;
        if (weakSelf.segmentStyle.isScaleTitle) {
            /** 文字缩放的更换 */
            oldTitleView.currentTransformSx = 1.0;
            currentTitleView.currentTransformSx = weakSelf.segmentStyle.titleBigScale;
        }
        
        //滚动条
        if (weakSelf.scrollLine) {
            if (weakSelf.segmentStyle.isScrollTitle) {
                weakSelf.scrollLine.lt_x = currentTitleView.lt_x;
                weakSelf.scrollLine.lt_width = currentTitleView.lt_width;
            } else {
                if (weakSelf.segmentStyle.isAdjustCoverOrLineWidth) {
                    CGFloat scrollLineW = [weakSelf.titleWidths[self->_currentIndex] floatValue] + wGap;
                    CGFloat scrollLineX = currentTitleView.lt_x + (currentTitleView.lt_width - scrollLineW)*0.5;
                    weakSelf.scrollLine.lt_x = scrollLineX;
                    weakSelf.scrollLine.lt_width = scrollLineW;
                } else {
                    weakSelf.scrollLine.lt_x = currentTitleView.lt_x;
                    weakSelf.scrollLine.lt_width = currentTitleView.lt_width;
                }
            }
        }
        
        /** 遮盖 */
        if (weakSelf.coverLayer) {
            if (weakSelf.segmentStyle.isScrollTitle) {
                
                weakSelf.coverLayer.lt_x = currentTitleView.lt_x - xGap;
                weakSelf.coverLayer.lt_width = currentTitleView.lt_width + wGap;
            } else {
                if (weakSelf.segmentStyle.isAdjustCoverOrLineWidth) {
                    CGFloat coverW = [weakSelf.titleWidths[self->_currentIndex] floatValue] + wGap;
                    CGFloat coverX = currentTitleView.lt_x + (currentTitleView.lt_width - coverW) * 0.5;
                    weakSelf.coverLayer.lt_x = coverX;
                    weakSelf.coverLayer.lt_width = coverW;
                } else {
                    weakSelf.coverLayer.lt_x = currentTitleView.lt_x;
                    weakSelf.coverLayer.lt_width = currentTitleView.lt_width;
                }
            }
            
        }
        
    } completion:^(BOOL finished) {
        [self adjustTitleOffsetToCurrentIndex:self->_currentIndex];
    }];
    /** 覆盖数据 */
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(LTSegmentView:oldTitleView:currentTitleView:oldIndex:currentIndex:)]) {
        [self.delegate LTSegmentView:self oldTitleView:oldTitleView currentTitleView:currentTitleView oldIndex:_oldIndex currentIndex:_currentIndex];
    }
    
    _oldIndex = _currentIndex;
    
}

- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    if (oldIndex < 0 || currentIndex > self.titles.count || currentIndex < 0 || currentIndex > self.titles.count) {
        return;
    }
    _oldIndex = currentIndex;
    
    LTTitleView *oldTitleView = (LTTitleView *)self.titleViews[oldIndex];
    LTTitleView *currentTitleView = (LTTitleView *)self.titleViews[currentIndex];
    /** 计算x移动的距离 */
    CGFloat xDistance = currentTitleView.lt_x - oldTitleView.lt_x;
    /** 计算w的差距 */
    CGFloat wDistance = currentTitleView.lt_width - oldTitleView.lt_width;
    /** 滚动条 */
    if (self.scrollLine) {
        if (self.segmentStyle.isScrollTitle) {
            self.scrollLine.lt_x = oldTitleView.lt_x + xDistance * progress;
            self.scrollLine.lt_width = oldTitleView.lt_width + wDistance * progress;
        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                CGFloat oldScrollLineW = [self.titleWidths[oldIndex] floatValue] + wGap;
                CGFloat currentScrollLineW = [self.titleWidths[currentIndex] floatValue] + wGap;
                wDistance = currentScrollLineW = oldScrollLineW;
                
                CGFloat oldScrollLineX = oldTitleView.lt_width + (oldTitleView.lt_width - oldScrollLineW) * 0.5;
                CGFloat currentScrollLineX = currentTitleView.lt_width + (currentTitleView.lt_width - currentScrollLineW) * 0.5;
                xDistance = currentScrollLineX - oldScrollLineX;
                self.scrollLine.lt_x = oldScrollLineX + xDistance * progress;
                self.scrollLine.lt_width = oldScrollLineW + wDistance * progress;
            } else {
                self.scrollLine.lt_x = oldTitleView.lt_x + xDistance * progress;
                self.scrollLine.lt_width = oldTitleView.lt_width + wDistance * progress;
            }
        }
    }
    // 渐变
    if (self.segmentStyle.isGradualChangeTitleColor) {
        
        oldTitleView.textColor = [UIColor
                                  colorWithRed:[self.selectedColorRGBA[0] floatValue] + [self.deltaRGBA[0] floatValue] * progress
                                  green:[self.selectedColorRGBA[1] floatValue] + [self.deltaRGBA[1] floatValue] * progress
                                  blue:[self.selectedColorRGBA[2] floatValue] + [self.deltaRGBA[2] floatValue] * progress
                                  alpha:[self.selectedColorRGBA[3] floatValue] + [self.deltaRGBA[3] floatValue] * progress];
        
        currentTitleView.textColor = [UIColor
                                      colorWithRed:[self.normalColorRGBA[0] floatValue] - [self.deltaRGBA[0] floatValue] * progress
                                      green:[self.normalColorRGBA[1] floatValue] - [self.deltaRGBA[1] floatValue] * progress
                                      blue:[self.normalColorRGBA[2] floatValue] - [self.deltaRGBA[2] floatValue] * progress
                                      alpha:[self.normalColorRGBA[3] floatValue] - [self.deltaRGBA[3] floatValue] * progress];
        
    }
    /** 遮盖 */
    if (self.coverLayer) {
        if (self.segmentStyle.isScrollTitle) {
            self.coverLayer.lt_x = oldTitleView.lt_x + xDistance * progress - xGap;
            self.coverLayer.lt_width = oldTitleView.lt_width + wDistance * progress + wGap;
        } else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                CGFloat oldCoverW = [self.titleWidths[oldIndex] floatValue] + wGap;
                CGFloat currentCoverW = [self.titleWidths[currentIndex] floatValue] + wGap;
                wDistance = currentCoverW - oldCoverW;
                CGFloat oldCoverX = oldTitleView.lt_x + (oldTitleView.lt_width - oldCoverW) * 0.5;
                CGFloat currentCoverX = currentTitleView.lt_x + (currentTitleView.lt_width - currentCoverW) * 0.5;
                xDistance = currentCoverX - oldCoverX;
                self.coverLayer.lt_x = oldCoverX + xDistance * progress;
                self.coverLayer.lt_width = oldCoverW + wDistance * progress;
            } else {
                self.coverLayer.lt_x = oldTitleView.lt_x + xDistance * progress;
                self.coverLayer.lt_width = oldTitleView.lt_width + wDistance * progress;
            }
        }
    }
    
    if (!self.segmentStyle.isScaleTitle) {
        return;
    }
    
    CGFloat deltaScale = self.segmentStyle.titleBigScale - 1.0;
    oldTitleView.currentTransformSx = self.segmentStyle.titleBigScale - deltaScale * progress;
    currentTitleView.currentTransformSx = 1.0 + deltaScale * progress;
    
}

- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)currentIndex {
    _oldIndex = currentIndex;
    int index = 0;
    for (LTTitleView *titleView in self.titleViews) {
        if (index != currentIndex) {
            titleView.textColor = self.segmentStyle.normalTitleColor;
            titleView.currentTransformSx = 1.0;
            titleView.selected = NO;
        } else {
            titleView.textColor = self.segmentStyle.selectedTitleColor;
            if (self.segmentStyle.isScaleTitle) {
                titleView.currentTransformSx = self.segmentStyle.titleBigScale;
            }
            titleView.selected = YES;
        }
        
        index ++;
    }
    
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width + contentSizeXoffset) {//需要滚动
        LTTitleView *currentTitleView = (LTTitleView *)self.titleViews[currentIndex];
        
        CGFloat offSetx = currentTitleView.center.x - _currentWidth * 0.5;
        if (offSetx < 0) {
            offSetx = 0;
        }
        
        CGFloat maxOffSetX = self.scrollView.contentSize.width - _currentWidth;
        if (maxOffSetX < 0) {
            maxOffSetX = 0;
        }
        
        if (offSetx > maxOffSetX) {
            offSetx = maxOffSetX;
        }
        
        [self.scrollView setContentOffset:CGPointMake(offSetx, 0.0) animated:YES];
        
    }
    
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    NSAssert(index >= 0 && index < self.titles.count, @"设置的下标不合法!!");
    
    if (index < 0 || index >= self.titles.count) {
        return;
    }
    
    _currentIndex = index;
    [self adjustUIWhenBtnOnClickWithAnimate:animated taped:NO];
}

- (void)reloadTitlesWithNewTitles:(NSArray *)titles {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _currentIndex = 0;
    _oldIndex = 0;
    self.titleWidths = nil;
    self.titleViews = nil;
    self.titles = nil;
    self.titles = [titles copy];
    if (self.titles.count == 0) return;
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    [self setupSubviews];
    [self setupUI];
    [self setSelectedIndex:0 animated:YES];
    
}

#pragma mark - getter
- (UIView *)scrollLine {
    
    if (!self.segmentStyle.isShowLine) {
        return nil;
    }
    
    if (!_scrollLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = self.segmentStyle.scrollLineColor;
        _scrollLine = lineView;
    }
    
    return _scrollLine;
}

- (UIView *)coverLayer {
    
    if (!self.segmentStyle.isShowCover) {
        return nil;
    }
    if (!_coverLayer) {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = self.segmentStyle.coverBackgroundColor;
        coverView.layer.cornerRadius = self.segmentStyle.coverCornerRadius;
        coverView.layer.masksToBounds = YES;
        _coverLayer = coverView;
    }
    return _coverLayer;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = self.segmentStyle.isSegmentViewBounces;
        scrollView.delegate = self;
        scrollView.pagingEnabled = NO;
        scrollView.scrollsToTop = NO;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (NSMutableArray *)titleViews {
    if (!_titleViews) {
        _titleViews = [NSMutableArray array];
    }
    return _titleViews;
}

- (NSMutableArray *)titleWidths {
    if (!_titleWidths) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

- (NSArray *)deltaRGBA {
    if (_deltaRGBA == nil) {
        NSArray *normalColorRgb = self.normalColorRGBA;
        NSArray *selectedColorRgb = self.selectedColorRGBA;
        
        NSArray *delta;
        if (normalColorRgb && selectedColorRgb) {
            CGFloat deltaR = [normalColorRgb[0] floatValue] - [selectedColorRgb[0] floatValue];
            CGFloat deltaG = [normalColorRgb[1] floatValue] - [selectedColorRgb[1] floatValue];
            CGFloat deltaB = [normalColorRgb[2] floatValue] - [selectedColorRgb[2] floatValue];
            CGFloat deltaA = [normalColorRgb[3] floatValue] - [selectedColorRgb[3] floatValue];
            delta = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), @(deltaA), nil];
            _deltaRGBA = delta;
            
        }
    }
    return _deltaRGBA;
}

- (NSArray *)normalColorRGBA {
    if (!_normalColorRGBA) {
        NSArray *normalColorRGBA = [self getColorRGBA:self.segmentStyle.normalTitleColor];
        NSAssert(normalColorRGBA, @"设置普通状态的文字颜色时 请使用RGBA空间的颜色值");
        _normalColorRGBA = normalColorRGBA;
        
    }
    return  _normalColorRGBA;
}

- (NSArray *)selectedColorRGBA {
    if (!_selectedColorRGBA) {
        NSArray *selectedColorRGBA = [self getColorRGBA:self.segmentStyle.selectedTitleColor];
        NSAssert(selectedColorRGBA, @"设置选中状态的文字颜色时 请使用RGBA空间的颜色值");
        _selectedColorRGBA = selectedColorRGBA;
        
    }
    return  _selectedColorRGBA;
}

- (NSArray *)getColorRGBA:(UIColor *)color {
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbaComponents;
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbaComponents = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), @(components[3]), nil];
    }
    return rgbaComponents;
    
}

@end
