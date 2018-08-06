//
//  PDPhotoBrowser.h
//  BeautifulBreastClub
//
//  Created by 潘东 on 2017/6/13.
//  Copyright © 2017年 BeautifulBreastClub. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PDPhotoBrowser;

@protocol PDPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(PDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(PDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

@end


@interface PDPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, weak) id<PDPhotoBrowserDelegate> delegate;

- (void)show;

@end
