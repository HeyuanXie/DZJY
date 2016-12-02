//
//  UIViewExtension.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/25.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit

private let kTagBadgeLabel = 20087


/**
*  @author LiuYu, 15-04-25 15:04:25
*
*  做一个有BadgeValue的扩展，默认的显示位置是在右上角
*/
extension UIView {
    /// 设置BadgeValue的值和位置,  nil: 隐藏，  "": 小红点， "str": 显示str
    var badgeValue: String? {
        get {
            return (self.viewWithTag(kTagBadgeLabel) as? UILabel)?.text
        }
        set {
            if newValue == nil { // 当设置nil的时候，删除所有相关的View
                self.viewWithTag(kTagBadgeLabel)?.removeFromSuperview()
            }
            else {
                let offsetTop: CGFloat = 10
                let offsetRight: CGFloat = 10
                let height: CGFloat = 18
                self.clipsToBounds = false
                var badgeLabel: UILabel! = self.viewWithTag(kTagBadgeLabel) as? UILabel
                if badgeLabel == nil {
                    badgeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: offsetTop*2, height: offsetRight*2))
                    badgeLabel.tag = kTagBadgeLabel
                    badgeLabel.autoresizingMask = .FlexibleLeftMargin
                    badgeLabel.textColor = UIColor.whiteColor()
                    badgeLabel.backgroundColor = UIColor(red: 234/255.0, green: 61/255.0, blue: 60/255.0, alpha: 1.0)
                    badgeLabel.textAlignment = .Center
                    badgeLabel.layer.masksToBounds = true
                    badgeLabel.font = UIFont.systemFontOfSize(12)
                    self.addSubview(badgeLabel)
                }
                
                if newValue != "" { // 当设置str的时候，显示str
                    badgeLabel.text = newValue!
                    badgeLabel.sizeToFit()
                    badgeLabel.bounds = CGRect(origin: CGPointZero, size: CGSize(width: max(height, badgeLabel.bounds.width + 10/*增加一个偏移值*/), height: height))
                }
                else { // 当设置""的时候，显示小红点
                    badgeLabel.text = newValue!
                    badgeLabel.bounds = CGRect(origin: CGPointZero, size: CGSize(width: 10, height: 10))
                }
                badgeLabel.layer.cornerRadius = badgeLabel.bounds.height/2.0
                badgeLabel.frame = CGRect(origin: CGPoint(x: self.bounds.width - offsetRight - badgeLabel.bounds.height/2.0, y: offsetTop - badgeLabel.bounds.height/2.0), size: badgeLabel.bounds.size)
            }
        }
    }
    
    /**
    设置BadgeValue的值和位置
    
    :param: badgeValue 值
    :param: center     中心点位置
    */
    func setBadgeValue(badgeValue: String?, center: CGPoint) {
        self.badgeValue = badgeValue
        self.viewWithTag(kTagBadgeLabel)?.center = center
    }
}
//方便自定义窗口弹出
extension UIView {
    //点击阴影移除窗口
    func showAsPopAndhideWhenClickGray() {
        let frontToBackWindows = UIApplication.sharedApplication().windows.reverse()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.mainScreen()
            let windowIsVisible = !window.hidden && window.alpha > 0
            let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                window.addSubview(self)
                
                let btn = UIButton(frame: CGRectMake(0 , 0, kScreenWidth,  kScreenHeight))
                btn.backgroundColor = UIColor.clearColor()
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    self.removePop()
                    sender.removeFromSuperview()
                })
                window.addSubview(btn)
                break
            }
        }
        //动画
        self.layer.opacity = 0.5;
        self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4) //半透明色值
            self.layer.opacity = 1.0
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);
            }) { (finished) -> Void in
        }
    }
 
    func showAsPop(setBgColor isSetBgColor : Bool  = true) {
        let frontToBackWindows = UIApplication.sharedApplication().windows.reverse()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.mainScreen()
            let windowIsVisible = !window.hidden && window.alpha > 0
            let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                window.addSubview(self)
                break
            }
        }
        self.layer.opacity = 0.5;
        self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            if isSetBgColor {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4) //半透明色值
            }
            self.layer.opacity = 1.0
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);
            }) { (finished) -> Void in
        }
    }
    func removePop() {
        UIView.animateWithDuration(0.15, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseIn , UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
            self.alpha = 0
            self.transform = CGAffineTransformScale(self.transform, 0.8,0.8);
            }) { (finished) -> Void in
                self.canPerformAction(Selector("removeFromSuperview"), withSender: self)
        }
    }
}

extension UIView {
    //通过UIView得到它的UIViewController
    public func getController()->UIViewController?{
        var next:UIView? = self
        repeat{
            if let nextResponder = next?.nextResponder() where nextResponder.isKindOfClass(UIViewController.self){
                return (nextResponder as! UIViewController)
            }
            next = next?.superview
        }while next != nil
        return nil
    }
}

//设置UIView 的frame
extension UIView {
    func get(type:String) -> CGFloat {
        switch type {
        case "x" :
            return self.frame.origin.x
        case "y" :
            return self.frame.origin.y
        case "w" :
            return self.frame.size.width
        case "h" :
            return self.frame.size.height
        default :
            print("type错误")
            return 0
        }
    }
    
    func set(type:String,value:CGFloat) {
        var frame = self.frame
        var center = self.center
        switch type {
        case "x" :
            frame.origin.x = value
            self.frame = frame
            break
        case "y" :
            frame.origin.y = value
            self.frame = frame
            break
        case "w" :
            frame.size.width = value
            self.frame = frame
            break
        case "h" :
            frame.size.height = value
            self.frame = frame
        case "cx" :
            center.x = value
            self.center = center
        case "cy" :
            center.y = value
            self.center = center
        default :
            print("type错误")
            break
        }
    }
    
    func add(type:String,value:CGFloat) {
        var frame = self.frame
        var center = self.center
        switch type {
        case "x" :
            frame.origin.x = value + frame.origin.x
            self.frame = frame
            break
        case "y" :
            frame.origin.y = value + frame.origin.y
            self.frame = frame
            break
        case "w" :
            frame.size.width = value + frame.size.width
            self.frame = frame
            break
        case "h" :
            frame.size.height = value + frame.size.height
            self.frame = frame
        case "cx" :
            center.x = value + center.x
            self.center = center
        case "cy" :
            center.y = value + center.y
            self.center = center
        default :
            print("type错误")
            break
        }
    }
    
}


