//
//  QNSharedDatas.swift
//  QooccShow
//
//  Created by LiuYu on 14/10/31.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

/** 此文件中放置整个App共享的数据 */

import UIKit

//富文本   ￥ ×
/// 加密解密密钥
let g_SecretKey = "qoocc"

/// 是否登录
var g_isLogin: Bool! { return g_customerId != nil }
/// 当前账号
var g_customerId : Int? // 408
var g_customer : ZMDCustomer?
// MARK: - 账号 & 账号管理
private let kKeyAccount = ("Account" as NSString).encrypt(g_SecretKey)
/// 账号（登录成功的）
var g_Account: String? {
    return (getObjectFromUserDefaults(kKeyAccount) as? NSString)?.decrypt(g_SecretKey)
}
/// 测试帐号
var g_AccountTest: String?
private let kKeyPassword = ("Password" as NSString).encrypt(g_SecretKey)
/// 密码（登录成功的）
var g_Password: String? {
    return (getObjectFromUserDefaults(kKeyPassword) as? NSString)?.decrypt(g_SecretKey)
}
/// 保存账号和密码
func saveAccountAndPassword(account: String, password: String?) {
    saveObjectToUserDefaults(kKeyAccount, value: (account as NSString).encrypt(g_SecretKey))
    if password == nil {
        cleanPassword()
    }
    else {
        saveObjectToUserDefaults(kKeyPassword, value: (password! as NSString).encrypt(g_SecretKey))
    }
}
/// 清除密码
func cleanPassword() {
    removeObjectAtUserDefaults(kKeyPassword)
}
func cleanAccount(){
    removeObjectAtUserDefaults(kKeyAccount)
}

func hideHYTabBar(hidden: Bool, animated: Bool, viewController: UIViewController?) {
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    if viewController != nil {
        viewController!.hidesBottomBarWhenPushed = true
    }
    app.tabBar.hyTabBarHidden(hidden, animated: animated)
}

