//
//  LoginWithCodeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/18.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class LoginWithCodeViewController: UIViewController , ZMDInterceptorNavigationBarHiddenProtocol, UITextFieldDelegate{
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var otherLoginBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var rightBar: UIBarButtonItem!
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
            self.login()
        }
        return false
    }
    
    // @IBAction
    // MARK: 登录
    @IBAction func login(sender: UIButton) {
        self.login()
    }
    //    @IBAction func goBack(sender: UIButton) {
    //        if self.getVerificationBtn == nil {
    //            self.navigationController?.popToRootViewControllerAnimated(true)
    //        } else {
    //            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    //            ZMDTool.enterRootViewController(vc!)
    //        }
    //    }
    //回到帐户登录
    @IBAction func accountBtnCli(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - PrivateMethod
    func updateUI() {
        // 进一步配置账号和密码输入UI
        let accountImageView = UIImageView(frame: CGRectMake(10, 0, 40, 20))
        accountImageView.contentMode = UIViewContentMode.ScaleAspectFit
        accountImageView.image = UIImage(named: "login_account")
        self.accountTextField.leftView = accountImageView
        self.accountTextField.leftViewMode =  UITextFieldViewMode.Always
        self.accountTextField.text = g_Account
        
        let passwordImageView = UIImageView(frame: CGRectMake(10, 0, 40, 20))
        passwordImageView.contentMode = UIViewContentMode.ScaleAspectFit
        passwordImageView.image = UIImage(named: "login_password")
        self.verificationTextField.leftView = passwordImageView
        self.verificationTextField.leftViewMode =  UITextFieldViewMode.Always
        
        ZMDTool.configViewLayerWithSize(self.loginBtn, size: 25)
        
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
        
        
        //这里是在LoginViewController拓展中定义的类方法，用于获取验证码
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
        
        let thirdTitle = ["微信","微博","QQ"]
        let thirdImage = ["common_share_wechat","common_share_weibo","common_share_qq"]
        var i = CGFloat(0)
        for title in thirdTitle {
            //105 50 50
            let width = CGFloat(50),height = CGFloat(75)
            let x = 25+width*i + 50*i
            let btn = ZMDTool.getBtn(CGRect(x: x, y: 0, width: width, height: height))
            btn.setImage(UIImage(named:thirdImage[Int(i)]), forState: .Normal)
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.titleLabel?.font = defaultSysFontWithSize(15)
            self.thirdView.addSubview(btn)
            i++
        }
    }
    func login() {
        if !self.checkAccountPassWord() {return}
        if let phone = self.accountTextField.text, let code = self.verificationTextField.text {
            QNNetworkTool.loginWithPhoneCode(phone, code: code, completion: { (success, error, dictionary) -> Void in
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
    
    // MARK: 登录，并把accoutn和password写入的页面上
    func login(account: String, password: String) {
        self.accountTextField.text = account
        self.verificationTextField.text = password
        self.login()
    }
    
    // MARK: 自动登录，获取本机保存的账号密码进行登录
    func autoLogin() {
        if let account = g_Account, password = g_Password {
            self.login(account, password: password)
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
            self.verificationTextField.becomeFirstResponder()
            return false
            
        }else if (self.verificationTextField.text?.characters.count == 0){
            ZMDTool.showPromptView("请输入验证码")
            self.accountTextField.becomeFirstResponder()
            return false
        }
        return true
    }
}
