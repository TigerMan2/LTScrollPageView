//
//  LTSegmentStyle.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTSegmentStyle.h"

@implementation LTSegmentStyle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _showCover = NO;
    _showLine = NO;
    _scaleTitle = NO;
    _scrollTitle = YES;
    _segmentViewBounces = YES;
    _contentViewBounces = YES;
    _gradualChangeTitleColor = NO;
    _scrollContentView = YES;
    _adjustCoverOrLineWidth = NO;
    _showImage = NO;
    _autoAdjustTitlesWidth = NO;
    _adjustTitleWhenBeginDrag = NO;
    _scrollLineHeight = 2.0;
    _scrollLineColor = [UIColor brownColor];
    _coverBackgroundColor = [UIColor lightGrayColor];
    _coverCornerRadius = 14;
    _coverHeight = 28.0;
    _titleMargin = 15.0;
    _titleFont = [UIFont systemFontOfSize:14.0];
    _titleBigScale = 1.3;
    _normalTitleColor = [UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:75/255.0 alpha:1.0];
    _selectedTitleColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:121/255.0 alpha:1.0];
    
}

@end
