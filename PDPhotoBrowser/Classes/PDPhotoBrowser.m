//
//  PDPhotoBrowser.m
//  BeautifulBreastClub
//
//  Created by 潘东 on 2017/6/13.
//  Copyright © 2017年 BeautifulBreastClub. All rights reserved.
//

#import "PDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "PDBrowserImageView.h"
#import "PDSaveWithCancelBtn.h"
 
//  ============在这里方便配置样式相关设置===========

//                      ||
//                      ||
//                      ||
//                     \\//
//                      \/

#import "PDPhotoBrowserConfig.h"
#import "PDSaveWithCancelBtn.h"
//  =============================================

@implementation PDPhotoBrowser 
{
    UIScrollView *_scrollView;
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIActivityIndicatorView *_indicatorView;
    BOOL _willDisappear;
    PDSaveWithCancelBtn *_saveWithCancelView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = PDPhotoBrowserBackgrounColor;

         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    return self;
}


- (void)didMoveToSuperview
{
    [self setupScrollView];
    
    [self setupToolbars];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (void)setupToolbars
{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
    }else{
        indexLabel.hidden = YES;
    }
    _indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
    __weak typeof(self)weakSelf = self;
    _saveWithCancelView = [[PDSaveWithCancelBtn alloc]init];
    [_saveWithCancelView addTarget:self action:@selector(saveWithCancelViewClick) forControlEvents:UIControlEventTouchUpInside];
    _saveWithCancelView.saveWithBtnClickBlock = ^{
        [weakSelf saveImage];
    };
    [_saveWithCancelView isHidden:YES];
    [self addSubview:_saveWithCancelView];
    
}

- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = PDPhotoBrowserSaveImageFailText;
    }   else {
        label.text = PDPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        PDBrowserImageView *imageView = [[PDBrowserImageView alloc] init];
        imageView.tag = i;
        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        //长按
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPress:)];
        //拖动
//        UIPanGestureRecognizer *translation = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(translation:)];
        
    
        
    
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [imageView addGestureRecognizer:longPress];
//        [imageView addGestureRecognizer:translation];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    PDBrowserImageView *imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    if (imageView.hasLoadedImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        imageView.image = [self placeholderImageForIndex:index];
    }
    imageView.hasLoadedImage = YES;
}
#pragma mark - 事件处理

- (void)translation:(UIPanGestureRecognizer *)recognizer{

//    CGPoint translatedPoint = [recognizer translationInView:self];
//    CGFloat x = recognizer.view.center.x + translatedPoint.x;
//    CGFloat y = recognizer.view.center.y + translatedPoint.y;
//    recognizer.view.center = CGPointMake(x, y);
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
//    switch ([self commitTranslation:[recognizer velocityInView:self]]) {
//        case 0:
//            NSLog(@"上");
//            break;
//        case 1:
//            NSLog(@"左");
//            break;
//        case 2:
//            NSLog(@"下");
//            break;
//        case 3:
//            NSLog(@"右");
//            break;
//            
//        default:
//            break;
//    }
    
}
- (NSInteger)commitTranslation:(CGPoint)translation{
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    NSLog(@"%f---%f",absX,absY);
//    0 上  1左  2下  3右
    if (absX > absY ) {
        if (translation.x<0) {
            
            return 1;
        }else{
            return 3;
        }
        
    }else{
        if (translation.y<0) {
            return 0;
        }else{
            return 2;
        }
    }
    
    
}
- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    PDBrowserImageView *currentImageView = (PDBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    
    UIView *sourceView = nil;
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    }
    
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];

    
    [UIView animateWithDuration:PDPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        _indexLabel.alpha = 0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    PDBrowserImageView *imageView = (PDBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    PDBrowserImageView *view = (PDBrowserImageView *)recognizer.view;

    [view doubleTapToZommWithScale:scale];
}
- (void)imageViewLongPress:(UIPinchGestureRecognizer *)recognizer{
    [_saveWithCancelView isHidden:NO];
}
- (void)saveWithCancelViewClick{
    [_saveWithCancelView isHidden:YES];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += PDPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - PDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(PDBrowserImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = PDPhotoBrowserImageViewMargin + idx * (PDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
    
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
    
    _saveWithCancelView.frame = self.bounds;
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        PDBrowserImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[PDBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}

- (void)showFirstImage
{
    UIView *sourceView = nil;
    
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentImageIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    }
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    
    [UIView animateWithDuration:PDPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;

//    CGFloat margin = 150;
//    CGFloat x = scrollView.contentOffset.x;
//    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
//        PDBrowserImageView *imageView = _scrollView.subviews[index];
//        if (imageView.isScaled) {
//            [UIView animateWithDuration:0.5 animations:^{
//                imageView.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//                [imageView eliminateScale];
//            }];
//        }
//    }
    if (!_willDisappear) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    }
    [self setupImageOfImageViewForIndex:index];
}



@end
