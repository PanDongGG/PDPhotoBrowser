//
//  PDBrowserImageView.m
//  BeautifulBreastClub
//
//  Created by 潘东 on 2017/6/13.
//  Copyright © 2017年 BeautifulBreastClub. All rights reserved.
//


typedef enum {
    PDWaitingViewModeLoopDiagram, // 环形
    PDWaitingViewModePieDiagram // 饼型
} PDWaitingViewMode;

// 图片保存成功提示文字
#define PDPhotoBrowserSaveImageSuccessText @" ^_^ 保存成功 ";

// 图片保存失败提示文字
#define PDPhotoBrowserSaveImageFailText @" >_< 保存失败 ";

// browser背景颜色
#define PDPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// browser中图片间的margin
#define PDPhotoBrowserImageViewMargin 10

// browser中显示图片动画时长
#define PDPhotoBrowserShowImageAnimationDuration 0.4f

// browser中显示图片动画时长
#define PDPhotoBrowserHideImageAnimationDuration 0.4f

// 图片下载进度指示进度显示样式（PDWaitingViewModeLoopDiagram 环形，PDWaitingViewModePieDiagram 饼型）
#define PDWaitingViewProgressMode PDWaitingViewModeLoopDiagram

// 图片下载进度指示器背景色
#define PDWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

// 图片下载进度指示器内部控件间的间距
#define PDWaitingViewItemMargin 10


