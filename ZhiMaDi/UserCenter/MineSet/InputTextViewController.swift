//
//  PersonIntroductionViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/2.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//个人昵称
//  通用的单输出页面
class InputTextViewController: UIViewController ,UITextViewDelegate,ZMDInterceptorProtocol {
    private var inputTextView: UITextView!
    var countLbl : UILabel!
    var text = ""                           // 初始文本
    var maxLength = 100                       // 昵称字数限制
    var finished : ((text:String)->Void)!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController!.tabBar.hidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.view.backgroundColor = defaultBackgroundGrayColor
        self.inputTextView = UITextView(frame: CGRectMake(0, 10, self.view.frame.width, 180))
        self.inputTextView.backgroundColor = UIColor.whiteColor()
        self.inputTextView.returnKeyType = UIReturnKeyType.Done
        self.inputTextView.text = text
        self.inputTextView.font = UIFont.systemFontOfSize(15)
        self.inputTextView.layer.masksToBounds = true
        self.inputTextView.layer.borderColor = defaultLineColor.CGColor
        self.inputTextView.layer.borderWidth = 0.5
        self.inputTextView.delegate = self
        self.inputTextView.returnKeyType = UIReturnKeyType.Default
        self.view.addSubview(self.inputTextView)
        
        self.countLbl = UILabel(frame: CGRectMake(self.view.frame.width - 88 , CGRectGetMaxY(self.inputTextView.frame) , 100, 13))
        let count =  (text as NSString).length
        self.countLbl.text = "\(self.maxLength - count)/\(self.maxLength)"
        self.countLbl.font = UIFont.systemFontOfSize(13)
        self.countLbl.textColor = UIColor.grayColor()
        self.view.addSubview(self.countLbl)
        // 保存按钮
        let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        saveItem.tintColor = appThemeColor
        saveItem.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                strongSelf.view.endEditing(true)
                if strongSelf.finished != nil {
                    strongSelf.finished(text: strongSelf.inputTextView.text)
                }
                strongSelf.back()
            }
            return RACSignal.empty()
            })
            self.navigationItem.rightBarButtonItem = saveItem
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UItextViewdDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true;
    }
    func textViewDidChange(textView: UITextView) {
        let mulStr = NSMutableString(string: textView.text)
        self.countLbl.text = "\(self.maxLength - mulStr.length)/\(self.maxLength)"
        self.countLbl.textColor = UIColor.grayColor()
        if  self.maxLength - mulStr.length < 0 {
            self.countLbl.textColor = UIColor.redColor()
        }
    }
    //MARK:- Private Method?
    // 保存个人简介
    class func saveDocIntroduce(resume: String?, viewController: UIViewController? = nil) -> Bool {
        var tmpResume = resume as NSString?
        tmpResume = tmpResume?.stringByReplacingOccurrencesOfString(" ", withString: "")
        if tmpResume == nil || tmpResume!.length == 0 {
            ZMDTool.showPromptView("请输入内容")
            return false
        }
        if  tmpResume!.length > 100 {
            ZMDTool.showPromptView("个人简介超过100字")
            return false
        }
        // 限制输入范围
//        if tmpResume!.length > self.maxLength {
//            tmpResume = tmpResume!.substringToIndex(self.maxLength)
//        }
        return true
    }
    override func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
