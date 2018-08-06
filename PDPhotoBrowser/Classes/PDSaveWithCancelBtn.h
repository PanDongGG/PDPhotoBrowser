//
//  BBCSaveWithCancelBtn.h
//  BeautifulBreastClub
//
//  Created by 潘东 on 2017/6/13.
//  Copyright © 2017年 BeautifulBreastClub. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^saveWithBtnClick)();
@interface PDSaveWithCancelBtn : UIButton
- (void)isHidden:(BOOL)hidden;
@property (nonatomic, copy) saveWithBtnClick saveWithBtnClickBlock;
@end
