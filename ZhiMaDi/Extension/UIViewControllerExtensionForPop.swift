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
extension UIView {
    
    /// Popup conteiner view
    private var containerView: UIView? {
        //动态向类中添加 方法
        get {
            return objc_getAssociatedObject(self, &containerViewAssociationKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &containerViewAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
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
    public func presentPopupView(popupView: UIView,config: ZMDPopViewConfig = ZMDPopViewConfig()) {
        self.addSubview(popupView)
        self.popupView = popupView
        self.config = config
        showAnimation()
    }
    private func showAnimation() {
        if let config = config {
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
                if let containerView = containerView, let popupView = popupView {
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
    public func dismissPopupView() {
        dismissAnimation()
    }
    
    private func completionDismissAnimation(finished: Bool) {
        if let completion = config?.dismissCompletion, let popupView =  popupView {
            completion(popupView)
        }
        
        // remove view
        containerView?.removeFromSuperview()
        containerView = nil
        config = nil
    }
    
    private func dismissAnimation() {
        NSNotificationCenter.defaultCenter().postNotificationName("popDismiss", object: nil)
        if let config = config {
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
                if let containerView = containerView, let popupView = popupView {
                    config.dismissCustomAnimation(containerView, popupView, { self.completionDismissAnimation(true) })
                }
            }
        }
    }
    
    // MARK: - Show Animation
    
    private func fadeIn() {
        if let containerView = containerView {
            containerView.alpha = 0
            UIView.animateWithDuration(0.2, animations: {
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
        if let containerView = containerView, let popupView = popupView {
            
            var frame = popupView.frame
            frame.origin.y = CGRectGetHeight(containerView.frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.3, animations: {
                popupView.center = containerView.center
                }, completion: completionShowAnimation)
        }
    }
    
    private func slideInFromLeft() {
        if let containerView = containerView, let popupView = popupView {
            
            var frame = popupView.frame
            frame.origin.x = -CGRectGetWidth(frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.3, animations: {
                popupView.center = containerView.center
                }, completion: completionShowAnimation)
        }
    }
    
    private func slideInFromRight() {
        if let containerView = containerView, let popupView = popupView {
            
            var frame = popupView.frame
            frame.origin.x = CGRectGetWidth(containerView.frame)
            popupView.frame = frame
            
            UIView.animateWithDuration(0.3, animations: {
                popupView.center = containerView.center
                }, completion: completionShowAnimation)
        }
    }
    
    // MARK: - Dismiss Animation
    
    private func fadeOut() {
        if let containerView = containerView {
            UIView.animateWithDuration(0.2, animations: {
                containerView.alpha = 0
                }, completion: completionDismissAnimation)
        }
    }
    
    private func slideOutToTop() {
        if let _ = containerView, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.y = -CGRectGetHeight(frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    
    private func slideOutToBottom() {
        if let containerView = containerView, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.y = CGRectGetHeight(containerView.frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    
    private func slideOutToLeft() {
        if let _ = containerView, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.x = -CGRectGetWidth(frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    
    private func slideOutToRight() {
        if let containerView = containerView, let popupView = popupView {
            UIView.animateWithDuration(0.3, animations: {
                var frame = popupView.frame
                frame.origin.x = CGRectGetWidth(containerView.frame)
                popupView.frame = frame
                }, completion: completionDismissAnimation)
        }
    }
    
}