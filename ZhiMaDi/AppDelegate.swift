//
//  AppDelegate.swift
//  ZhiMaDi
//
//  Created by caichong on 16/2/19.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
/// 第一次启动判断的Key
let kKeyIsFirstStartApp = ("IsFirstStartApp" as NSString).encrypt(g_SecretKey)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var images = NSMutableArray()
    var selectImages = NSMutableArray()
    var titles = NSMutableArray()
    var tabBar : HYTabBarController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        self.customTabBar()
        
        print("\n<\(APP_NAME)> 开始运行\nversion: \(APP_VERSION)(\(APP_VERSION_BUILD))\nApple ID: \(APP_ID)\nBundle ID: \(APP_BUNDLE_ID)\n")
        // 修改统一的字体
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : navigationTextFont], forState: .Normal)
        //配置分享
        ZMDShareSDKTool.startShare()
        
        self.configXGPush(launchOptions)
        
        // 开启推送服务
        ZMDPushTool.startPushTool(launchOptions)
        ZMDPushTool.clear()
        // 启动过渡页
//        let allowShowStartPages = !NSUserDefaults.standardUserDefaults().boolForKey(kKeyIsFirstStartApp)
//        if allowShowStartPages {
//            UIApplication.sharedApplication().statusBarHidden = true
//            let startPages = StartPagesWindow()
//            startPages.finished = { () -> Void in
//                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kKeyIsFirstStartApp)
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
//                ZMDTool.enterRootViewController(vc)
//            }
//            window = UIWindow(frame: UIScreen.mainScreen().bounds)
//            window?.rootViewController = startPages
//            window?.makeKeyAndVisible()
//        }
        
        if let account = g_Account {
            if let password = g_Password {
                QNNetworkTool.loginAjax(account, Password: password, completion: { (success, error, dictionary) -> Void in
                    if success! {
                        
                    }else{
                        
                    }
                })
            }
        }
        
        // 开启拦截器
        ZMDInterceptor.start()
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        ZMDPushTool.clear()
        XGPush.clearLocalNotifications()
    }

   
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        BPush.registerDeviceToken(deviceToken)
        BPush.bindChannelWithCompleteHandler { (result, error) -> Void in
            //回调中看获得channnelid appid userid
        }
        
        XGPush.setAccount("JNNTAccount")    // 要在注册设备前调用,更改account要重新注册设备
        
        XG_DeviceToken = deviceToken
        let deviceTokenStr = XGPush.registerDevice(XG_DeviceToken, successCallback: { () -> Void in
            print("XGPush-registerDevice-succeed")
            }) { () -> Void in
                print("XGPush-registerDevice-failed")
        }
        print("deviceTokenStr:\(deviceTokenStr)")
    }
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        BPush.handleNotification(userInfo)
        if (application.applicationState == UIApplicationState.Active || application.applicationState == UIApplicationState.Background) {
            ZMDTool.showPromptView("你有新的消息,请注意查收")
        }
        else//跳转到跳转页面。
        {
           
        }
        XGPush.handleReceiveNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.NewData)
        if (application.applicationState == UIApplicationState.Active || application.applicationState == UIApplicationState.Background) {
            ZMDTool.showPromptView("收到一条消息")
        }
        else//跳转到跳转页面。
        {
            
        }
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("DeviceToken 获取失败，原因：\(error)")
    }
    //客户端支付
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.host == "safepay" {
            //跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (resultDic) -> Void in
                
            })
        }
        return true
    }
    // @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if url.host == "safepay" {
            //跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (resultDic) -> Void in
                
            })
        }
        return true
    }
    
    
    //MARK: - 自定义TabBar
    func customTabBar() {
        let array = ["home","list","cart","mine"]
        let array2 = ["首页","分类","购物车","我的"]
        var count = 0
        for item in array {
            let unSelectedStr = "tab bar_"+item+"01"
            let selectedStr = "tab bar_"+item+"02"
            let unSelectedImage = UIImage(named: unSelectedStr)
            let selectedImage = UIImage(named: selectedStr)
            images.addObject(unSelectedImage!)
            selectImages.addObject(selectedImage!)
            titles.addObject(array2[count++])
        }
        self.tabBar = HYTabBarController(tabBarSelectedImages: selectImages, normalImages: images, titles: titles)
        let vc1 = HomePageViewController.CreateFromMainStoryboard() as! HomePageViewController
        let vc2 = SortViewController2()
        let vc3 = ShoppingCartViewController.CreateFromMainStoryboard() as! ShoppingCartViewController
        let vc4 = MineHomeViewController.CreateFromMainStoryboard() as! MineHomeViewController
        let nvc1 = UINavigationController(rootViewController: vc1)
        let nvc2 = UINavigationController(rootViewController: vc2)
        let nvc3 = UINavigationController(rootViewController: vc3)
        let nvc4 = UINavigationController(rootViewController: vc4)
        tabBar.viewControllers = [nvc1,nvc2,nvc3,nvc4]
        tabBar.showCenterItem = true
        tabBar.centerItemImage = UIImage(named: "btn_release")
        tabBar.centerBtnClickBlock = {() -> Void in
            let view = UIView(frame: UIScreen.mainScreen().bounds)
            view.backgroundColor = UIColor.whiteColor()
            view.alpha = 1.0
//            view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
            let zoom = kScreenWidth/375.0
            let width = 80*zoom
            let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: width))
            let point = CGPoint(x: kScreenWidth/2, y: kScreenHeight-40*zoom)
            cancelBtn.center = point
            cancelBtn.setImage(UIImage(named: "publish_close"), forState: .Normal)
            cancelBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            cancelBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                view.removePop()
                return RACSignal.empty()
            })
            view.addSubview(cancelBtn)
            
            let titles = ["发布供应","发布求购"]
            let images = ["fabu_gy","fabu_qg"]
            let titles2 = ["好货源,生意滚滚来!","坐等商机到碗里来!"]
            let btnPadding = (kScreenWidth - 2*(40+80)*zoom)
            for i in 0..<2 {
                let btn = ZMDTool.getButton(CGRect(x: 50*zoom+CGFloat(i)*(80*zoom+btnPadding), y: kScreenHeight-230*zoom, width: 80*zoom, height: 80*zoom), textForNormal: "", fontSize: 15, textColorForNormal: defaultTextColor, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                    let rootVc = (self.tabBar.viewControllers?[self.tabBar.selectedIndex] as! UINavigationController).viewControllers.first
                    if !g_isLogin {
                        view.removePop()
                        self.showLoginAlert(rootVc!)
                        return
                    }
                    view.removePop()
                    let vc = PublishSupplyViewController.CreateFromMainStoryboard() as! PublishSupplyViewController
                    vc.contentType = i == 0 ? .Supply : .Demand
                    rootVc?.pushToViewController(vc, animated: true, hideBottom: true)
                })
                btn.setImage(UIImage(named: images[i]), forState: .Normal)

                let labelBot = ZMDTool.getLabel(CGRect(x: CGFloat(i)*kScreenWidth/2, y: kScreenHeight-120*zoom, width: kScreenWidth/2, height: 20*zoom), text: titles2[i], fontSize: 12, textColor: defaultDetailTextColor, textAlignment: NSTextAlignment.Center)
                let labelTop = ZMDTool.getLabel(CGRect(x: CGFloat(i)*kScreenWidth/2, y: kScreenHeight-145*zoom, width: kScreenWidth/2, height: 20), text: titles[i], fontSize: 13, textColor: defaultTextColor, textAlignment: .Center)
                view.addSubview(btn)
                view.addSubview(labelBot)
                view.addSubview(labelTop)
                btn.set("cx", value: labelTop.center.x)
            }
            
            view.showAsPop(setBgColor: false)
        }
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.rootViewController = tabBar
        self.window?.makeKeyAndVisible()
    }
    
    //MAKR: - 没有登陆Alert
    func showLoginAlert(rootVC:UIViewController) {
        let alert = UIAlertController(title: "未登录!", message: "登陆才能发布,是否立即登陆?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Destructive, handler: { (alert) -> Void in
            let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
            rootVC.pushToViewController(vc, animated: true, hideBottom: true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - 初始化信鸽推送
    func configXGPush(launchOptions: [NSObject: AnyObject]?) {
        self.registerPushForIOS8()
        XGPush.startApp(UInt32((XG_AccessId as NSString).integerValue) , appKey: XG_AccessKey)
        let successCallBack = {()
            //如果变成需要注册状态
            /*if !XGPush.isUnRegisterStatus() {
            if __IPHONE_OS_VERSION_MAX_ALLOWED >= 8 {
            if (UIDevice.currentDevice().systemVersion.compare("8", options:.NumericSearch) != NSComparisonResult.OrderedAscending) {
            self.registerPushForIOS8()
            } else {
            self.registerPush()
            }
            }
            }*/
        }
        
        XGPush.initForReregister(successCallBack)
        XGPush.handleLaunching(launchOptions, successCallback: {
            print("[XGPush]--没运行-handleLaunching's successBlock/n/n")
            }) {
                print("[XGPush]--没运行-handleLaunching's errorBlock/n/n")
        }
    }
    
    func registerPushForIOS8() {
        //Types
        let types = UIUserNotificationType.Sound //| UIUserNotificationType.Alert | UIUserNotificationType.Badge
        
        //Actions
        let acceptAction = UIMutableUserNotificationAction()
        
        acceptAction.identifier = "ACCEPT_IDENTIFIER"
        acceptAction.title = "Accept"
        
        acceptAction.activationMode = UIUserNotificationActivationMode.Foreground
        
        acceptAction.destructive = false
        acceptAction.authenticationRequired = false
        
        
        //Categories
        let inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.identifier = "INVITE_CATEGORY";
        
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Default)
        inviteCategory.setActions([acceptAction], forContext: UIUserNotificationActionContext.Minimal)
        
        //let categories = NSSet(objects: inviteCategory)
        let categories = Set(arrayLiteral: inviteCategory)
        
        let mySettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: categories)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func registerPush(){
        UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound)
    }
    
    func configPushNotification(launchOptions:[NSObject:AnyObject]?) {
        guard let launchOptions = launchOptions else {
            return
        }
        let tabBarVC = self.window?.rootViewController as! UITabBarController
        tabBarVC.selectedIndex = 3
    }
}

