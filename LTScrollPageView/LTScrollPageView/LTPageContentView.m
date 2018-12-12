//
//  LTPageContentView.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTPageContentView.h"
#import "UIView+LTFrame.h"

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
static NSString *collectionCellIdentifier = @"collectionCellIdentifier";

@interface LTPageContentView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIScrollViewDelegate
>

@property (nonatomic, weak) UIViewController *parentVC;//父视图
@property (nonatomic, strong) NSArray *childsVCs;//子视图数组
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat startOffsetX;
@property (nonatomic, strong) LTSegmentStyle *segmentStyle;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger oldIndex;
// 当这个属性设置为YES的时候 就不用处理 scrollView滚动的计算
@property (assign, nonatomic) BOOL forbidTouchToAdjustPosition;

@end

@implementation LTPageContentView

- (instancetype)initWithFrame:(CGRect)frame
                     childVCs:(NSArray *)childVCs
                     parentVC:(UIViewController *)parentVC
                 segmentStyle:(LTSegmentStyle *)segmentStyle
                     delegate:(id<LTScrollPageViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.parentVC = parentVC;
        self.childsVCs = childVCs;
        self.delegate = delegate;
        self.segmentStyle = segmentStyle;
        
        [self setupSubViews];
    }
    return self;
}

#pragma mark --setup
- (void)setupSubViews
{
    _startOffsetX = 0;
    _currentIndex = 0;
    _oldIndex = -1;
    _forbidTouchToAdjustPosition = NO;
    
    for (UIViewController *childVC in self.childsVCs) {
        [self.parentVC addChildViewController:childVC];
    }
    [self.collectionView reloadData];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childsVCs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    if (IOS_VERSION < 8.0) {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIViewController *childVC = self.childsVCs[indexPath.item];
        childVC.view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:childVC.view];
    }
    return cell;
}

#ifdef __IPHONE_8_0
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIViewController *childVc = self.childsVCs[indexPath.row];
    childVc.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:childVc.view];
}
#endif

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startOffsetX = scrollView.contentOffset.x;
    self.forbidTouchToAdjustPosition = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(LTContentViewWillBeginDragging:)]) {
        [self.delegate LTContentViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.forbidTouchToAdjustPosition || //点击标题切换
        scrollView.contentOffset.x <= 0 || // first or last
        scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width) {
        return;
    }
    CGFloat tempProgress = scrollView.contentOffset.x / self.bounds.size.width;
    NSInteger tempIndex = tempProgress;
    
    CGFloat progress = tempProgress - floor(tempProgress);
    CGFloat deltaX = scrollView.contentOffset.x - _startOffsetX;
    
    if (deltaX > 0) {// 向左
        if (progress == 0.0) {
            return;
        }
        self.currentIndex = tempIndex+1;
        self.oldIndex = tempIndex;
    }
    else if (deltaX < 0) {
        progress = 1.0 - progress;
        self.oldIndex = tempIndex+1;
        self.currentIndex = tempIndex;
        
    }
    else {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(LTContentViewDidScroll:oldIndex:currentIndex:progress:)]) {
        [self.delegate LTContentViewDidScroll:self oldIndex:_oldIndex currentIndex:_currentIndex progress:progress];
    }
}
/**
 *  滑动停止 已经结束减速时调用
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentIndex = (scrollView.contentOffset.x / self.bounds.size.width);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(LTContenViewDidEndDecelerating:oldIndex:currentIndex:)]) {
        [self.delegate LTContenViewDidEndDecelerating:self oldIndex:currentIndex currentIndex:currentIndex];
    }
}
/**
 *  滑动停止 手指离开屏幕之后不再滚动时调用
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSInteger currentIndex = (scrollView.contentOffset.x / self.bounds.size.width);
        if (self.delegate && [self.delegate respondsToSelector:@selector(LTContenViewDidEndDecelerating:oldIndex:currentIndex:)]) {
            [self.delegate LTContenViewDidEndDecelerating:self oldIndex:currentIndex currentIndex:currentIndex];
        }
    }
}

#pragma mark setter

- (void)adjustPageContentViewCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    if (currentIndex < 0||currentIndex >= self.childsVCs.count) {
        return;
    }
    self.forbidTouchToAdjustPosition = YES;
    self.currentIndex = currentIndex;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
}

#pragma mark --LazyLoad

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.bounces = self.segmentStyle.isContentViewBounces;
        collectionView.scrollEnabled = self.segmentStyle.isScrollContentView;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}


@end
