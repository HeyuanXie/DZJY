//
//  InvoiceTypeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/31.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 选择发票类型
class InvoiceTypeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    var invoiceStrTextF : UITextField!
    var tableView : UITableView!
    var datas : ZMDPublicInfo!
    var indexTypeRow = 0,indexCategoryRow = 0,indexDetailRow = 0
    var invoiceFinish : NSDictionary?
    var finished : ((dic:NSDictionary?)->Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择发票类型"
        let rightBar = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        rightBar.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            return RACSignal.empty()
        })
        rightBar.tintColor = defaultTextColor
        self.navigationController?.navigationItem.rightBarButtonItem = rightBar
        self.updateUI()
        self.dataUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.datas.getTypes().count
        }else{
            return section == 1 ? self.datas.getCategorys().count : self.datas.getBodys().count
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.datas == nil ? 0 : 3
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? 57 : 12
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 57))
            headView.backgroundColor = UIColor.clearColor()
            let label = ZMDTool.getLabel(CGRect(x: 12, y: 30, width: 100, height: 17), text: "发票明细", fontSize: 17)
            headView.addSubview(label)
            return headView
        }
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 12))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell\(indexPath.section)\(indexPath.row)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
            let imgV = UIImageView(frame: CGRect(x: kScreenWidth - 12 - 14, y: 15, width: 14, height: 25))
            imgV.image = UIImage(named: "pay_selected")
            imgV.tag = 10001
            imgV.hidden = true
            cell?.contentView.addSubview(imgV)
        }
        var text = ""
        if indexPath.section == 0 {
            text = self.datas.getTypes()[indexPath.row]
        }else if indexPath.section == 1 {
            text = self.datas.getCategorys()[indexPath.row]
        } else {
            text = self.datas.getBodys()[indexPath.row]
        }
        cell?.textLabel?.text = text
        if text == "企业" && self.invoiceStrTextF == nil {
            let textField = UITextField(frame: CGRect(x: 64, y: 0, width: kScreenWidth - 64 - 12, height: 55))
            textField.textColor = defaultDetailTextColor
            textField.font = defaultSysFontWithSize(17)
            textField.placeholder = "输入发票台头"
            cell?.contentView.addSubview(textField)
            self.invoiceStrTextF = textField
        }
        if text == "企业" && self.invoiceStrTextF != nil {
            if let body = self.invoiceFinish?["HeadTitle"] as? String {
                self.invoiceStrTextF.text = body
            }
        }
       
        if (indexPath.section == 0 && indexPath.row == self.indexTypeRow) || (indexPath.section == 1 && indexPath.row == self.indexCategoryRow) || indexPath.section == 2 && indexPath.row == self.indexDetailRow {
            if let tmp = cell?.contentView.viewWithTag(10001) as? UIImageView {
                tmp.hidden = false
            }
            cell?.textLabel?.textColor = RGB(235,61,61,1.0)
        } else {
            cell?.textLabel?.textColor = defaultTextColor
            if let tmp = cell?.contentView.viewWithTag(10001) as? UIImageView {
                tmp.hidden = true
            }
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.indexTypeRow = indexPath.row
        } else if indexPath.section == 1{
            self.indexCategoryRow = indexPath.row
        }else {
            self.indexDetailRow = indexPath.row
        }
        self.tableView.reloadData()
    }
    func updateUI() {
        tableView = UITableView(frame: self.view.bounds)
        tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: self.view.bounds.size.height - 64)
        tableView.backgroundColor = tableViewdefaultBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(tableView)
    }
    func dataUpdate() {
        ZMDTool.showActivityView(nil)
        QNNetworkTool.fetchPublicInfo { (publicInfo, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if publicInfo != nil {
                self.datas = publicInfo
                if self.invoiceFinish == nil {
                    self.tableView.reloadData()
                    return
                }
                var index = -1
                for tmp in self.datas.getTypes() {
                    index = index + 1
                    if tmp == self.invoiceFinish!["Type"] as? String {
                        self.indexTypeRow = index
                    }
                }
                index = -1
                for tmp in self.datas.getCategorys() {
                    index = index + 1
                    if tmp == self.invoiceFinish!["Category"] as? String {
                        self.indexTypeRow = index
                    }
                }
                index = -1
                for tmp in self.datas.getBodys() {
                    index = index + 1
                    if tmp == self.invoiceFinish!["Body"] as? String {
                        self.indexDetailRow = index
                    }
                }
                self.tableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(nil, error: error, errorMsg: nil)
            }
        }
    }
    
    //获取传递的参数
    func getPostData() -> NSDictionary? {
        if self.datas == nil {
            return nil
        }
        let type = self.datas.getTypes()[self.indexTypeRow]
        var body = self.datas.getBodys()[self.indexDetailRow]
        let category = self.datas.getCategorys()[self.indexCategoryRow]
        let singleOrCompany = self.indexCategoryRow == 0 ? "个人" : "企业"
        if self.indexTypeRow == 0 {
            body = "不开发票"
        }
        let dic = ["CustomerId":g_customerId!,"Body":body,"HeadTitle":self.invoiceStrTextF.text ?? "","Type":type,"Category":category,"singleOrCompany":singleOrCompany]
        return dic
    }
    override func back() {
        self.finished(dic: self.getPostData())
        self.navigationController?.popViewControllerAnimated(true)
    }
}
