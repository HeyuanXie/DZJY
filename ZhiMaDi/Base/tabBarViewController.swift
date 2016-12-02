//
//  tabBarViewController.swift
//  SleepCare
//
//  Created by haijie on 15/12/15.
//  Copyright © 2015年 juxi. All rights reserved.
//

import UIKit
// MARK: Tab 分组
private enum QNTabBarItem: Int {
    case Home = 0
    case Category = 1
    case School = 2
    case Mine = 3
    
    // 对应的图片名
    var imageName: String {
        switch self {
        case .Home: return "home"
        case .Category: return "category"
        case .School: return "shoppingCar"
        case .Mine: return "mine"
        }
    }
}

/// MARK: - 底部工具控制器
class tabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 修改底部工具条的字体和颜色
//        let titleSelectedColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        self.tabBar.translucent = false
//        self.tabBar.barTintColor = UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1.0)
//        self.tabBar.tintColor = UINavigationBar.appearance().tintColor
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(dictionary: [NSForegroundColorAttributeName: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1.0),NSFontAttributeName:UIFont.systemFontOfSize(11)]) as? [String : AnyObject], forState: .Normal)
        
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(dictionary: [NSForegroundColorAttributeName: /*defaultSelectColor*/UIColor(red: 54/255, green: 183/255, blue: 9/255, alpha: 1),NSFontAttributeName:UIFont.systemFontOfSize(11)]) as? [String : AnyObject], forState: .Selected)
        // 图标配置
        if let _ = self.tabBar.items {
            self.itemConfig(QNTabBarItem.Home)
            self.itemConfig(QNTabBarItem.Category)
//            self.itemConfig(QNTabBarItem.Add)
            self.itemConfig(QNTabBarItem.School)
            self.itemConfig(QNTabBarItem.Mine)
        }
        self.delegate = self
//        let tabBarView = UIView(frame: CGRect(x: 0, y: kScreenHeight-59, width: kScreenWidth, height: 59))
//        tabBarView.backgroundColor = UIColor.whiteColor()
//        let
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
//        if viewController != (self.viewControllers?.first)! as UIViewController && !g_isLogin! {/*未登录*/
//            ZMDTool.enterLoginViewController()
//            return false
//        }
//        if viewController == (self.viewControllers?.last)! as UIViewController && !g_isLogin! {/*未登录*/
//            ZMDTool.enterLoginViewController()
//            return false
//        }
        return true
    }
    //MARK:-Private Method
    /**
     配置Item
     
     :param: index     配置项
     :param: haveDot   是否需要小红点
     
     :returns: 被配置的Item
     */
    private func itemConfig(qnItem: QNTabBarItem, haveDot: Bool = false) -> UITabBarItem? {
        if let item = self.tabBar.items?[qnItem.rawValue]{
            let imageName = qnItem.imageName
            if let image = UIImage(named: "Tabbar_" + imageName + "_unselected"),
                let selectedImage = UIImage(named: "Tabbar_" + imageName + "_selected") {
                    if !haveDot {
                        item.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal) //不使用Tint Color
                        item.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    }
                    else {
                        item.image = self.imageAddDotView(image).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                        item.selectedImage = self.imageAddDotView(selectedImage).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    }
            }
            
            return item
        }
        return nil
    }
    private func imageAddDotView(image: UIImage) -> UIImage {
        let imageView = UIImageView(image: image)
        
        let dotView = UIView(frame: CGRect(x: imageView.bounds.width - 8, y: imageView.bounds.height - 8, width: 8, height: 8))
        dotView.layer.masksToBounds = true
        dotView.layer.cornerRadius = dotView.bounds.width/2.0
        dotView.backgroundColor = UIColor(red: 251/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1.0)
        imageView.addSubview(dotView)
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        imageView.layer.renderInContext(context!)
        let imageResult = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageResult
    }
    //可以隐藏首页
    func hideTabBar() {
        for v in self.view.subviews {
            if v is UITabBar {
                v.hidden = true
                break
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
