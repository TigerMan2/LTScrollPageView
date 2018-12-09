//
//  LTTitleView.m
//  LTScrollPageView
//
//  Created by wangpeng on 2018/12/6.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTTitleView.h"
#import "UIView+LTFrame.h"
@interface LTTitleView ()
{
    BOOL _isShowImage;
    CGSize _titleSize;
    CGFloat _imageWidth;
    CGFloat _imageHeight;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation LTTitleView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _isShowImage = NO;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_isShowImage) {
        self.label.frame = self.bounds;
    }
}

- (void)adjustSubviewFrame {
    _isShowImage = YES;
    
    self.contentView.frame = self.bounds;
    self.contentView.lt_width = [self titleViewWidth];
    self.contentView.lt_x = (self.lt_width - self.contentView.lt_width) * 0.5;
    self.label.frame = self.contentView.bounds;
    
    [self addSubview:self.contentView];
    [self.label removeFromSuperview];
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.imageView];
    
    switch (self.imagePosition) {
        case TitleImagePositionTop:
        {
            /** 设置contentFrame */
            self.contentView.lt_height = _imageHeight + _titleSize.height;
            self.contentView.lt_y = (self.contentView.lt_height - self.contentView.lt_height) * 0.5;
            
            /** 设置imageViewFrame */
            self.imageView.frame = CGRectMake(0, 0, _imageWidth, _imageHeight);
            self.imageView.lt_centerX = self.label.lt_centerX;
            
            /** 设置LabelFrame */
            self.label.lt_y = _imageHeight;
            self.label.lt_height = _titleSize.height;
        }
            break;
        case TitleImagePositionLeft:
        {
            /** 设置LabelFrame */
            self.label.lt_x = _imageWidth;
            self.label.lt_width = _titleSize.width;
            
            /** 设置imageViewFrame */
            self.imageView.frame = CGRectMake(0, 0, _imageWidth, _imageHeight);
            self.imageView.lt_y = (self.contentView.lt_height - _imageHeight) * 0.5;
        }
            break;
        case TitleImagePositionRight:
        {
            /** 设置LabelFrame */
            self.label.lt_width = _titleSize.width;
            
            /** 设置imageViewFrame */
            self.imageView.frame = CGRectMake(0, 0, _imageWidth, _imageHeight);
            self.imageView.lt_y = (self.contentView.lt_height - _imageHeight) * 0.5;
            self.imageView.lt_x = _titleSize.width;
        }
            break;
        case TitleImagePositionCenter:
        {
            /** 设置imageFrame */
            self.imageView.frame = self.contentView.bounds;
            /** 移除label */
            [self.label removeFromSuperview];
        }
            break;
            
        default:
            break;
    }
    
}

- (CGFloat)titleViewWidth {
    CGFloat width = 0.0f;
    switch (self.imagePosition) {
        case TitleImagePositionLeft:
        case TitleImagePositionRight:
            width = _titleSize.width + _imageWidth;
            break;
        case TitleImagePositionCenter:
            width = _imageWidth;
            break;
            
        default:
            width = _titleSize.width;
            break;
    }
    return width;
}

#pragma mark -----setter------
- (void)setCurrentTransformSx:(CGFloat)currentTransformSx {
    _currentTransformSx = currentTransformSx;
    self.transform = CGAffineTransformMakeScale(currentTransformSx, currentTransformSx);
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    _imageWidth = normalImage.size.width;
    _imageHeight = normalImage.size.height;
    self.imageView.image = normalImage;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    self.imageView.highlightedImage = selectedImage;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = text;
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.label.font} context:nil];
    _titleSize = bounds.size;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label.textColor = textColor;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.label.font = font;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.imageView.highlighted = selected;
}

#pragma mark -----basic attribute------
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

@end
