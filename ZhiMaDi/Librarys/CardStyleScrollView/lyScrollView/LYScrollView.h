//
//  LYScrollView.h
//  Demo
//
//  Created by 志恒李-ly on 16/9/2.
//  Copyright © 2016年 志恒李. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LYScrollViewDelegate <NSObject>

- (void)scrolIndex:(NSInteger)index;

@end

@interface LYScrollView : UIView

@property (nonatomic, weak) id <LYScrollViewDelegate>delegate;

@property (nonatomic, strong) NSMutableArray * itmeArray;

@property (nonatomic, assign) BOOL isOpenDelete;//开启⬆️滑删除

@end
