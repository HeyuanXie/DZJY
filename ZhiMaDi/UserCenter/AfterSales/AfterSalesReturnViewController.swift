//
//  AfterSalesReturnViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class AfterSalesReturnViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    enum CellType {
        case ReturnType
        case ReturnReason
        case ReturnExplan
        case ReturnMoney
        
        case ExpressCompany
        case ExpressCode
        var title : String {
            switch self {
            case .ReturnType :
                return "服务类型 ："
            case .ReturnReason :
                return  "换货原因"
            case .ReturnExplan :
                return "退货说明 ："
            case ReturnMoney:
                return "退款金额 ：  /  应返还金额 ："
                
            case ExpressCompany :
                return "快递公司 ："
            case ExpressCode :
                return "快递单号 ："
            }
        }
    }
    
    var currentTableView: UITableView!
    var explainTextField : UITextField!
    var expressCompanyTextField : UITextField!
    var expressCodeTextField : UITextField!
    var picker : UIImagePickerController?
    var photoSelectbtn : UIButton?
    
    var celltype : [[CellType]]!
    var returnType : ReturnCellType!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.subViewInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.celltype[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.celltype.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.celltype[indexPath.section][indexPath.row] == .ReturnExplan {
            return 18+17+8 + 120
        }
        return 56
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type = self.celltype[indexPath.section][indexPath.row]
        switch type {
        case .ReturnType :
            let cellId = "TypeCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell?.textLabel!.text = type.title
            let lbl = ZMDTool.getLabel(CGRect(x: 117, y: 0, width: 120, height: 56), text: self.returnType.title, fontSize: 17)
            cell?.contentView.addSubview(lbl)
            return cell!
        case .ReturnReason :
            let cellId = "ReasonCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            cell?.textLabel!.text = self.returnType.returnReasonTitle
            let lbl = ZMDTool.getLabel(CGRect(x: 117, y: 0, width: 200, height: 56), text:self.returnType.returnReason, fontSize: 17,textColor:defaultDetailTextColor)
            cell?.contentView.addSubview(lbl)
            return cell!
        case .ReturnMoney :
            let cellId = "MoneyCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = .None
                
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel!.text = self.returnType == ReturnCellType.ReturnGoods ? "退款金额 ：" : "应返还金额 ："
            let lbl = ZMDTool.getLabel(CGRect(x: 117, y: 0, width: 200, height: 56), text:"495.00", fontSize: 17,textColor:RGB(235,61,61,1.0))
            cell?.contentView.addSubview(lbl)
            return cell!
        case .ReturnExplan :
            let cellId = "ExplanCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
            }
            let lbl = ZMDTool.getLabel(CGRect(x: 12, y: 18, width: 100, height: 17), text:self.returnType.returnExplan, fontSize: 17)
            cell?.contentView.addSubview(lbl)
            self.explainTextField = ZMDTool.getTextField(CGRect(x: 12, y: 18+17+8, width: kScreenWidth - 24, height: 120), placeholder: "", fontSize: 17)
            cell?.contentView.addSubview(self.explainTextField)
            return cell!
        case .ExpressCompany :
            let cellId = "ExpressCompCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
            }
            let lbl = ZMDTool.getLabel(CGRect(x: 12, y: 18, width: 100, height: 17), text: type.title, fontSize: 17)
            cell?.contentView.addSubview(lbl)
            self.expressCompanyTextField = ZMDTool.getTextField(CGRect(x: 130, y: 8, width: kScreenWidth - 142, height: 40), placeholder: "", fontSize: 17)
            self.expressCompanyTextField.backgroundColor = RGB(246,246,246,1)
            ZMDTool.configViewLayer(self.expressCompanyTextField)
            ZMDTool.configViewLayerFrame(self.expressCompanyTextField)
            cell?.contentView.addSubview(self.expressCompanyTextField)
            return cell!
        case .ExpressCode :
            let cellId = "ExplanCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell!.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            let lbl = ZMDTool.getLabel(CGRect(x: 12, y: 18, width: 100, height: 17), text: type.title, fontSize: 17)
            cell?.contentView.addSubview(lbl)
            self.explainTextField = ZMDTool.getTextField(CGRect(x: 130, y: 8, width: kScreenWidth - 142, height: 40), placeholder: "", fontSize: 17)
            self.explainTextField.backgroundColor = RGB(246,246,246,1)
            ZMDTool.configViewLayer(self.explainTextField)
            ZMDTool.configViewLayerFrame(self.explainTextField)
            cell?.contentView.addSubview(self.explainTextField)
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // 存储图片
        let size = CGSizeMake(image.size.width, image.size.height)
        let headImageData = UIImageJPEGRepresentation(self.imageWithImageSimple(image, scaledSize: size), 0.125) //压缩
        self.uploadUserFace(headImageData)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
        //        self.headerView.image = UIImage(data: headImageData!)
        self.photoSelectbtn?.setImage(UIImage(data: headImageData!), forState: .Normal)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 上传头像
    private func uploadUserFace(imageData: NSData!) {
        if imageData == nil {
            ZMDTool.showPromptView( "上传图片数据损坏", nil)
            return
        }
        ZMDTool.showActivityView("正在上传...", inView: self.view, nil)
        
        //        QNNetworkTool.uploadDoctorImage(imageData, fileName: "" + ".jpg", type: "groupUserFace") { (dictionary, error) -> Void in
        ZMDTool.hiddenActivityView()
        //            if dictionary != nil, let errorCode = dictionary?["errorCode"] as? String where errorCode == "0" {
        //                let dict = dictionary!["data"] as! NSDictionary
        //                let urlStr = dict["url"] as! String
        //                let fileName = dict["fileName"] as! String
        //                for temp in g_currentGroup!.users {
        //                    if temp.id == self.user.id {
        //                        temp.photoURL = urlStr
        //                    }
        //                }
        //                self.updateGroupPhoto(fileName,url: urlStr)
        //                self.headerView.sd_setImageWithURL(NSURL(string: urlStr), placeholderImage: UIImage(named: "UserCenter_HeaderImage"))
        //                self.tableView.reloadData()
        //
        //            }else {
        //                QNTool.showPromptView( "上传失败,点击重试或者重新选择图片", nil)
        //            }
        //
        //        }
        
    }
    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    
    func updateGroupPhoto(fileName : String,url : String) {
        //        QNNetworkTool.updateGroupPhoto(fileName, userId: self.user.id) { (dictionary, error) -> Void in
        //            if dictionary != nil ,let errorCode = dictionary?["errorCode"] as? String where errorCode == "0"{
        //                var familys = g_currentGroup!.users
        //                familys[self.userIndex].photoURL = url
        //                g_currentGroup?.users = familys
        //                QNTool.showPromptView( "头像修改成功", nil)
        //            }else {
        //                QNTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
        //            }
        //        }
    }

    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.view.backgroundColor = UIColor.whiteColor()
        let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("从手机相册选择")
        actionSheet.addButtonWithTitle("拍照")
        actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
            if let indexInt = index as? Int {
                switch indexInt {
                case 1, 2:
                    if self.picker == nil {
                        self.picker = UIImagePickerController()
                        self.picker!.delegate = self
                    }
                    
                    self.picker!.sourceType = (indexInt == 1) ? .SavedPhotosAlbum : .Camera
                    self.picker!.allowsEditing = true
                    self.presentViewController(self.picker!, animated: true, completion: nil)
                default: break
                }
            }
        })

        self.title = "退款/售后"
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width:kScreenWidth , height: self.view.bounds.height - 58 - 58))
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
        let imgFootV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 120+64))
        imgFootV.backgroundColor = UIColor.clearColor()
        let imgBtn = ZMDTool.getBtn(CGRect(x: 12, y: 24, width: 75, height: 75))
        imgBtn.setImage(UIImage(named: "common_add_pho"), forState: .Normal)
        imgBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.photoSelectbtn = sender as? UIButton
            actionSheet.showInView(self.view)
            return RACSignal.empty()
        })
        imgFootV.addSubview(imgBtn)
        let lbl = ZMDTool.getLabel(CGRect(x: 12, y: 90 + 8, width: 75, height: 15), text: "上传图片", fontSize: 15,textColor: defaultDetailTextColor)
        lbl.textAlignment = .Center
        imgFootV.addSubview(lbl)
        let submitBtn = ZMDTool.getButton(CGRect(x: 12, y: CGRectGetMaxY(lbl.frame)+12, width: kScreenWidth-12*2, height: 58), textForNormal: "提交申请", fontSize: 17, backgroundColor: defaultSelectColor) { (sender) -> Void in
            ZMDTool.showPromptView("功能完善中")
        }
        ZMDTool.configViewLayer(submitBtn)
        imgFootV.addSubview(submitBtn)
        self.currentTableView.tableFooterView = imgFootV
        
        self.view.addSubview(ZMDTool.getLine(CGRect(x: 0, y: self.view.bounds.height - 58-58-0.5, width: kScreenWidth, height: 0.5)))
    }
    func dataInit() {
        if self.returnType == ReturnCellType.ReturnGoods {
            self.celltype = [[CellType.ReturnType,.ReturnReason,.ReturnMoney],[.ReturnExplan]]
        } else if self.returnType == ReturnCellType.Refund {
            self.celltype = [[CellType.ReturnType,.ReturnReason],[.ReturnExplan]]
        } else if self.returnType == ReturnCellType.EXchangeGoods {
            self.celltype = [[CellType.ReturnType,.ReturnReason],[.ReturnExplan]]
        } else if self.returnType == ReturnCellType.ReturnLease {
            self.celltype = [[CellType.ReturnType,.ReturnReason,.ReturnMoney],[.ExpressCompany,.ExpressCode]]
        }
    }
    
}
