//
//  ResisterViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/1.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 注册
class ResisterViewController: UIViewController, UITextFieldDelegate,ZMDInterceptorProtocol{
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var psTextField: UITextField!
    @IBOutlet weak var offerCodeTextField: UITextField!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    var getVerificationBtn: UIButton!  //  getVerificationBtn == nil ？ 密码登录 ： 验证码登录
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.view.backgroundColor = tableViewdefaultBackgroundColor
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            self.verificationTextField.becomeFirstResponder()
        }
        else if textField.returnKeyType == .Done {
            self.login()
        }
        return false
    }
    
    // @IBAction
    // MARK: 登录
    @IBAction func login(sender: UIButton) {
        if self.agreeBtn.selected {
            self.login()
        } else {
            ZMDTool.showPromptView("请先同意葫芦堡用户注册协议")
        }
    }
    @IBAction func agreeBtnCli(sender: UIButton) {
        self.agreeBtn.selected = !self.agreeBtn.selected
    }
    //    @IBAction func goBack(sender: UIButton) {
    //        if self.getVerificationBtn == nil {
    //            self.navigationController?.popToRootViewControllerAnimated(true)
    //        } else {
    //            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    //            ZMDTool.enterRootViewController(vc!)
    //        }
    //    }
    
    //MARK: - PrivateMethod
    func updateUI() {
        //默认统一协议
        self.agreeBtn.selected = true
        // 进一步配置账号和密码输入UI
        let TmpV1 = UIImageView(frame: CGRectMake(10, 0, 12, 20))
        self.accountTextField.leftViewMode =  UITextFieldViewMode.Always
        self.accountTextField.text = g_Account
        self.accountTextField.leftView = TmpV1
        
        let TmpV2 = UIImageView(frame: CGRectMake(10, 0, 12, 20))
        self.verificationTextField.leftView = TmpV2
        
        self.verificationTextField.leftViewMode =  UITextFieldViewMode.Always
        let TmpV3 = UIImageView(frame: CGRectMake(10, 0, 12, 20))
        self.psTextField.leftView = TmpV3
        self.psTextField.leftViewMode =  UITextFieldViewMode.Always
        
        let TmpV4 = UIImageView(frame: CGRectMake(10, 0, 12, 20))
        self.offerCodeTextField.leftView = TmpV4
        self.offerCodeTextField.leftViewMode =  UITextFieldViewMode.Always
        
        
        ZMDTool.configViewLayerWithSize(self.loginBtn, size: 12)
        
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
        
        
        // 获取验证码的按钮
        let codeRightV = UIView(frame: CGRect(x: 0, y: 0, width: 92+12, height: 60))
        codeRightV.backgroundColor = UIColor.clearColor()
        let btn = ZMDTool.getButton(CGRect(x: 0, y: 14, width: 92, height: 32), textForNormal: "获取验证码", fontSize: 13, textColorForNormal:defaultDetailTextColor,backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
            
        })
        ZMDTool.configViewLayerWithSize(btn, size: 18)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = defaultLineColor.CGColor
        codeRightV.addSubview(btn)
        self.accountTextField.rightViewMode =  UITextFieldViewMode.Always
        self.accountTextField.rightView = codeRightV
        self.getVerificationBtn = btn
        
        
        LoginViewController.waitingAuthCode(self.getVerificationBtn, start: false)
        self.getVerificationBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
            if let strongSelf = self {
                LoginViewController.fetchAuthCode(strongSelf, phone: { () -> String? in
                    if !strongSelf.accountTextField.text!.checkStingIsPhone()  {
                        ZMDTool.showPromptView( "请正确填写手机号码")
                        strongSelf.accountTextField.text = nil
                        strongSelf.accountTextField.becomeFirstResponder()
                        return nil
                    }
                    else {
                        return strongSelf.accountTextField.text!
                    }
                    }, authCodeButton: strongSelf.getVerificationBtn, isRegister: true)
            }
        }
    }
    func login() {
        if !self.checkAccountPassWord() {return}
        if let phone = self.accountTextField.text,let code = self.verificationTextField.text , let psw = self.verificationTextField.text {
            QNNetworkTool.registerAndLogin(phone, code: code, psw: psw, completion: { (success, error, dictionary) -> Void in
                if success! {
                    ZMDTool.showPromptView("成功")
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    ZMDTool.enterRootViewController(vc!)
                } else {
                    ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "失败")
                }
            })
        }
    }

    
    // 判断输入的合法性
    private func checkAccountPassWord() -> Bool {
        if (self.accountTextField.text?.characters.count == 0 && self.verificationTextField.text?.characters.count == 0) {
            ZMDTool.showPromptView("请输入账号与密码")
            self.accountTextField.becomeFirstResponder()
            return false
        }else if(self.accountTextField.text?.characters.count == 0) {
            ZMDTool.showPromptView("请输入帐号")
            self.verificationTextField.becomeFirstResponder()
            return false
            
        }else if (self.verificationTextField.text?.characters.count == 0){
            ZMDTool.showPromptView("请输入验证码")
            self.verificationTextField.becomeFirstResponder()
            return false
        }else if (self.psTextField.text?.characters.count == 0){
            ZMDTool.showPromptView("请输入密码")
            self.psTextField.becomeFirstResponder()
            return false
        }
        return true
    }
}
