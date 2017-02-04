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
    var defaultBtn : UIButton!
    var isAdd : Bool = true //默认为添加地址
    let titles = ["联系人 : ","手机号 : ","所在地 : ","邮政编码 : ","详细地址 : "]

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
            return 0.5
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == self.titles.count-1 ? zoom(55) : 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if self.titles[indexPath.section] == "详细地址 : " {
//            return 50
//        }
        return zoom(50)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
            return view
        }else{
            return nil
        }
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.titles.count-1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(55)))
            self.defaultBtn = UIButton(frame: CGRect.zero)
            self.defaultBtn.setImage(UIImage(named: "cb_glossy_off"), forState: .Normal)
            self.defaultBtn.setImage(UIImage(named: "cb_glossy_on"), forState: .Selected)
            self.defaultBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                (sender as! UIButton).selected = !(sender as! UIButton).selected
                return RACSignal.empty()
            })
            view.addSubview(self.defaultBtn)
            let label = ZMDTool.getLabel(CGRect.zero, text: "设为默认地址", fontSize: 14)
            label.textColor = defaultTextColor
            label.textAlignment = .Center
            view.addSubview(label)
            label.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(0)
                make.right.equalTo(-(zoom(10)))
                make.height.equalTo(zoom(55))
                make.width.equalTo(zoom(100))
            })
            self.defaultBtn.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(zoom(20))
                make.right.equalTo(label.snp_left).offset(-zoom(5))
                make.width.equalTo(zoom(15))
                make.height.equalTo(zoom(15))
            })
            return view
        }
        return nil
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
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
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
            cell?.textLabel?.text = self.titles[indexPath.section]
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
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
        case  "联系人 : ":
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(14), maxWidth: 320)
            if self.usrNameTextFidld == nil {
                self.usrNameTextFidld = UITextField(frame: CGRect(x: zoom(20) + size.width, y: 0, width: kScreenWidth - zoom(20) - size.width - zoom(12), height: zoom(50)))
                self.usrNameTextFidld.textColor = defaultTextColor
                self.usrNameTextFidld.font = defaultSysFontWithSize(14)
                cell?.contentView.addSubview(self.usrNameTextFidld)
            }
            if self.address != nil {
                self.usrNameTextFidld.text = self.address.FirstName
            }
            return cell!
        case "手机号 : " :
            let cellId = "cell\(indexPath.section)"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = self.titles[indexPath.section]
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(14), maxWidth: 320)
            if self.phoneTextFidld == nil {
                self.phoneTextFidld = UITextField(frame: CGRect(x: zoom(20) + size.width, y: 0, width: kScreenWidth - zoom(20) - size.width - zoom(12), height: zoom(50)))
                self.phoneTextFidld.textColor = defaultTextColor
                self.phoneTextFidld.font = defaultSysFontWithSize(14)
                cell?.contentView.addSubview(self.phoneTextFidld)
            }
            if self.address != nil {
                self.phoneTextFidld.text = self.address.PhoneNumber
            }
            return cell!
        case "所在地 : ":
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
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
            
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(14), maxWidth: 320)
            if self.areaLbl == nil {
                self.areaLbl = ZMDTool.getLabel( CGRect(x: zoom(20) + size.width, y: 0, width: kScreenWidth - zoom(20) - size.width - zoom(12), height: zoom(50)), text: "", fontSize: 14)
                areaLbl.text  = "省/市/区"
                areaLbl.textColor = defaultDetailTextColor
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
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.codeTextFidld == nil {
                self.codeTextFidld = UITextField(frame: CGRect(x: zoom(20) + size.width, y: 0, width: kScreenWidth - zoom(20) - size.width - zoom(12), height: zoom(50)))
                self.codeTextFidld.font = defaultSysFontWithSize(14)
                self.codeTextFidld.textColor = defaultTextColor
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
            cell?.textLabel?.textColor = defaultTextColor
            cell?.textLabel?.font = UIFont.systemFontOfSize(14)
            let size = self.titles[indexPath.section].sizeWithFont(defaultSysFontWithSize(17), maxWidth: 320)
            if self.addressTextFidld == nil {
                self.addressTextFidld = UITextField(frame: CGRect(x: zoom(20) + size.width, y: 0, width: kScreenWidth - zoom(20) - size.width - zoom(12), height: zoom(50)))
                self.addressTextFidld.font = defaultSysFontWithSize(14)
                self.addressTextFidld.textColor = defaultTextColor
                cell?.contentView.addSubview(self.addressTextFidld)
            }
            self.addressTextFidld.placeholder = self.isToHome ? " " : "请选择代收网点"
            if self.address != nil {
                self.addressTextFidld.text = self.address.Address2 ?? ""
            }
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
        self.title = self.isAdd ? "新建收货地址" : "编辑收货地址"
   
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        self.currentTableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(-50)
        }
        self.viewForFoot()
    }
    
    func viewForFoot() {
        if self.isAdd {
            self.addBottomBtn(blockForCli: { (sender) -> Void in
                self.addAddress()
            })
        }else{
            self.addBottomBtns(["删除","保存"], colors: [RGB(239,67,70,1.0),appThemeColor])
            let bgView = self.view.viewWithTag(66666)
            for i in 0..<2 {
                let btn = bgView?.viewWithTag(1000+i) as! UIButton
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    if i==0 {
                        self.deleteAddress()
                    }else{
                        self.addAddress()
                    }
                    return RACSignal.empty()
                })
            }
        }
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
        address.IsDefault = self.defaultBtn.selected
        address.City = "市辖区"
        address.CountryId = 23
//        address.FaxNumber = self.codeTextFidld.text
        return address
    }
    
    
    func deleteAddress() {
        QNNetworkTool.deleteAddress(self.address.Id.integerValue, customerId: g_customerId!, completion: { (succeed, dictionary,error) -> Void in
            if error == nil {
                ZMDTool.showPromptView("删除成功")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "")
            }
        })

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
