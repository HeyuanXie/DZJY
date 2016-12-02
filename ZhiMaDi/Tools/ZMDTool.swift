//
//  ZMDTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/5/28.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import Foundation
import UIKit
// 私有的实例，用户处理一些回调
private let zmdToolInstance = ZMDTool()

/** 通用工具类 */
class ZMDTool: NSObject {
}
// MARK: - 更新时做 数据迁移
private let kKeyVersionOnLastOpen = ("VersionOnLastOpen" as NSString).encrypt(g_SecretKey)
extension ZMDTool {
    /// 更新时做 数据迁移
    class func update() {
        }
}

// MARK: - 提示框相关
extension ZMDTool {
    
    /**
    弹出会自动消失的提示框
    
    :param: message    提示内容
    :param: completion 提示框消失后的回调
    */
    class func showPromptView(message: String = "服务升级中，请耐心等待！", _ completion: (()->Void)? = nil) {
        lyShowPromptView(message, completion)
    }
    
    /**
    弹出进度提示框
    
    :param: message         提示内容
    :param: inView          容器，如果设置为nil，会放在keyWindow上
    :param: timeoutInterval 超时隐藏，如果设置为nil，超时时间是3min
    */
    class func showActivityView(message: String?, inView: UIView? = nil, _ timeoutInterval: NSTimeInterval? = nil) {
        lyShowActivityView(message, inView: inView, timeoutInterval)
    }
    
    /**
    隐藏进度提示框
    */
    class func hiddenActivityView() {
        lyHiddenActivityView()
    }
    
    /**
    显示错误提示
    
    优先显示服务器返回的错误信息，如果没有，则显示网络层返回的错误信息，如果在没有，则显示默认的错误提示
    
    :param: dictionary 服务器返回的Dic
    :param: error      网络层返回的error
    :param: errorMsg   服务器返回的错误信息
    */
    class func showErrorPromptView(dictionary: NSDictionary?, error: NSError?, errorMsg: String? = nil) {
        if errorMsg != nil {
            ZMDTool.showPromptView(errorMsg!); return
        }
        
        if let errorMsg = dictionary?["errorMsg"] as? String {
            ZMDTool.showPromptView(errorMsg); return
        }
        
        if error != nil && error!.domain.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            ZMDTool.showPromptView("网络异常，请稍后重试！"); return
        }
        
        ZMDTool.showPromptView()
    }
    
    
}

// MARK: - 增加空提示的View
private let kTagEmptyView = 96211
private let kTagMessageLabel = 96212
extension ZMDTool {
    
    /**
    为inView增加空提示
    
    :param: message    提示内容
    :param: inView     所依附的View
    */
    class func showEmptyView(message: String? = nil, inView: UIView?) {
        if inView == nil { return }
        
        //
        var emptyView: UIView! = inView!.viewWithTag(kTagEmptyView)
        if emptyView == nil {
            emptyView = UIView(frame: inView!.bounds)
            emptyView.backgroundColor = UIColor.clearColor()
            emptyView.tag = kTagEmptyView
            inView!.addSubview(emptyView)
        }
        
        // 设置提示
        if message != nil {
            let widthMax = emptyView.bounds.width - 40
            var messageLabel: UILabel! = emptyView.viewWithTag(kTagMessageLabel) as? UILabel
            if messageLabel == nil {
                messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: widthMax, height: 20))
                messageLabel.tag = kTagMessageLabel
                messageLabel.textColor = tableViewCellDefaultDetailTextColor
                messageLabel.backgroundColor = UIColor.clearColor()
                messageLabel.textAlignment = .Center
                messageLabel.autoresizingMask = .FlexibleWidth
                messageLabel.numberOfLines = 0
                emptyView.addSubview(messageLabel)
            }
            
            messageLabel.text = message
            messageLabel.bounds = CGRect(origin: CGPointZero, size: messageLabel.sizeThatFits(CGSize(width: widthMax, height: CGFloat.max)))
            messageLabel.center = CGPoint(x: emptyView.bounds.width/2.0, y: emptyView.bounds.height/2.0)
        }
        else {
            emptyView.viewWithTag(kTagMessageLabel)?.removeFromSuperview()
        }
    }
    
    /**
    隐藏空提示
    
    :param: inView     所依附的View
    */
    class func hiddenEmptyView(forView: UIView?) {
        forView?.viewWithTag(kTagEmptyView)?.removeFromSuperview()
    }
    
    
}
// MARK: - 让 Navigation 支持右滑返回
extension ZMDTool: UIGestureRecognizerDelegate {
    
    /**
     让 Navigation 支持右滑返回
     
     :param: navigationController 需要支持的 UINavigationController 对象
     */
    class func addInteractive(navigationController: UINavigationController?) {
        navigationController?.interactivePopGestureRecognizer!.enabled = true
        navigationController?.interactivePopGestureRecognizer!.delegate = zmdToolInstance
    }
    
    /**
     移除 Navigation 右滑返回
     
     :param: navigationController 需要支持的 UINavigationController 对象
     */
    class func removeInteractive(navigationController: UINavigationController?) {
        navigationController?.interactivePopGestureRecognizer!.enabled = false
        navigationController?.interactivePopGestureRecognizer!.delegate = nil
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        _ = topViewController()
        if let vc = topViewController() where gestureRecognizer == vc.navigationController?.interactivePopGestureRecognizer {
            return (vc.navigationController!.viewControllers.count > 1)
        }
        return false // 其他情况，则不支持
    }
}
// MARK: - 页面切换相关
extension ZMDTool {
    ///隐藏底部自定义tabBar
    class func hideBottomBarWhenPushed(hide:Bool = true) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let tabBar = app.tabBar
        tabBar.hyTabBarHidden(true, animated: true)
    }

    /**
    转场动画过渡
    
    :param: vc 将要打开的ViewController
    */
    class func enterRootViewController(vc: UIViewController, animated: Bool = true) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let animationView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false)
            appDelegate.window?.addSubview(animationView)
            let changeRootViewController = { () -> Void in
                appDelegate.window?.rootViewController = vc
                if animated {
                    appDelegate.window?.bringSubviewToFront(animationView)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        animationView.transform = CGAffineTransformMakeScale(3.0, 3.0)
                        animationView.alpha = 0
                        }, completion: { (finished) -> Void in
                            animationView.removeFromSuperview()
                    })
                }
                else {
                    animationView.removeFromSuperview()
                }
            }
            
            if let viewController = appDelegate.window?.rootViewController where viewController.presentedViewController != nil {
                viewController.dismissViewControllerAnimated(false) {
                    changeRootViewController()
                }
            }
            else {
                changeRootViewController()
            }
        }
    }
    
    /**
    进入登陆的控制器
    */
    class func enterLoginViewController() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
        ZMDTool.enterRootViewController(vc)
    }

    class func enterMyStoreViewController() {
        let vc = UIStoryboard(name: "Store", bundle: nil).instantiateInitialViewController()!
        ZMDTool.enterRootViewController(vc)
    }
    
    class func enterHomePageViewController() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        ZMDTool.enterRootViewController(vc)
    }
    
}

// MARK: - 获得某个范围内的屏幕图像
extension ZMDTool {
    /// 获得 view 某个范围内的屏幕图像
    class func imageFromView(view: UIView, frame: CGRect) -> UIImageView {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        UIRectClip(frame)
        view.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        return  imageView
    }
}


// MARK: - 判断当前网络状况
extension ZMDTool {
    /// 网络连接状态
    class func netWorkStatus() -> NetworkStatus {
        let netWorkStatic = Reachability.reachabilityForInternetConnection()
        netWorkStatic.startNotifier()
        return netWorkStatic.currentReachabilityStatus()
    }
}

extension ZMDTool {
    
    class func getTextField(frame:CGRect,placeholder:String,fontSize:CGFloat,textColor:UIColor = defaultTextColor) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.textColor = defaultTextColor
        textField.font = defaultSysFontWithSize(fontSize)
        textField.placeholder = placeholder
        return textField
    }
    
    class func getTextView(frame:CGRect,placeholder:String,fontSize:CGFloat,textColor:UIColor = defaultTextColor) -> UITextView {
        let textView = UITextView(frame: frame)
        textView.textColor = textColor
        textView.font = defaultSysFontWithSize(fontSize)
        let label = ZMDTool.getLabel(CGRect(x: 5, y: 5, width: frame.width, height: 20), text: placeholder, fontSize: fontSize, textColor: RGB(173,173,173,1.0), textAlignment: .Left)
        textView.addSubview(label)
        label.tag = 10000
        return textView
    }
    
    class func getLabel(frame:CGRect,text:String,fontSize:CGFloat,textColor:UIColor = defaultTextColor,textAlignment : NSTextAlignment = .Left) -> UILabel {
        let label = UILabel(frame: frame)
        label.backgroundColor = UIColor.clearColor()
        label.text = text
        label.font = defaultSysFontWithSize(fontSize)
        label.textColor = textColor
        label.textAlignment = textAlignment
        return label
    }
    class func getButton (frame:CGRect,textForNormal:String,fontSize:CGFloat,textColorForNormal:UIColor = defaultTextColor,backgroundColor:UIColor,blockForCli : ((AnyObject!) -> Void)!) -> UIButton {
        let btn = UIButton(frame: frame)
        btn.backgroundColor = backgroundColor
        btn.setTitle(textForNormal, forState: .Normal)
        btn.setTitleColor(textColorForNormal, forState: .Normal)
        btn.titleLabel!.font = defaultSysFontWithSize(fontSize)
        btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext(blockForCli)
        return btn
    }
    class func getButton (frame:CGRect,textForNormal:String,fontSize:CGFloat,textColorForNormal:UIColor = defaultTextColor,backgroundColor:UIColor,blockForCom : ((AnyObject!) -> RACSignal!)?) -> UIButton {
        let btn = UIButton(frame: frame)
        btn.backgroundColor = backgroundColor
        btn.setTitle(textForNormal, forState: .Normal)
        btn.setTitleColor(textColorForNormal, forState: .Normal)
        btn.titleLabel!.font = defaultSysFontWithSize(fontSize)
        if blockForCom != nil {
            btn.rac_command = RACCommand(signalBlock: blockForCom)
        }
        return btn
    }
    
    class func getMutilButton (frame:CGRect,textForNormal:String,textColorForNormal:UIColor = defaultTextColor,textColorForSelect:UIColor = RGB(235,61,61,1.0),fontSize:CGFloat,backgroundColor:UIColor,blockForCli : ((AnyObject!) -> Void)!) -> UIButton{
        let btn = UIButton(frame: frame)
        btn.backgroundColor = backgroundColor
        btn.setTitle(textForNormal, forState: .Normal)
        btn.setTitleColor(textColorForNormal, forState: .Normal)
        btn.setTitle(textForNormal, forState: .Selected)
        btn.setTitleColor(textColorForSelect, forState: .Selected)
        btn.titleLabel!.font = defaultSysFontWithSize(fontSize)
        btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext(blockForCli)
        return btn
    }
    class func getLine(frame:CGRect,backgroundColor : UIColor = defaultLineColor) -> UIView {
        let line = UIView(frame: frame)
        line.backgroundColor = defaultLineColor
        return line
    }
    class func getBtn (frame:CGRect) -> CustomBtn {
        return CustomBtn(frame: frame)
    }
    //图文垂直btn
    class func getVerticalBtn(frame:CGRect) -> CustomVerticalBtn {
        return CustomVerticalBtn(frame: frame)
    }
}

//自定义UIButton 用于图跟文字垂直
class CustomBtn : UIButton {
    override func layoutSubviews() {
        let edgeTop = (self.frame.height - (self.imageView?.frame.size.height)! - 24)/2
        super.layoutSubviews()
        // Center image
        var center = self.imageView?.center
        center?.x = self.frame.size.width/2
        center?.y = self.imageView!.frame.size.height/2 + edgeTop
        self.imageView!.center = center!
        
        //Center text
        var newFrame = self.titleLabel!.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.imageView!.frame.size.height + edgeTop + 8 // 8 为 title img 间距
        newFrame.size.width = self.frame.size.width;
        
        self.titleLabel!.frame = newFrame;
        self.titleLabel!.textAlignment = .Center
    }
}
// 图跟文字垂直
class CustomVerticalBtn : UIButton {
    override func layoutSubviews() {
        let titleSize = self.titleLabel!.bounds.size
        let imageSize = self.imageView!.bounds.size
        let interval : CGFloat = 1.0
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: titleSize.height+interval, right: -(titleSize.width+interval))
        self.titleEdgeInsets = UIEdgeInsets(top: imageSize.height+interval, left: -(imageSize.width+interval), bottom: 0, right: 0)
    }
}


extension ZMDTool {
    //画左下三角
    class func drawLeftLowerTriangle(rect:CGRect) {
        //设置背景色
        UIColor.clearColor().set()
        UIRectFill(rect)
        let context = UIGraphicsGetCurrentContext()   //拿到当前画板
        CGContextBeginPath(context)     //标记
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y) //设置起点
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y)
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y+rect.size.height)
        CGContextClosePath(context)
        RGB(253,124,76,1.0).setFill()   //设置填充色
        UIColor.clearColor().setStroke()    //设置边框色
        CGContextDrawPath(context, .FillStroke)
    }
}

// test
// map faltmap
class ZMDHaijie {
    func func1() {
        // 1
        let numbers = [1,2,3,4]
        let result = numbers.map { $0 + 2 }
        print(result)  // [3,4,5,6]
        let _ = numbers.map{"key_\($0)"}
        // 2
        let numbersCompound = [[1,2,3],[4,5,6]];
        let _ = numbersCompound.map { $0.map{ $0 + 2 } }
        // [[3, 4, 5], [6, 7, 8]]
        let _ = numbersCompound.flatMap { $0.map{ $0 + 2 } }
        // [3, 4, 5, 6, 7, 8]
        
        // 3
        let optionalArray: [String?] = ["AA", nil, "BB", "CC"];
        let _ = optionalArray.flatMap{ $0 } // ["AA", "BB", "CC"]
        // 无效的图片过滤掉：
        let imageNames = ["test.png", "aa.png", "icon.png"];
        let _ = imageNames.flatMap{ UIImage(named: $0) }
    }
}




