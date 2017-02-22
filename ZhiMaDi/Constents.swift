//
//  Constents.swift
//  TestSwify
//
//  Created by LiuYu on 14/10/31.
//  Copyright (c) 2014年 Liuyu. All rights reserved.
//

import UIKit

// MARK: - Path
/// Caches 目录
let PATH_CACHES = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
/// Documents 目录
let PATH_DOCUMENTS = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.UserDomainMask, true).first

// MARK: - Application information
/// App ID (必须与 iTunes Connect 上设置的一致)
let APP_ID = "1182284278" //当前App(农批)的ID
let APP_ID_NT = "1164015233"          //农特App的ID
let APP_ID_NZ = "1182283898"          //农资App的ID
/// App SKU码 (必须与 iTunes Connect 上设置的一致)
let APP_SKU = "com.qoocc.QooccHealth"
/// App Bundle Id
let APP_BUNDLE_ID = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
/// App 名称
let APP_NAME = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! String
/// App 版本号
let APP_VERSION = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
/// App 编译版本号
let APP_VERSION_BUILD = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
/// APP 下载地址前缀
let APP_URL_IN_ITUNES_PREFIX = "https://itunes.apple.com/cn/app/id%@?ls=1&mt=8"
/// APP 下载地址（在iTunes中）
let APP_URL_IN_ITUNES = String(format: APP_URL_IN_ITUNES_PREFIX, APP_ID)

// MARK: - CheckUpdate
/// APP 首页进入DidAppear方法的次数
var APP_LAUNCHEDTIME = 0
/// APP 详细信息地址
let APP_URL_DETAIL = "http://itunes.apple.com/cn/lookup?id=\(APP_ID)"

// MARK: - XGPush
/// 信鸽推送注册的设备Token
var XG_DeviceToken : NSData?
/// 信鸽推送AccessId
let XG_AccessId = "2200241980"
/// 信鸽推送AccessKey
let XG_AccessKey = "IT5A2WNM296F"

// MARK: - System
/// 系统名称
let SYSTEM_NAME: String = UIDevice.currentDevice().systemName
/// 系统版本号 （字符串）
let SYSTEM_VERSION: String = UIDevice.currentDevice().systemVersion
/// 系统版本号 （浮点数）
let SYSTEM_VERSION_FLOAT: Float = (SYSTEM_VERSION as NSString).floatValue
/// APPDelegate
let APP_DELEGATE = UIApplication.sharedApplication().delegate as! AppDelegate

// MARK: - 屏幕高度 & 屏幕宽度 & 放大系数
/// 屏幕高度
let kScreenHeight = UIScreen.mainScreen().bounds.size.height
/// 屏幕宽度
let kScreenWidth = UIScreen.mainScreen().bounds.size.width
/// 屏幕高度放大系数（相对于iPhone5/5S的屏幕）
let kScreenHeightZoom = kScreenHeight/568.0
/// 屏幕宽度放大系数（相对于iPhone5/5S的屏幕）
let kScreenWidthZoom = kScreenWidth/320.0
/// 相对于6的放大系数
let kScreenWidthZoom6 = kScreenWidth/375.0
let kScreenHeightZoom6 = kScreenHeight/667.0
/// 快速转换相对6/6s的尺寸
func zoom(value:CGFloat)->CGFloat {
    return value*kScreenWidth/375.0
}

// MARK: - NSUserDefaults.standardUserDefaults() 相关
/// 从 NSUserDefaults.standardUserDefaults() 中获取数据
func getObjectFromUserDefaults(key: String) -> AnyObject? {
    return NSUserDefaults.standardUserDefaults().objectForKey(key)
}
/// 保存 obj 到 NSUserDefaults.standardUserDefaults() 中
func saveObjectToUserDefaults(key: String, value: AnyObject) {
    NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
    NSUserDefaults.standardUserDefaults().synchronize()
}
/// 从 NSUserDefaults.standardUserDefaults() 中移除数据
func removeObjectAtUserDefaults(key: String) {
    NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    NSUserDefaults.standardUserDefaults().synchronize()
}

// MARK: - 一些公有的函数
/// 获取最顶层的ViewController
func topViewController() -> UIViewController? {
    var resultViewController: UIViewController? = nil
    // 多window的情况下， 需要对window进行有效选择选择
    if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
        resultViewController = __topViewController(rootViewController)
        while resultViewController?.presentedViewController != nil {
            resultViewController = resultViewController?.presentedViewController
        }
    }
    return resultViewController
}

private func __topViewController(object: AnyObject!) -> UIViewController? {
    if let navigationController = object as? UINavigationController {
        return __topViewController(navigationController.viewControllers.last)
    }
    else if let tabBarController = object as? UITabBarController {
        if tabBarController.selectedIndex < tabBarController.viewControllers?.count {
            return __topViewController(tabBarController.viewControllers![tabBarController.selectedIndex])
        }
    }
    else if let vc = object as? UIViewController {
        return vc
    }

    return nil
}

/// 版本比较(无法进行比较会返回nil)（version为本地版本）
func compareVersion(version1: String, version2: String) -> NSComparisonResult? {
    let version1Array = version1.componentsSeparatedByString(".")
    let version2Array = version2.componentsSeparatedByString(".")
    
    let iCount = min(version1Array.count, version2Array.count)
    if iCount == 0 {
        return nil  // 无法进行比较 version的格式错误
    }
    
    for index in 0..<iCount {
        let iVersion1Sub = (Int)(version1Array[index])
        let iVersion2Sub = (Int)(version2Array[index])
        if iVersion1Sub != nil && iVersion2Sub != nil {
            if iVersion1Sub == iVersion2Sub {
                continue // 相同，则去判断下一个位置
            }
            else if iVersion1Sub > iVersion2Sub {
                return NSComparisonResult.OrderedDescending     //基本不会有这种情况
            }
            else {
                return NSComparisonResult.OrderedAscending
                //本地比appStore小
            }
        }
        else { // 无法进行比较 version的格式错误
            return nil
        }
    }
    
    if version1Array.count == version2Array.count {
        return NSComparisonResult.OrderedSame
    }
    else if version1Array.count > version2Array.count {
        return NSComparisonResult.OrderedDescending
    }
    else {
        return NSComparisonResult.OrderedAscending
    }
}

// MARK: - 在 Relase 模式下，关闭后台打印
#if DEBUG
    func print(object: Any) {}
    func NSLog(format: String, args: CVarArgType...) {}
    #else
#endif

