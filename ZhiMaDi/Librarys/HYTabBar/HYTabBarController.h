//
//  HYTabBarController.h
//  HYTabBar
//
//  Created by 任长平 on 15/12/18.
//  Copyright © 2015年 任长平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CenterBtnClick)();
typedef void(^Block)(int a);

@protocol HYTabBarControllerDelegate <NSObject>

@optional
-(void)xm_selectedViewController:(UIViewController *)viewController;
@end



@interface HYTabBarController : UITabBarController


@property (nonatomic, assign) NSInteger selectedItem;

/** 是否显示中间按钮，默认为NO */
@property (nonatomic, assign) BOOL showCenterItem;

/** 中间按钮 */
@property(nonatomic, strong) UIButton* centerItem;

/** 中间按钮的图片 */
@property (nonatomic, strong) UIImage * centerItemImage;

/** 中间按钮控制的试图控制器 */
@property (nonatomic, strong) UIViewController * xm_centerViewController;

/** 文字颜色 */
@property (nonatomic, strong) UIColor * textColor;

@property (nonatomic, weak) id<HYTabBarControllerDelegate>XMDelegate;

/** 点击centerBtn调用的block */
@property (nonatomic, copy) CenterBtnClick centerBtnClickBlock;

/**
 *  指定item设置badgeValue
 */
-(void)tabBarBadgeValue:(NSUInteger)value item:(NSInteger)index;

/**
 *  隐藏或显示TabBar
 */
-(void)hyTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 *  隐藏或显示中间试图控制器
 */
-(void)showCenterViewController:(BOOL)show animated:(BOOL)animated;

- (id)initWithTabBarSelectedImages:(NSMutableArray *)selected
                      normalImages:(NSMutableArray *)normal
                            titles:(NSMutableArray *)titles;


+(HYTabBarController*)shareInstance;




@end




@interface XMButton : UIButton

@property (nonatomic, assign) NSUInteger badgeValue;
+ (instancetype)xm_shareButton;

@end







