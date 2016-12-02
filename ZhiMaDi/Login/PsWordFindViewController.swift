//
//  PsWordFindViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/1.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 找回登录密码
class PsWordFindViewController: UIViewController, ZMDInterceptorNavigationBarHiddenProtocol, UITextFieldDelegate{
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var psTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var getVerificationBtn: UIButton!  //  getVerificationBtn == nil ？ 密码登录 ： 验证码登录
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = false
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
        }
        return false
    }
    
    //MARK: - PrivateMethod
    func updateUI() {
        // 进一步配置账号和密码输入UI
        let configLeftView = { (textField : UITextField, imageName: String) -> Void in
            let tmpV = UIImageView(frame: CGRectMake(10, 0, 40, 20))
            tmpV.contentMode = UIViewContentMode.ScaleAspectFit
            tmpV.image = UIImage(named: imageName)
            textField.leftView = tmpV
            textField.leftViewMode =  UITextFieldViewMode.Always
        }
        configLeftView(self.accountTextField, "login_account")
        configLeftView(self.verificationTextField, "login_password")
        configLeftView(self.psTextField, "login_password")
        ZMDTool.configViewLayerWithSize(self.confirmBtn, size: 12)
        confirmBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            if !self.checkAccountPassWord() {
                return RACSignal.empty()
            }
            if let phone = self.accountTextField.text,let code = self.verificationTextField.text , let psw = self.psTextField.text {
                QNNetworkTool.changePassword(phone, code: code, psw: psw, completion: { (success, error, dictionary) -> Void in
                    if success! {
                        ZMDTool.showPromptView("修改成功")
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "修改失败")
                    }
                })
            }
            return RACSignal.empty()
        })
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
        self.view.addGestureRecognizer(tap)
        
        let codeRightV = UIView(frame: CGRect(x: 0, y: 0, width: 92+12, height: 60))
        codeRightV.backgroundColor = UIColor.clearColor()
        // 获取验证码的按钮
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
                        ZMDTool.showPromptView( "请填写手机号码")
                        strongSelf.accountTextField.text = nil; strongSelf.accountTextField.becomeFirstResponder()
                        return nil
                    }
                    else {
                        return strongSelf.accountTextField.text!
                    }
                    }, authCodeButton: strongSelf.getVerificationBtn, isRegister: true)
            }
        }
    }
    
    // 判断输入的合法性
    private func checkAccountPassWord() -> Bool {
        if (self.accountTextField.text?.characters.count == 0 && self.verificationTextField.text?.characters.count == 0) {
            ZMDTool.showPromptView("请输入手机号和验证码")
            self.accountTextField.becomeFirstResponder()
            return false
        }else if(self.accountTextField.text?.characters.count == 0) {
            ZMDTool.showPromptView("请输入手机号")
            self.accountTextField.becomeFirstResponder()
            return false
            
        }else if (self.verificationTextField.text?.characters.count == 0){
            ZMDTool.showPromptView("请输入验证码")
            self.verificationTextField.becomeFirstResponder()
            return false
        }
        return true
    }
}
