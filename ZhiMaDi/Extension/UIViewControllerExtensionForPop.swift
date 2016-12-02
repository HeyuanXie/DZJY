//
//  UIViewExtensionForPop.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/21.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit


//MARK: - Show Animation type
public enum ZMDPopupShowAnimation {
    case None
    case FadeIn
    case SlideInFromTop
    case SlideInFromBottom
    case SlideInFromLeft
    case SlideInFromRight
    case Custom // Need implements 'showCustomAnimation'
}

//MARK: - Dismiss Animation
public enum ZMDPopupDismissAnimation {
    case None
    case FadeOut
    case SlideOutToTop
    case SlideOutToBottom
    case SlideOutToLeft
    case SlideOutToRight
    case Custom // Need implements 'dismissCustomAnimation'
}


//MARK : - Popup Config
public class ZMDPopViewConfig {
    
    /// Dismiss touch the Background if ture.
    public var dismissTouchBackground = true
    
    /// Popup corner radius value.
    public var cornerRadius: CGFloat = 0
    
    /// Background overlay color.  118,118,118
    public var overlayColor = UIColor(red: 118/255, green: 118/255, blue: 118/255, alpha: 0.5)
    
    /// Show animation type.
    public var showAnimation = ZMDPopupShowAnimation.FadeIn
    
    /// Dismiss animation type.
    public var dismissAnimation = ZMDPopupDismissAnimation.FadeOut
    
    /// Clouser show animation is completed.
    /// Pass the popup view to argument.
    public var showCompletion: ((UIView) -> Void)? = nil
    
    /// Clouser disimss animation is completed.
    /// Pass the popup view to argument.
    public var dismissCompletion: ((UIView) -> Void)? = nil
    
    public var showCustomAnimation: (UIView, UIView, (Void) -> Void) -> Void = { containerView, popupView, completion in }
    
    public var dismissCustomAnimation: (UIView, UIView, (Void) -> Void) -> Void = { containerView, popupView, completion in }
    
    public init() {}
}
/// Association key
private var containerViewAssociationKey: UInt8 = 0
private var popupViewAssociationKey: UInt8 = 0
private var configAssociationKey: UInt8 = 0

/**
 *  UIViewController + STZPopupView
 */
extension UIViewController {
    /// Popup view
    private var popupView: UIView? {
        get {
            return objc_getAssociatedObject(self, &popupViewAssociationKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &popupViewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// Popup config
    private var config: ZMDPopViewConfig? {
        get {
            return objc_getAssociatedObject(self, &configAssociationKey) as? ZMDPopViewConfig
        }
        set {
            objc_setAssociatedObject(self, &configAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Show popup
    
    /**
    Show popup
    
    :param: popupView Popup view
    :param: config    Config (Option)
    */
    public func presentPopupView(popupView: UIView,config: ZMDPopViewConfig!) {
        self.view.addSubview(popupView)
        self.popupView = popupView
        self.config = config
        showAnimation()
    }
    public func presentPopupViewForNav(popupView: UIView,config: ZMDPopViewConfig!) {
        self.navigationController?.view.addSubview(popupView)
        self.popupView = popupView
        self.config = config
        showAnimation()
    }
    private func showAnimation() {
        if let config = self.config {
            switch (config.showAnimation) {
            case .None:
                completionShowAnimation(true)
            case .FadeIn:
                fadeIn()
            case .SlideInFromTop:
                slideInFromTop()
            case .SlideInFromBottom:
                slideInFromBottom()
            case .SlideInFromLeft:
                slideInFromLeft()
            case .SlideInFromRight:
                slideInFromRight()
            case .Custom:
                if let containerView = self.view, let popupView = popupView {
                    config.showCustomAnimation(containerView, popupView, { self.completionShowAnimation(true) })
                }
            }
        }
    }
    
    private func completionShowAnimation(finished: Bool) {
        if let completion = config?.showCompletion, let popupView = popupView {
            completion(popupView)
        }
    }
    
    // MARK: - Dismiss popup
    
    /**
    Dismiss popup
    */
    public func dismissPopupView(popupView:UIView) {
        self.popupView = popupView
        dismissAnimation()
    }
    
    private func completionDismissAnimation(finished: Bool) {
        if let completion = config?.dismissCompletion, let popupView =  popupView {
            completion(popupView)
        }
        
        // remove view
        config = nil
    }
    
    private func dismissAnimation() {
        if let config = self.config {
            switch (config.dismissAnimation) {
            case .None:
                completionDismissAnimation(true)
            case .FadeOut:
                fadeOut()
            case .SlideOutToTop:
                slideOutToTop()
            case .SlideOutToBottom:
                slideOutToBottom()
            case .SlideOutToLeft:
                slideOutToLeft()
            case .SlideOutToRight:
                slideOutToRight()
            case .Custom:
                if let containerView = self.view, let popupView = popupView {
                    config.dismissCustomAnimation(containerView, popupView, { self.completionDismissAnimation(true) })
                }
            }
        }
    }
    
    // MARK: - Show Animation
    
    private func fadeIn() {
        if let containerView = self.popupView {
            containerView.alpha = 0
            UIView.animateWithDuration(0.1, animations: {
                containerView.alpha = 1
                }, completion: completionShowAnimation)
        }
    }
    
    private func slideInFromTop() {
        if let popupView = popupView {
            let center = popupView.center
            var frame = popupView.frame
            frame.origin.y = -CGRectGetHeight(frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.3, animations: {
                popupView.center = center
                }, completion: completionShowAnimation)
        }
    }
    
    private func slideInFromBottom() {
        if let containerView = self.view, let popupView = popupView {
            
            var frame = popupView.frame
            frame.origin.y = CGRectGetHeight(containerView.frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.38, animations: {
                var frame = popupView.frame
                frame.origin.y = CGRectGetHeight(containerView.frame) -  CGRectGetHeight(frame)
                popupView.frame = frame
                }, completion: completionShowAnimation)
        }
    }
    
    private func slideInFromLeft() {
        if let containerView = self.view, let popupView = popupView {
            
            var frame = popupView.frame
            frame.origin.x = -CGRectGetWidth(frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.3, animations: {
                popupView.center = containerView.center
                }, completion: completionShowAnimation)
        }
    }
    
    private func slideInFromRight() {
        if let containerView = self.navigationController!.view, let popupView = popupView {
            var frame = popupView.frame
            frame.origin.x = CGRectGetWidth(containerView.frame)+CGRectGetWidth(frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.x = CGRectGetWidth(containerView.frame)-CGRectGetWidth(frame)
                popupView.frame = frame
                }, completion: completionShowAnimation)
        }
    }
    
    // MARK: - Dismiss Animation
    
    private func fadeOut() {
        if let containerView = self.popupView {
            UIView.animateWithDuration(0.2, animations: {
                containerView.alpha = 0
                }, completion: completionDismissAnimation)
            containerView.removeFromSuperview()
        }
    }
    
    private func slideOutToTop() {
        if let _ = self.view, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.y = -CGRectGetHeight(frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    
    private func slideOutToBottom() {
        if let containerView = self.view, let popupView = popupView {
            UIView.animateWithDuration(0.38, animations: {
                var frame = popupView.frame
                frame.origin.y = CGRectGetHeight(containerView.frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    
    private func slideOutToLeft() {
        if let _ = self.view, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.x = -CGRectGetWidth(frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    private func slideOutToRight() {
        if let containerView = self.view, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.x = CGRectGetWidth(containerView.frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    // 自定义个黑色背景
    // 使用于self.view中
    func viewShowWithBg(view:UIView,showAnimation:ZMDPopupShowAnimation = .None,dismissAnimation:ZMDPopupDismissAnimation = .None) {
        let bg = UIButton(frame: self.view.bounds)
        bg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4) //半透明色值
        bg.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.dismissPopupView(view)
            return RACSignal.empty()
        })
        self.presentPopupView(bg,config: ZMDPopViewConfig())
        let config = ZMDPopViewConfig()
        config.dismissCompletion = { (view) ->Void in
            bg.removeFromSuperview()
        }
        config.showAnimation = showAnimation
        config.dismissAnimation = dismissAnimation
        self.presentPopupView(view,config: config)
    }
    // 使用于全屏
    func viewShowWithBgForNav(view:UIView,showAnimation:ZMDPopupShowAnimation = .None,dismissAnimation:ZMDPopupDismissAnimation = .None) {
        let bg = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        bg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4) //半透明色值
        bg.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.dismissPopupView(view)
            return RACSignal.empty()
        })
        //灰色背景btn的tag
        bg.tag = 5000
        self.presentPopupViewForNav(bg,config: ZMDPopViewConfig())
        let config = ZMDPopViewConfig()
        config.dismissCompletion = { (view) ->Void in
            bg.removeFromSuperview()
        }
        config.showAnimation = showAnimation
        config.dismissAnimation = dismissAnimation
        self.presentPopupViewForNav(view,config: config)
    }
}

//MARK:设置导航栏全透明
extension UIViewController {
    
    /// NaviagtionBarTransparent
    func navigationBartransparent(var superView:UIView) {
        let navBackView : UIView!
        var navLine : UIView!
        let backString = SYSTEM_VERSION_FLOAT >= 10.0 ? "_UIBarBackground" : "_UINavigationBarBackground"
        if superView.isKindOfClass(NSClassFromString(backString)!) {
            for view in superView.subviews {
                //移除分割线
                if view.isKindOfClass(UIImageView.classForCoder()) {
                    navLine = view
                    navLine.hidden = true
                }
            }
            navBackView = superView
            navBackView.alpha = 0
            navBackView.backgroundColor = navigationBackgroundColor
        } else if superView.isKindOfClass(NSClassFromString("_UIBackdropView")!) {
            superView.hidden = true
        }
        for view in superView.subviews {
            self.navigationBartransparent(view)
        }
    }
}
