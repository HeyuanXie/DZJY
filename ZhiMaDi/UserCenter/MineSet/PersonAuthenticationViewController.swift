//
//  PersonAuthenticationViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/2.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//身份证认证
class PersonAuthenticationViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMoreProtocol{
    var currentTableView: UITableView!
    var nameTextField : UITextField!
    var cardNumTextField : UITextField!
    var leftPhotoBtn : UIButton!
    var rightPhotoBtn : UIButton!
    
    var picker : UIImagePickerController?
    var photoSelectbtn : UIButton?
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
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell\(indexPath.section)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
        }
        cell?.textLabel!.text = indexPath.section == 0 ? "姓名" : "身份证"
        let tmp = UITextField(frame: CGRect(x: 88, y: 0, width: kScreenWidth - 88 - 12, height: 60))
        tmp.textColor = defaultTextColor
        tmp.font = defaultSysFontWithSize(17)
        tmp.placeholder = indexPath.section == 0 ? "持卡人姓名" : "本人身份证号"
        cell?.contentView.addSubview(tmp)
        if indexPath.section == 0 {
            self.nameTextField = tmp
        } else {
            self.cardNumTextField = tmp
        }
        return cell!
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
    //MARK:- Private Method
    private func subViewInit(){
            self.title = "身份证认证"
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        
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
        let fotView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 240))
        fotView.backgroundColor = UIColor.clearColor()
        let leftBtn = ZMDTool.getButton(CGRect(x: kScreenWidth/2 - 32 - 75, y: 25, width: 75, height: 75), textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            self.photoSelectbtn = sender as? UIButton
            actionSheet.showInView(self.view)
        }
        leftBtn.setImage(UIImage(named: "common_add_pho"), forState: .Normal)
        self.leftPhotoBtn = leftBtn
        fotView.addSubview(self.leftPhotoBtn)
        
        let leftLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth/2 - 32 - 75 - 15, y: 25 + 75 + 8, width: 75 + 30, height: 15), text: "身份证正面照", fontSize: 15, textColor: defaultDetailTextColor)
        leftLbl.textAlignment = .Center
        fotView.addSubview(leftLbl)
        let rightBtn = ZMDTool.getButton(CGRect(x: kScreenWidth/2 + 32, y: 25, width: 75, height: 75), textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            self.photoSelectbtn = sender as? UIButton
            actionSheet.showInView(self.view)
        }
        rightBtn.setImage(UIImage(named: "common_add_pho"), forState: .Normal)
        self.rightPhotoBtn = rightBtn
        fotView.addSubview(self.rightPhotoBtn)
        let rightLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth/2 + 32 - 15, y: 25 + 75 + 8, width: 75+30, height: 15), text: "身份证背面照", fontSize: 15, textColor: defaultDetailTextColor)
        rightLbl.textAlignment = .Center
        fotView.addSubview(rightLbl)
        
        //MARK:下一步，请求实名认证接口
        let saveBtn = ZMDTool.getButton(CGRect(x: 12, y : 25+75+8+15+48, width: kScreenWidth - 24, height: 50), textForNormal: "下一步", fontSize: 20, textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(235,61,61,1.0)) { (sender) -> Void in
            ZMDTool.showPromptView("实名认证暂未开放")
        }
        ZMDTool.configViewLayerWithSize(saveBtn, size: 25)
        fotView.addSubview(saveBtn)
        self.currentTableView.tableFooterView = fotView
    }
    private func dataInit(){
    }
}
