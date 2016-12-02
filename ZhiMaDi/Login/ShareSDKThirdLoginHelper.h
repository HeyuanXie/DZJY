//
//  ShareSDKThirdLoginHelper.h
//  ZhiMaDi
//
//  Created by haijie on 16/7/4.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShareSDKThirdLoginHelperDelegate <NSObject>

-(void)loginWithName:(NSString*)nickName andPassWord:(NSString*)password andIcon:(NSString*)icon;


@end

@interface ShareSDKThirdLoginHelper : NSObject

@property(nonatomic,assign)id<ShareSDKThirdLoginHelperDelegate>delegate;


-(void)loginWithIndex:(NSInteger)index;

@end
