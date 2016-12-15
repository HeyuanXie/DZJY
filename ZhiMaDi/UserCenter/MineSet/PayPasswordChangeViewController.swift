//
//  PayPasswordChangeViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/13.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//设置支付密码
class PayPasswordChangeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol,ZMDInterceptorKeyboardProtocol {
    enum CellType {
        case Phone,Code,Password1,Password2
        init() {
            self = .Phone
        }
        
        var title : String {
            switch self {
            case .Phone:
                return "  请输入手机号"
            case .Code:
                return "  验证码"
            case .Password1:
                return "  * 输入支付密码"
            case .Password2:
                return "  * 再次输入支付密码"
            }
        }
    }
    enum ContentType {
        case Code,Password
    }
    var currentTableView : UITableView!
    var contentType = ContentType.Code
    var cellTypes : [CellType]!
    private let kFirstTfTag = 10000
    private let kSecondTfTag = 10001
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataInit()
        self.initUI()
        // Do any additional setup after loading the view.
    }

    
    
    //MARK: - PrivateMethod
    private func dataInit() {
        self.cellTypes = self.contentType == .Code ? [CellType.Phone,.Code] : [CellType.Password1,.Password2]
    }
    
    private func initUI() {
        //设置footView
        self.title = "设置支付密码"
        if self.contentType == .Code {
            self.addBottomBtn("下一步", color: appThemeColor) { (sender) -> Void in
                let vc = PayPasswordChangeViewController()
                vc.contentType = .Password
                self.pushToViewController(vc, animated: true, hideBottom: true)
            }
        }else{
            self.addBottomBtn("确定修改", color: appThemeColor, blockForCli: { (sender) -> Void in
                //...修改密码
                
            })
        }
        
        //设置tableView
        self.currentTableView = UITableView(frame: CGRect.zero, style: .Plain)
        self.currentTableView.separatorStyle = .None
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.delegate = self
        self.currentTableView.dataSource = self
        self.view.addSubview(self.currentTableView)
        self.currentTableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-50)
        }
    }
    
    
    
    //MARK: - TableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellTypes.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return zoom(43)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellType = self.cellTypes[section]
        let label = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(43)), text: cellType.title, fontSize: 15, textColor: defaultTextColor, textAlignment: .Left)
        if self.contentType == .Password {
            label.attributedText = cellType.title.AttributedText("*", color: appThemeColor)
        }
        return label
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "textFieldCell\(indexPath.section)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 52))
            textField.tag = 10000+indexPath.section
            textField.delegate = self
            cell?.contentView.addSubview(textField)
        }
        
        return cell!
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    //MARK: - OverrideMethod
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
