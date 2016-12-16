//
//  UIViewControllerExtension.swift
//  QooccShow
//
//  Created by LiuYu on 14/11/3.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

import UIKit

//MARK:- 为 UIViewController ... 扩展一个公有的从storyboard构建的方法
extension UIViewController {
    //MARK: 从 Main.storyboard 初始化一个当前类
    // 从 Main.storyboard 中创建一个使用了当前类作为 StoryboardID 的类
    public class func CreateFromMainStoryboard() ->  AnyObject! {
        return self.CreateFromStoryboard("Main")
    }
    public class func CreateFromLoginStoryboard() ->  AnyObject! {
        return self.CreateFromStoryboard("Login")
    }
    public class func CreateFromStoreStoryboard() ->  AnyObject! {
        return self.CreateFromStoryboard("Store")
    }

    //MARK: 从 storyboardName.storyboard 初始化一个当前类
    // 从 storyboardName.storyboard 中创建一个使用了当前类作为 StoryboardID 的类
    public class func CreateFromStoryboard(name: String) -> AnyObject! {
        let classFullName = NSStringFromClass(self.classForCoder())
        let className = classFullName.componentsSeparatedByString(".").last as String! 
        let mainStoryboard = UIStoryboard(name: name, bundle:nil)
        return mainStoryboard.instantiateViewControllerWithIdentifier(className)
    }
    
    
}

//MARK:- 为 UIViewController ... 扩展一个 返回功能
extension UIViewController {
    @IBAction func back() {
        if let navigationController = self.navigationController where (navigationController.viewControllers.first) != self {
            navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    @IBAction func gotoMsg() {
        if let navigationController = self.navigationController where (navigationController.viewControllers.first) != self {
                navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    @IBAction func gotoMore() {
        if let navigationController = self.navigationController where (navigationController.viewControllers.first) != self {
            navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }
    }
    @IBAction func customFooterRefresh() {
        
    }
}

//MARK:- 为 UIViewController ... 提供一个标准的导航栏返回按钮配置
extension UIViewController {
    public func configBackButton() {
        let item = UIBarButtonItem(image: UIImage(named: "Navigation_Back")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: self, action: Selector("back"))
        item.customView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.leftBarButtonItem = item
    }
    public func configMsgButton() {
        let item = UIBarButtonItem(image: UIImage(named: "Navi_Msg")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: self, action: Selector("back"))
        item.customView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
    public func configMoreButton() {
        let item = UIBarButtonItem(image: UIImage(named: "common_more")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: self, action: Selector("gotoMore"))
        item.customView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
}

//MARK: 为UIViewController 提供一个alertView弹出
//如果haveCancleBtn==false,则只需要用确定作为cancleBtn，并且不做任何操作a
extension UIViewController {
    public func commonAlertShow(haveCancleBtn:Bool,btnTitle1: String = "确定",btnTitle2: String = "取消", title: String, message: String, preferredStyle: UIAlertControllerStyle){
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if haveCancleBtn {
            let action1 = UIAlertAction(title: btnTitle1, style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                self.alertDestructiveAction()
            })
            let action2 = UIAlertAction(title: btnTitle2, style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
        }else{
            let action = UIAlertAction(title: btnTitle1, style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                self.alertCancelAction()
            })
            alert.addAction(action)
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //点击commonAlert确定按钮执行的方法
    public func alertDestructiveAction() {
        print("alert确定")
    }
    public func alertCancelAction() {
        print("alert取消")
    }
}

//MARK: 导航控制器Push
extension UIViewController {
    public func pushToViewController(vc:UIViewController,animated:Bool,hideBottom:Bool){
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}

//MARK: 经常出现的UI
extension UIViewController {
    func addBottomBtn(title:String = "保存",color:UIColor = appThemeColor, blockForCli : ((AnyObject!) -> Void)!) {
        let bgViewTag = 66666
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 50))
        bgView.backgroundColor = appThemeColor
        bgView.tag = bgViewTag
        self.view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(50)
        }
        
        let saveBtn = ZMDTool.getButton(CGRect.zero, textForNormal: title, fontSize: 16, textColorForNormal: UIColor.whiteColor(), backgroundColor: appThemeColor,blockForCli: blockForCli)
        bgView.addSubview(saveBtn)
        saveBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        }
    }

    func addBottomBtns(titles:[String] = ["保存"],colors:[UIColor] = [appThemeColor]) {
        let bgViewTag = 66666
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 50))
        bgView.backgroundColor = appThemeColor
        bgView.tag = bgViewTag
        self.view.addSubview(bgView)
        bgView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(50)
        }
        
        let width = kScreenWidth/CGFloat(titles.count)
        for i in 0..<titles.count {
            let title = titles[i]
            let saveBtn = ZMDTool.getButton(CGRect.zero, textForNormal: title, fontSize: 16, textColorForNormal: UIColor.whiteColor(), backgroundColor: colors[i],blockForCli: nil)
            bgView.addSubview(saveBtn)
            saveBtn.tag = 1000+i
            saveBtn.snp_makeConstraints { (make) -> Void in
                make.left.equalTo(CGFloat(i)*width)
                make.width.equalTo(width)
                make.bottom.equalTo(0)
                make.height.equalTo(50)
            }
        }
    }
    
    
    //下拉筛选Btn
    func addSelectBtn(titles:[String],frame:CGRect,selectViewBgColor:UIColor) -> UIButton {
        let btn = ZMDTool.getButton(frame, textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) in
            let downBtn = sender as! UIButton     //downBtn
            downBtn.selected = !downBtn.selected
            let selectView = UIView(frame: CGRect(x: zoom(65), y: 64, width: zoom(80), height: 3*zoom(36)))
            selectView.backgroundColor = selectViewBgColor
            selectView.alpha = 1.0
            ZMDTool.configViewLayer(selectView)
            var i = -1
            for title in titles {
                i = i + 1
                let btn = UIButton(frame: CGRect(x: 0, y: 36*CGFloat(i)*kScreenWidth/375, width: 80*kScreenWidth/375, height: 36*kScreenWidth/375))
                btn.tag = 1000+i
                btn.setTitle(title, forState: .Normal)
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                btn.backgroundColor = UIColor.clearColor()
                btn.addSubview(ZMDTool.getLine(CGRect(x: 0, y: btn.frame.height-0.5, width: btn.frame.width, height: 0.5), backgroundColor: UIColor.whiteColor()))
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    selectView.removeFromSuperview()
                    
                    return RACSignal.empty()
                })
                selectView.addSubview(btn)
            }
            selectView.showAsPop(setBgColor: false)
        })
        btn.setImage(UIImage(named: "btn_Arrow_turnDown1"), forState: .Normal)
        return btn
    }


}