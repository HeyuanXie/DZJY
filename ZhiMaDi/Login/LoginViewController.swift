//
//  LoginViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 登录
class LoginViewController: UIViewController , ZMDInterceptorNavigationBarHiddenProtocol,UITextFieldDelegate, ShareSDKThirdLoginHelperDelegate{

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var otherLoginBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var invisiable: UIButton!
    
    @IBOutlet weak var rightBar: UIBarButtonItem!
    
    override func awakeFromNib() {
        self.view.bringSubviewToFront(self.thirdView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.configBackButton()
        // 如果有本地账号了，就自动登录
        self.autoLogin()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBarHidden = false
        self.view.backgroundColor = tableViewdefaultBackgroundColor
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: shareThirdLoginHelperDelegate
    func loginWithName(nickName: String!, andPassWord password: String!, andIcon icon: String!) {
        //利用传过来的用户信息注册登陆
//        QNNetworkTool.registerAndLogin(<#T##mobile: String##String#>, code: <#T##String#>, psw: <#T##String#>, completion: <#T##(success: Bool!, error: NSError?, dictionary: NSDictionary?) -> Void#>)

        /*
        let alert = UIAlertController(title: "用户信息", message: "nickName:\(nickName) password:\(password)", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            alert.removeFromParentViewController()
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
        */
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            self.verificationTextField.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
            self.login()
        }
        return true
    }
    
    
    // @IBAction
    // MARK: 登录
    @IBAction func login(sender: UIButton) {
        self.login()
    }
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
        self.accountTextField.returnKeyType = .Next
        self.accountTextField.delegate = self
        
        let passwordImageView = UIImageView(frame: CGRectMake(10, 0, 40, 20))
        passwordImageView.contentMode = UIViewContentMode.ScaleAspectFit
        passwordImageView.image = UIImage(named: "login_password")
        self.verificationTextField.leftView = passwordImageView
        self.verificationTextField.leftViewMode =  UITextFieldViewMode.Always
        self.verificationTextField.secureTextEntry = true
        self.verificationTextField.returnKeyType = .Done
        self.verificationTextField.delegate = self
        
        self.invisiable.setImage(UIImage(named: "login_visible"), forState: .Selected)
        self.invisiable.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as! UIButton).selected = !(sender as! UIButton).selected
            self.verificationTextField.secureTextEntry = !(sender as! UIButton).selected
            return RACSignal.empty()
        })
        ZMDTool.configViewLayerWithSize(self.loginBtn, size: 25)
        
        // 键盘消失
        let tap = UITapGestureRecognizer()
        tap.rac_gestureSignal().subscribeNext { [weak self](tap) -> Void in
            self?.view.endEditing(true)
        }
    
        self.view.addGestureRecognizer(tap)
        
        let xhyThirdView = UIView(frame:self.thirdView.frame)
        self.view.addSubview(xhyThirdView)
        let xhyThirdLabel = UILabel(frame: self.thirdLabel.frame)
        xhyThirdLabel.textAlignment = .Center
        xhyThirdLabel.center.x = self.view.center.x
        xhyThirdLabel.textColor = defaultTextColor
        xhyThirdLabel.text = "第三方登陆"
        self.view.addSubview(xhyThirdLabel)
        
        let thirdTitle = ["微信","微博","QQ"]
        let thirdImage = ["common_share_wechat","common_share_weibo","common_share_qq"]
        var i = CGFloat(0)
        for title in thirdTitle {
            //105 50 50 
            let width = CGFloat(50),height = CGFloat(75)
            let x = 25+width*i + 50*i
            //ZMDTool.getBtn得到图和文字垂直的自定义btn
            let btn = ZMDTool.getBtn(CGRect(x: x, y: 0, width: width, height: height))
            btn.setImage(UIImage(named:thirdImage[Int(i)]), forState: .Normal)
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.titleLabel?.font = defaultSysFontWithSize(15)
            btn.tag = 100 + Int(i)
            xhyThirdView.addSubview(btn)
            if btn.tag == 101 {
                btn.center.x = self.view.center.x
            }
            if btn.tag == 102 {
                let secondBtn = xhyThirdView.viewWithTag(101) as! UIButton
                btn.frame = CGRect(x: CGRectGetMaxX(secondBtn.frame) + CGRectGetMinX(secondBtn.frame) - 25 - width, y: 0, width: width, height: height)
            }
            btn.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext({ (sender) -> Void in
                let thirdLoginHelper = ShareSDKThirdLoginHelper() 
                thirdLoginHelper.delegate = self
                ShareSDKThirdLoginHelper().loginWithIndex(sender.tag - 100)
            })
            i++
        }
    }
    
    func login() {
        if !self.checkAccountPassWord() {return}
        if let usrN = self.accountTextField.text, let ps = self.verificationTextField.text {
            QNNetworkTool.loginAjax(usrN, Password: ps, completion: { (success, error, dictionary) -> Void in
                if success! {
                    saveAccountAndPassword(usrN, password: ps)
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
            ZMDTool.showPromptView("请输入账号与密码")
            self.accountTextField.becomeFirstResponder()
            return false
        }else if(self.accountTextField.text?.characters.count == 0) {
            ZMDTool.showPromptView("请输入账号")
//            改
//            self.verificationTextField.becomeFirstResponder()
            self.accountTextField.becomeFirstResponder()
            return false
        }else if (self.verificationTextField.text?.characters.count == 0){
            ZMDTool.showPromptView("请输入密码")
//            改
//            self.accountTextField.becomeFirstResponder()
            self.verificationTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    override func back() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        ZMDTool.enterRootViewController(vc!)
    }
}
// MARK: - 获取验证码UI 显示的超时时间
private let overTimeMax = 60
// MARK: - 获取验证码的支持
extension LoginViewController {
    // MARK: 验证码
    // 从服务器获取验证码
    
    class func fetchAuthCode(viewController: UIViewController, phone: (() -> String?), authCodeButton: UIButton?, isRegister: Bool) {
        // where phoneNum > 0
        if let phoneNum = phone(){
            ZMDTool.showActivityView("正在获取验证码...", inView: viewController.view)
            if isRegister {
                QNNetworkTool.sendCode(phoneNum, completion: { (success, error, dictionary) -> Void in
                    ZMDTool.hiddenActivityView()
                    if success! {
                        ZMDTool.showPromptView( "验证码已发送到你手机", nil)
                        self.waitingAuthCode(authCodeButton, start: true)
                    }
                    else {
                        ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
                    }
                })
            }else{}
        }
    }
    // 显示获取验证码倒计时
    class func waitingAuthCode(button: UIButton!, start: Bool = false) {
        if button == nil { return } // 验证码的UI变化，如果没有button，则不会有变化
        
        let overTimer = button.tag
        if overTimer == 0 && start {
            button.tag = overTimeMax
        }
        else {
            button.tag = max(overTimer - 1, 0)
        }
        
        if button.tag == 0 {
            button.setTitle("获取验证码", forState: .Normal)
            button.backgroundColor = UIColor.clearColor()
            button.setTitleColor(UIColor.grayColor(), forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
            button.enabled = true
        }
        else {
            button.setTitle("\(button.tag)S", forState: .Normal)
            button.backgroundColor = UIColor.whiteColor()
            button.setTitleColor(appThemeColor, forState: .Normal)
            button.enabled = false
            button.setNeedsLayout()
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(1) * NSEC_PER_SEC)), dispatch_get_main_queue(), { () in
                self.waitingAuthCode(button)
            })
        }
    }
}

