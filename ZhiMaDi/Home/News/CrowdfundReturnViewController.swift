//
//  CrowdfundReturnViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/12.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 众筹回报
class CrowdfundReturnViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    
    enum CellType{
        case Project
        case Originator
        case SupportMoney
        case DistributionMoney
        case Return
        
        case Mark
        
        case Address
        
        init(){
            self = Project
        }
        var height : CGFloat {
            switch self{
            case Return:
                return 260
            case Mark:
                return 100
            case Address:
                return 54
            default :
                return 56
            }
        }
        var title : String{
            switch self{
            case Project :
                return "项目:"
            case Originator :
                return "发起人:"
            case SupportMoney :
                return "支付金额:"
            case DistributionMoney:
                return "配送费用:"
            case Return:
                return "回报内容:"
            case Mark:
                return "备注:"
            case Address:
                return "选择收货地址:"
            }
        }
    }
    
    var currentTableView: UITableView!
    var markTextField : UITextField!
    var celltypes: [[CellType]]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.celltypes[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.celltypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let type = self.celltypes[indexPath.section][indexPath.row]
        return type.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type = self.celltypes[indexPath.section][indexPath.row]
        switch type {
        case .Return :
            let cellId = "ReturnCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            let titleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 20, width: 200, height: 17), text: "回报内容", fontSize: 17)
            cell?.contentView.addSubview(titleLbl)
            let detailText = "支持5600元，获得彩色气球系列1301A儿童雄鹿一张，店铺无门槛50元优惠券1张\n\n限额50位，剩余26位\n预计回报发放时间 ：项目短款成功后的30天内"
            let detailSize = detailText.sizeWithFont(UIFont.systemFontOfSize(17), maxWidth: kScreenWidth - 24)
            let detailLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(titleLbl.frame), width: kScreenWidth - 24, height: detailSize.height), text: detailText, fontSize: 17,textColor: defaultDetailTextColor)
            detailLbl.numberOfLines = 0
            cell?.contentView.addSubview(detailLbl)
            let imgV = UIImageView(frame: CGRect(x: 12, y: 260-20-75, width: 75, height: 75))
            imgV.image = UIImage(named: "product_pic")
            cell?.contentView.addSubview(imgV)
            return cell!
        case .Mark :
            let cellId = "MarkCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                let lbl =  ZMDTool.getLabel(CGRect(x: 12, y: 20, width: 200, height: 17), text: "备注：", fontSize: 17)
                cell?.contentView.addSubview(lbl)
                markTextField = ZMDTool.getTextField(CGRect(x: 12, y: CGRectGetMaxY(lbl.frame)+6, width: kScreenWidth-12, height: 60), placeholder: "给项目人发起留言", fontSize: 17)
                cell?.contentView.addSubview(markTextField)
            }
            return cell!
        case .Address :
            let cellId = "AddressCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                
                cell?.imageView?.image = UIImage(named: "pay_select_adress")
                let numLbl = ZMDTool.getLabel(CGRect(x: 46, y: 0, width: 300, height: 55), text: "选择收获地址", fontSize: 17)
                cell?.contentView.addSubview(numLbl)
            }
            return cell!
        default :
            let cellId = "OtherCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            var title = ""
            switch type {
            case .Project:
                title = "\(type.title)彩色气球系列"
                break
            case .Originator:
                title = "\(type.title)葫芦堡旗舰店"
                break
            case .SupportMoney:
                title = "\(type.title)5600.0"
                break
            case .DistributionMoney:
                title = "\(type.title)免运费"
                break
            default :
                break
            }
        cell?.textLabel!.text = title
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.celltypes[indexPath.section][indexPath.row]
        switch cellType{
        case .Return :
            //选择收货地址
            break
        default:
            break
        }
    }
    //MARK:Private Method
    //    func configHead() {
    //
    //    }
    func updateUI() {
        self.title = "众筹"
        var frame = self.view.bounds
        frame.size.height = frame.size.height - 56 - 64
        self.currentTableView = UITableView(frame: frame)
        self.currentTableView.backgroundColor  = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        self.configeBottomView()
    }
    private func dataInit(){
        self.celltypes = [[.Project,.Originator,.SupportMoney,.DistributionMoney,.Return], [.Mark],[.Address]]
    }
    func configeBottomView() {
        let bottomV = UIView(frame: CGRect(x: 0, y: kScreenHeight - 64 - 56, width: kScreenWidth, height: 56))
        bottomV.backgroundColor = RGB(247,247,247,1)
        self.view.addSubview(bottomV)
        let consultationBtn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 100, height: 56), textForNormal: "咨询", fontSize: 17, backgroundColor: UIColor.clearColor()) { (sender) -> Void in
        }
        consultationBtn.setImage(UIImage(named: "product_chat"), forState: .Normal)
        bottomV.addSubview(consultationBtn)
        let supportBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 110-12, y: 10, width: 110, height: 36), textForNormal: "去支持", fontSize: 17,textColorForNormal:UIColor.whiteColor(), backgroundColor: RGB(66,221,211,1)) { (sender) -> Void in
        }
        ZMDTool.configViewLayerWithSize(supportBtn, size: 18)
        bottomV.addSubview(supportBtn)
    }

}
