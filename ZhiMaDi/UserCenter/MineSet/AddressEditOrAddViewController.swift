//
//  AddressEditOrAddViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/2.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//编辑或增加收货地址
class AddressEditOrAddViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView: UITableView!
    var usrNameTextFidld : UITextField!,phoneTextFidld : UITextField!,codeTextFidld : UITextField!,addressTextFidld : UITextField!
    var areaLbl : UILabel! // 所在地区
    var swithBtn : UISwitch!
    var isAdd : Bool = true //默认为添加地址
    let titles = ["收件人 : ","手机号码 : ","收货地址 : "/*,"邮政编码 : "*/,"详细地址 : ","设为默认地址 : "]

    let titles2 = ["选择配送方式:","快递送货上门","收件人 : ","手机号码 : ","收货地址 : ","邮政编码 : ","详细地址 : ","设为默认地址 : "]
    let titles3 = ["选择配送方式:","快递送货上门","收件人 : ","手机号码 : ","选择区域 : ","邮政编码 : ","选择网点 : ","设为默认地址 : "]
    var addressId = ""
    var address : ZMDAddress!
    
    var isToHome : Bool = true
    var peiSongView :UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titles.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        /* 农资if section == 2 {
            return 10
        } else {
            return 1
        }*/
        //农产品
        if section == 0 {
            return 10
        }else{
            return 1
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
            return view
        }else{
            return nil
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let title = self.titles[indexPath.section]
        switch title {
        case "选择配送方式:" :
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                cell?.backgroundColor = tableViewdefaultBackgroundColor
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            cell?.textLabel?.textColor = UIColor.darkGrayColor()
            return cell!
        case "快递送货上门" :
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.isToHome ? "快递送货上门" : "网点代收"
            let btn = UIButton(frame: CGRect(x: kScreenWidth-40, y: 8, width: 40, height: 40))
            btn.setImage(UIImage(named: "btn_Arrow_TurnDown1@2x"), forState: .Normal)
            cell?.contentView.addSubview(btn)
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                //选择配送方式
                self.createPeiSongView()
                self.viewShowWithBg(self.peiSongView, showAnimation: ZMDPopupShowAnimation.SlideInFromTop, dismissAnimation: ZMDPopupDismissAnimation.SlideOutToTop)
                return RACSignal.empty()
            })
            return cell!
        case  "收件人 : ":
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.usrNameTextFidld == nil {
                self.usrNameTextFidld = UITextField(frame: CGRect(x: 20 + size.width, y: 0, width: kScreenWidth - 20 - size.width - 12, height: 56))
                self.usrNameTextFidld.font = defaultSysFontWithSize(17)
                cell?.contentView.addSubview(self.usrNameTextFidld)
            }
            if self.address != nil {
                self.usrNameTextFidld.text = self.address.FirstName
            }
            return cell!
        case "手机号码 : " :
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.phoneTextFidld == nil {
                self.phoneTextFidld = UITextField(frame: CGRect(x: 20 + size.width, y: 0, width: kScreenWidth - 20 - size.width - 12, height: 56))
                self.usrNameTextFidld.font = defaultSysFontWithSize(17)
                cell?.contentView.addSubview(self.phoneTextFidld)
            }
            if self.address != nil {
                self.phoneTextFidld.text = self.address.PhoneNumber
            }
            return cell!
        case "收货地址 : ":
            //收货地址（选择区域）
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
//            cell?.textLabel?.text = self.isToHome ? "选择地址" : "选择区域"   //农资
            
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.areaLbl == nil {
                self.areaLbl = ZMDTool.getLabel( CGRect(x: 20 + size.width, y: 0, width: kScreenWidth - 20 - size.width - 12, height: 56), text: "", fontSize: 17)
                areaLbl.text  = "省/市/区"
                areaLbl.textColor = UIColor.lightGrayColor()
                cell?.contentView.addSubview(self.areaLbl)
            }
            if self.address != nil {
                self.areaLbl.text = self.address.Address1
            }
            return cell!
        case "邮政编码 : " :
            //邮政编码
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.codeTextFidld == nil {
                self.codeTextFidld = UITextField(frame: CGRect(x: 20 + size.width, y: 0, width: kScreenWidth - 20 - size.width - 12, height: 56))
                self.codeTextFidld.font = defaultSysFontWithSize(17)
                cell?.contentView.addSubview(self.codeTextFidld)
            }
            if self.address != nil {
                self.codeTextFidld.text = self.address.FaxNumber ?? ""
            }
            return cell!
        case "详细地址 : " :
            //详细地址(选择网点)
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
//            cell?.textLabel?.text = self.isToHome ? "详细地址" : "选择网点"   //农资
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.addressTextFidld == nil {
                self.addressTextFidld = UITextField(frame: CGRect(x: 20 + size.width, y: 0, width: kScreenWidth - 20 - size.width - 12, height: 56))
                self.addressTextFidld.font = defaultSysFontWithSize(17)
                cell?.contentView.addSubview(self.addressTextFidld)
            }
            self.addressTextFidld.placeholder = self.isToHome ? " " : "请选择代收网点"
            if self.address != nil {
                self.addressTextFidld.text = self.address.Address2 ?? ""
            }
            return cell!
        case "设为默认地址 : " :
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                
                if self.swithBtn == nil {
                    self.swithBtn = UISwitch(frame: CGRect(x: kScreenWidth - 12 - 56, y: 14, width: 56, height: 28))
                    cell?.contentView.addSubview(swithBtn)
                    if !self.isAdd && self.address != nil {
                        self.swithBtn.on = self.address.IsDefault.boolValue
                    }
                }
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            
            return cell!
        default :
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "cell\(2)" {
//        if self.titles[indexPath.section] == "所在地区 : " {
            self.view.endEditing(true)
            let areaView = ZMDAreaView(frame: CGRect(x: 0, y: kScreenHeight-400, width: kScreenWidth, height: 400))
            areaView.finished = { (address,addressId) ->Void in
                self.areaLbl.text = address
                self.addressId = addressId
                self.dismissPopupView(areaView)
            }
            self.viewShowWithBg(areaView,showAnimation: .SlideInFromBottom,dismissAnimation: .SlideOutToBottom)
        }
    }
    //MARK:- Private Method
    private func subViewInit(){
        if self.isAdd {
            self.title = "添加收货地址"
        } else {
            self.title = "编辑收货地址"
        }
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
        let fotView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        fotView.backgroundColor = UIColor.clearColor()
        let saveBtn = ZMDTool.getButton(CGRect(x: 12, y: 45, width: kScreenWidth - 24, height: 50), textForNormal: "保存", fontSize: 20, textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(235,61,61,1.0)) { (sender) -> Void in
            self.addAddress()
        }
        ZMDTool.configViewLayerWithSize(saveBtn, size: 25)
        fotView.addSubview(saveBtn)
        self.currentTableView.tableFooterView = fotView
    }
    
    private func checkData() -> Bool {
        if usrNameTextFidld.text == nil || usrNameTextFidld.text == "" {
            ZMDTool.showPromptView("请输入姓名")
            return false
        } else if phoneTextFidld.text == nil || phoneTextFidld.text == "" {
            ZMDTool.showPromptView("请输入手机号")
            return false
        } else if !phoneTextFidld.text!.checkStingIsPhoneNum() {
            ZMDTool.showPromptView("请输入有效手机号")
            return false
        }  else if areaLbl.text == nil || areaLbl.text == "省/市/区" || areaLbl.text == "" {
            //nil和“省/市/区”以及 “”都是没有选择地区
            ZMDTool.showPromptView("请选择所在地区")
            return false
        } else if addressTextFidld.text == nil || addressTextFidld.text == "" {
            ZMDTool.showPromptView("请输入街道地址")
            return false
        }
        return true
    }
    
    func updateAddress() -> ZMDAddress{
        let address = self.isAdd ? ZMDAddress() : self.address
        address.FirstName = usrNameTextFidld.text
        address.PhoneNumber = phoneTextFidld.text
        address.Address1 = areaLbl.text
        address.Address2 = addressTextFidld.text
        address.AreaCode = self.addressId == ""  ? address.AreaCode : self.addressId
        address.IsDefault = self.swithBtn.on
        address.City = "市辖区"
        address.CountryId = 23
//        address.FaxNumber = self.codeTextFidld.text
        return address
    }
    
    func addAddress() {
        if !self.checkData() {
            return
        }
        QNNetworkTool.addOrEditAddress(self.updateAddress()) { (succeed, error, dictionary) -> Void in
            if succeed! {
                ZMDTool.showPromptView(self.isAdd ? "添加成功" : "保存成功")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: self.isAdd ? "添加不成功" : "保存不成功")
            }
        }
    }
    
    //MARK:创建配送选择View
    func createPeiSongView() {
        self.peiSongView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56*2 + 1))
        self.peiSongView.backgroundColor = UIColor.whiteColor()
        let peiSongTitle = ["快递送货上门","网点代收"]
        var index = 0
        for title in peiSongTitle {
            let btn = UIButton(frame: CGRect(x: 0, y: CGFloat(index)*(56+1), width: kScreenWidth, height: 56))
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            peiSongView.addSubview(btn)
            btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.dismissPopupView(self.peiSongView)
                self.peiSongView.removeFromSuperview()
                if title == "快递送货上门" {
                    self.isToHome = true
                } else {
                    self.isToHome = false
                }
                self.currentTableView.reloadData()
                return RACSignal.empty()
            })
            index++
        }
        let line = ZMDTool.getLine(CGRect(x: 0, y: 56, width: kScreenWidth, height: 1), backgroundColor: defaultLineColor)
        self.peiSongView.addSubview(line)
    }
}
