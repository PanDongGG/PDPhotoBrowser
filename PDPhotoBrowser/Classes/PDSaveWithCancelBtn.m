//
//  BBCSaveWithCancelBtn.m
//  BeautifulBreastClub
//
//  Created by 潘东 on 2017/6/13.
//  Copyright © 2017年 BeautifulBreastClub. All rights reserved.
//

#import "PDSaveWithCancelBtn.h"

@implementation PDSaveWithCancelBtn
{
    UIView *_buttomView;
    CGFloat _y;
    CGFloat _h;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        UIColor *btnHighlightedColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:.5];
        UIColor *btnNormalColor = [UIColor whiteColor];
        _y = [UIScreen mainScreen].bounds.size.height;
        _h = 110;
        
        
        _buttomView = [[UIView alloc]init];
//        _buttomView.backgroundColor = [UIColor redColor];
        
        _buttomView.frame = CGRectMake(0, _y, [UIScreen mainScreen].bounds.size.width, _h);
        [self addSubview:_buttomView];
        
        UIButton *saveBtn = [[UIButton alloc]init];
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setBackgroundImage:[self imageWithColor:btnNormalColor] forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(saveBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [saveBtn setBackgroundImage:[self imageWithColor:btnHighlightedColor] forState:UIControlStateHighlighted];
        [_buttomView addSubview:saveBtn];
        
        UIButton *cancelBtn = [[UIButton alloc]init];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[self imageWithColor:btnNormalColor] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[self imageWithColor:btnHighlightedColor] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_buttomView addSubview:cancelBtn];
        
        CGFloat btnH = (_h-5)/2;
        cancelBtn.frame = CGRectMake(0, _buttomView.frame.size.height-btnH, _buttomView.frame.size.width, btnH);
        saveBtn.frame = CGRectMake(0, 0, _buttomView.frame.size.width, btnH);
    }
    return self;
}
- (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)saveBtnBtnClick{
    if (self.saveWithBtnClickBlock) {
        self.saveWithBtnClickBlock();
    }
    [self isHidden:YES];
}
- (void)cancelBtnClick{
    [self isHidden:YES];
}
- (void)isHidden:(BOOL)hidden{
    if (!hidden) {
        self.hidden = hidden;
    }
    [UIView animateWithDuration:.2 animations:^{
        if (hidden) {
            _y = [UIScreen mainScreen].bounds.size.height;
            self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        }else{
            _y = [UIScreen mainScreen].bounds.size.height-_h;
            self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        }
        _buttomView.frame = CGRectMake(0, _y, [UIScreen mainScreen].bounds.size.width, _h);
    }completion:^(BOOL finished) {
        self.hidden = hidden;
    }];

}

@end
