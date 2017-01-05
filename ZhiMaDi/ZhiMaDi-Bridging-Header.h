//
//  SleepCare-Bridging-Header.h
//  SleepCare
//
//  Created by haijie on 15/12/15.
//  Copyright © 2015年 juxi. All rights reserved.
//

#ifndef SleepCare_Bridging_Header_h
#define SleepCare_Bridging_Header_h

#import "NSString+AES.h"                // AES 加密解密 相关需要
//BEGIN 网络图片加载库
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImageView+HighlightedWebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCacheOperation.h>

//#import <Reachability/Reachability.h>   // 判断网络状况
#import "Aspects.h"        // 拦截器
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Reachability.h"
//简单轮翻图
#import "CycleScrollView.h"
// 键盘遮挡解决方案
#import <IQKeyboardManager/IQKeyboardManager.h>
//友盟分享
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/WeiBoAPI.h>
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import "ShareSDKThirdLoginHelper.h"
//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"
// 极光推送
#import "BPush.h"
//下拉刷新
#import <MJRefresh/MJRefresh.h>
// 富文本控件
#import <CoreText/CoreText.h>
#import <TYAttributedLabel/TYAttributedLabel.h>
// 模型转换
#import "MJExtension.h"
// 第三方数据库框架
#import <FMDB/FMDB.h>

#import <CommonCrypto/CommonHMAC.h>
#import <AlipaySDK/AlipaySDK.h>

//信鸽推送
#import "XGPush.h"

//仿微信图片选择
#import "TZImagePickerController.h"

#import "HYTabBarController.h"
//卡片ScrollView
#import "PGIndexBannerSubiew.h"
#import "NewPagedFlowView.h"
#import "LYScrollView.h"

//用于左滑cell
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

//时间选择器
#import "HZQDatePickerView.h"
#import "AddressSelectViewController.h"

//网路数据请求本地缓存
#import "HYNetworkCache.h"

#endif /* SleepCare_Bridging_Header_h */