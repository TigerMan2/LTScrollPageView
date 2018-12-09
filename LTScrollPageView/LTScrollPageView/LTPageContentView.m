//
//  LTPageContentView.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTPageContentView.h"
#import "LTCollectionView.h"
#import "UIViewController+LTScrollPageController.h"

@interface LTPageContentView ()
<
    UIScrollViewDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
{
    CGFloat _oldOffSetX;
    BOOL _isLoadFirstView;
    NSInteger _sysVersion;
}
/** LTCollectionView */
@property (nonatomic, strong) LTCollectionView *collectionView;
/** collectionView 的布局 */
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
/** 父类 用于处理添加子控制器 使用weak避免循环引用 */
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, assign) NSInteger itemsCount;

/** 所有的子控制器 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIViewController *> *childVcsDic;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger oldIndex;
// 滚动超过页面(直接设置contentOffSet导致)
@property (assign, nonatomic) BOOL scrollOverOnePage;

@property (nonatomic, strong) LTSegmentStyle *segmentStyle;

@end

@implementation LTPageContentView
#define cellID @"cellID"

- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(LTSegmentStyle *)segmentStyle parentViewController:(UIViewController *)parentViewController delegate:(id<LTScrollPageViewDelegate>) delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentViewController = parentViewController;
        self.segmentStyle = segmentStyle;
        self.delegate = delegate;
        
        [self setupSubviews];
        [self addSubview:self.collectionView];
        
        [self addNotification];
    }
    return self;
}

- (void)setupSubviews {
    _oldIndex = -1;
    _currentIndex = 0;
    _oldOffSetX = 0.0f;
    _isLoadFirstView = YES;
    _sysVersion = [[[UIDevice currentDevice] systemVersion] integerValue];
    
    if ([_delegate respondsToSelector:@selector(numberOfChildViewControllers)]) {
        self.itemsCount = [_delegate numberOfChildViewControllers];
    } else {
        NSAssert(NO, @"必须实现的代理方法");
    }
    
    UINavigationController *navi = (UINavigationController *)self.parentViewController.parentViewController;
    if ([navi isKindOfClass:[UINavigationController class]]) {
        if (navi.viewControllers.count == 1) return;
        
        if (navi.interactivePopGestureRecognizer) {
            
            __weak typeof(self) weakSelf = self;
            [_collectionView setupScrollViewShouldBeginPanGestureHandler:^BOOL(LTCollectionView *collectionView, UIPanGestureRecognizer *panGesture) {
                
                CGFloat transionX = [panGesture translationInView:panGesture.view].x;
                if (collectionView.contentOffset.x == 0 && transionX > 0) {
                    navi.interactivePopGestureRecognizer.enabled = YES;
                }
                else {
                    navi.interactivePopGestureRecognizer.enabled = NO;
                    
                }
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(scrollPageController:contentScrollView:shouldBeginPanGesture:)]) {
                    return [weakSelf.delegate scrollPageController:weakSelf.parentViewController contentScrollView:collectionView shouldBeginPanGesture:panGesture];
                }
                else return YES;
            }];
        }
    }
    
}

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMemoryWarningHander:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)receiveMemoryWarningHander:(NSNotificationCenter *)noti {
    
    __weak typeof(self) weakSelf = self;
    [_childVcsDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<LTScrollPageViewDelegate> * _Nonnull childVc, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            if (childVc != strongSelf.currentChildVc) {
                [self->_childVcsDic removeObjectForKey:key];
                [LTPageContentView removeChildVc:childVc];
            }
        }
        
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.currentChildVc) {
        self.currentChildVc.view.frame = self.bounds;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if DEBUG
    NSLog(@"ZJContentView---销毁");
#endif
}

#pragma mark - public helper

/** 给外界可以设置ContentOffSet的方法 */
- (void)setContentOffSet:(CGPoint)offset animated:(BOOL)animated {
    NSInteger currentIndex = offset.x/self.collectionView.bounds.size.width;
    _oldIndex = _currentIndex;
    self.currentIndex = currentIndex;
    _scrollOverOnePage = NO;
    
    NSInteger page = labs(_currentIndex-_oldIndex);
    if (page>=2) {// 需要滚动两页以上的时候, 跳过中间页的动画
        _scrollOverOnePage = YES;
    }
    
    [self.collectionView setContentOffset:offset animated:animated];
    
}

/** 给外界刷新视图的方法 */
- (void)reload {
    
    [self.childVcsDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<LTScrollPageViewDelegate> * _Nonnull childVc, BOOL * _Nonnull stop) {
        [LTPageContentView removeChildVc:childVc];
        childVc = nil;
        
    }];
    self.childVcsDic = nil;
    [self setupSubviews];
    [self.collectionView reloadData];
    [self setContentOffSet:CGPointZero animated:NO];
    
}

+ (void)removeChildVc:(UIViewController *)childVc {
    [childVc willMoveToParentViewController:nil];
    [childVc.view removeFromSuperview];
    [childVc removeFromParentViewController];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (// 点击标题滚动
        scrollView.contentOffset.x <= 0 || // first or last
        scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width) {
        return;
    }
    CGFloat tempProgress = scrollView.contentOffset.x / self.bounds.size.width;
    NSInteger tempIndex = tempProgress;
    
    CGFloat progress = tempProgress - floor(tempProgress);
    CGFloat deltaX = scrollView.contentOffset.x - _oldOffSetX;
    
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
    //    NSLog(@"old ---- %ld current --- %ld", _oldIndex, _currentIndex);
    
    if ([_delegate respondsToSelector:@selector(contentViewDidMoveFromIndex:toIndex:progress:)]) {
        [_delegate contentViewDidMoveFromIndex:_oldIndex toIndex:_currentIndex progress:progress];
    }
    
}

/** 滚动减速完成时再更新title的位置 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = (scrollView.contentOffset.x / self.bounds.size.width);
    if ([_delegate respondsToSelector:@selector(contentViewDidMoveFromIndex:toIndex:progress:)]) {
        [_delegate contentViewDidMoveFromIndex:_oldIndex toIndex:_currentIndex progress:1.0];
    }
    
    // 调整title
    if ([_delegate respondsToSelector:@selector(adjustSegmentTitleOffsetToCurrentIndex:)]) {
        [_delegate adjustSegmentTitleOffsetToCurrentIndex:currentIndex];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _oldOffSetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    UINavigationController *navi = (UINavigationController *)self.parentViewController.parentViewController;
    if ([navi isKindOfClass:[UINavigationController class]] && navi.interactivePopGestureRecognizer) {
        navi.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - UICollectionViewDelegate --- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    // 移除subviews 避免重用内容显示错误
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (_sysVersion < 8) {
        [self setupChildVcForCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}


- (void)setupChildVcForCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (_currentIndex != indexPath.row) {
        return; // 跳过中间的多页
    }
    
    _currentChildVc = [self.childVcsDic valueForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    
    if (_delegate && [_delegate respondsToSelector:@selector(childViewController:forIndex:)]) {
        if (_currentChildVc == nil) {
            _currentChildVc = [_delegate childViewController:nil forIndex:indexPath.row];
            // 设置当前下标
            _currentChildVc.lt_currentIndex = indexPath.row;
            [self.childVcsDic setValue:_currentChildVc forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        } else {
            [_delegate childViewController:_currentChildVc forIndex:indexPath.row];
        }
    } else {
        NSAssert(NO, @"必须设置代理和实现代理方法");
    }
    // 这里建立子控制器和父控制器的关系
    if ([_currentChildVc isKindOfClass:[UINavigationController class]]) {
        NSAssert(NO, @"不要添加UINavigationController包装后的子控制器");
    }
    if (_currentChildVc.lt_scrollViewController != self.parentViewController) {
        [self.parentViewController addChildViewController:_currentChildVc];
    }
    _currentChildVc.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:_currentChildVc.view];
    [_currentChildVc didMoveToParentViewController:self.parentViewController];
    
    
}

#pragma mark - getter

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        if ([_delegate respondsToSelector:@selector(adjustSegmentTitleOffsetToCurrentIndex:)]) {
            [_delegate adjustSegmentTitleOffsetToCurrentIndex:currentIndex];
        }
        
    }
}

- (LTCollectionView *)collectionView {
    if (!_collectionView) {
        LTCollectionView *collectionView = [[LTCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        [collectionView setBackgroundColor:[UIColor yellowColor]];
        collectionView.pagingEnabled = YES;
        collectionView.scrollsToTop = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.bounces = YES;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
        collectionView.bounces = self.segmentStyle.isContentViewBounces;
        collectionView.scrollEnabled = self.segmentStyle.isScrollContentView;
        [self addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0.0;
        flowLayout.minimumInteritemSpacing = 0.0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout = flowLayout;
    }
    return _flowLayout;
}

- (NSMutableDictionary<NSString *,UIViewController *> *)childVcsDic {
    if (!_childVcsDic) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        _childVcsDic = dic;
    }
    return _childVcsDic;
}

@end
