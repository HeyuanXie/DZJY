//
//  PersonInfoViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/1.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import SDWebImage
//账户设置
class PersonInfoViewController:UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMoreProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate,HZQDatePickerViewDelegate {
    enum UserCenterCellType : String {
        case Head
        case Name
        case Gender
        case BirthDay
        case Location
        
        case QQ
        case WeiXin
        case Email
        case Phone
        
        case PayPassword
        
        case Address
        case Version
        
        case Clean
        
        init(){
            self = Head
        }
        
        var title : String{
            switch self{
            case Head:
                return "更换头像"
            case Name:
                return "真实姓名"
            case .Gender:
                return "性别"
            case .BirthDay:
                return "生日"
            case .Location:
                return "所在地"
                
            case .QQ:
                return "QQ号"
            case .WeiXin:
                return "微信号"
            case .Email:
                return "邮箱"
            case .Phone:
                return "手机号"
                
            case .PayPassword:
                return "设置支付密码"
                
            case .Address:
                return "管理收货地址"
            case .Version:
                return "版本号"
                
            case Clean:
                return "清理缓存"
            }
        }
        
        var text : String {
            switch self {
            case Head:
                return ""
            case .Name:
                return ""
            case .Gender:
                return ""
            case .BirthDay:
                return "未选择"
            case .Location:
                return "广东 - 东莞"
                
            case .QQ:
                return "请填写"
            case .WeiXin:
                return "请填写"
            case .Email:
                return "请填写"
            case .Phone:
                return "请填写"
                
            default:
                return ""
            }
        }

        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case .Gender:
                viewController = UIViewController()
            case .BirthDay:
                viewController = UIViewController()
            case .Location :
                viewController = UIViewController()
                
            case .PayPassword:
                viewController = PayPasswordChangeViewController()
            case .Address:
                viewController = AddressViewController.CreateFromMainStoryboard() as! AddressViewController
                (viewController as! AddressViewController).contentType = .Manage
            default:
                viewController = InputTextViewController()
            }
            viewController.hidesBottomBarWhenPushed = true
            return viewController
        }
        //MARK:didSelect 选择跳转的VC
        func didSelect(navViewController:UINavigationController){
            if self == Address && !g_isLogin {
                ZMDTool.showPromptView("请您先登录!")
                return
            }
            navViewController.pushViewController(self.pushViewController, animated: true)
        }
    }
    
    var tableView : UITableView!
    var headerView: UIImageView!
    var nameLB: UILabel!
    var sexLB: UILabel!
    var addressLB: UILabel!
    var descriptionLB: UILabel!
    var moreView :UIView!
    var picker: UIImagePickerController?
    var pickerView : HZQDatePickerView!
    
    var userCenterData: [[UserCenterCellType]]!
    
    var isMoreViewShow = true   //判断点击moreBtn时是否显示popView(首页、消息)
    var isSaveImage = false
//    var postHeadImage : ((imageData: NSData) -> Void)! //设置图像后将iamgeData传递给MineSetVC
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.subViewInit()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userCenterData[section].count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return zoom(12)
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.userCenterData[indexPath.section][indexPath.row] == .Head {
            return zoom(68)
        }else{
            return zoom(tableViewCellDefaultHeight)
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, zoom(12)))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let content = self.userCenterData[indexPath.section][indexPath.row]
        switch content {
        case .Head://选择图像
            let cellId = "headCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell!
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                ZMDTool.configTableViewCellDefault(cell)
                cell.accessoryView = ZMDTool.getDefaultAccessoryDisclosureIndicator()
//                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
                if self.headerView == nil {
                    self.headerView = UIImageView(frame: CGRectMake(kScreenWidth - zoom(60 + 38), 0, zoom(50), zoom(50)))
                    self.headerView.layer.masksToBounds = true
                    self.headerView.layer.cornerRadius = self.headerView.frame.width/2
                    cell.contentView.addSubview(self.headerView)
                    self.headerView.image = UIImage(named: "示例图像")
                    self.headerView.set("cy",value: zoom(34))
                }
                cell.addLine()
            }
            //如果headerView.iamge == nil刷新，避免每次拖动table都从ulr取图片
            if self.headerView.image == nil ,let urlStr = g_customer?.Avatar?.AvatarUrl,url = NSURL(string:urlStr) {
                self.headerView.sd_setImageWithURL(url, placeholderImage: nil)
            }
            cell.textLabel?.text = content.title
            cell.textLabel?.font = UIFont.systemFontOfSize(15)
            return cell!
        default:
            let cellId = "defaultCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                ZMDTool.configTableViewCellDefault(cell!)

                let rightLbl = UILabel(frame: CGRectMake(kScreenWidth - zoom(190+48), 0, zoom(190), zoom(tableViewCellDefaultHeight)))
                rightLbl.font = UIFont.systemFontOfSize(15)
                rightLbl.textAlignment = NSTextAlignment.Right
                rightLbl.textColor = defaultDetailTextColor
                rightLbl.tag = 10000
                cell!.contentView.addSubview(rightLbl)
                if content != .Location && content != .PayPassword && content != .Version && content != .Phone {
                    cell?.addLine()
                }
            }
            if content == .Name || content == .WeiXin || content == .Email || content == .Version {
                cell?.accessoryType = .None
            }else{
                cell?.accessoryView = ZMDTool.getDefaultAccessoryDisclosureIndicator()
//                cell?.accessoryType = .DisclosureIndicator
            }
            cell?.textLabel?.text = content.title
            cell?.textLabel!.font = defaultSysFontWithSize(15)
            let rightLbl = cell?.contentView.viewWithTag(10000) as! UILabel
            rightLbl.text = content.text
            switch content {
            case .Name:
                rightLbl.text = getObjectFromUserDefaults("realName") as? String
            case .Gender:
                rightLbl.text = getObjectFromUserDefaults("gender") as? String
            case .BirthDay:
                rightLbl.text = getObjectFromUserDefaults("birthDay") as? String
            case .Location:
                rightLbl.text = getObjectFromUserDefaults("location") as? String
            case .QQ:
                rightLbl.text = getObjectFromUserDefaults("qq") as? String
            case .WeiXin:
                rightLbl.text = getObjectFromUserDefaults("weiXin") as? String
            case .Phone:
                rightLbl.text = getObjectFromUserDefaults("phone") as? String
            case .Email:
                rightLbl.text = getObjectFromUserDefaults("email") as? String
            case .Version:
                rightLbl.text = "V "+APP_VERSION
            default:
                break
            }
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let type = self.userCenterData[indexPath.section][indexPath.row]
        switch type {
        case .Head:
            if !g_isLogin {
                self.commonAlertShow(true, title: "提示:未登录!", message: "是否立即登录?", preferredStyle: UIAlertControllerStyle.Alert)
                return
            }
            let actionSheet = UIAlertController(title: nil, message: "操作选项", preferredStyle: .ActionSheet)
            let titles = [("从手机相册选择",UIImagePickerControllerSourceType.SavedPhotosAlbum),("拍照",UIImagePickerControllerSourceType.Camera)]
            for item in titles {
                let action = UIAlertAction(title: item.0, style: .Default, handler: { (action) -> Void in
                    self.picker?.sourceType = item.1
                    self.presentViewController(self.picker!, animated: true, completion: { () -> Void in
                        self.picker?.delegate = self
                    })
                })
                actionSheet.addAction(action)
            }
            actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
            break
        case .Clean:
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                //计算缓存
                let size = self.fileSizeOfCache()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //在主线程显示cleanAlert
                    let sizeString = String(format:"%.2f",size)
                    let message = "已存有\(sizeString)M缓存，确定清理吗？"
                    let cleanAlert = UIAlertController(title: "注意", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(cleanAlert, animated: true, completion: nil)
                    let action1 = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (sender) -> Void in
                    })
                    let action2 = UIAlertAction(title: "确定", style: UIAlertActionStyle.Destructive, handler: { (sender) -> Void in
                        //清理缓存
                        self.clearCache()
                        ZMDTool.showPromptView("清理完成")
                    })
                    cleanAlert.addAction(action1)
                    cleanAlert.addAction(action2)
                })
            })
            break
        case .Gender:
            let sheet = UIAlertController(title: "性别", message: "", preferredStyle: .ActionSheet)
            for title in ["男","女"] {
                sheet.addAction(UIAlertAction(title: title, style: .Default, handler: { (sheet) -> Void in
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
                    let rightLbl = cell?.contentView.viewWithTag(10000) as! UILabel
                    rightLbl.text = title
                    saveObjectToUserDefaults("gender", value: title)
                }))
            }
            sheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            self.presentViewController(sheet, animated: true, completion: nil)
            return
        case .BirthDay:
            self.pickerView = HZQDatePickerView.instanceDatePickerView()
            self.pickerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight + 20)
            self.pickerView.backgroundColor = UIColor.clearColor()
//            self.pickerView.delegate = self
            self.pickerView.type = DateType.init(0)
            self.pickerView.datePickerView?.maximumDate = NSDate()
            self.view.addSubview(self.pickerView)
            break
        case .Location:
            self.view.endEditing(true)
            let areaView = ZMDAreaView(frame: CGRect(x: 0, y: kScreenHeight-400, width: kScreenWidth, height: 400))
            areaView.finished = { (address,addressId) ->Void in
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))
                let rightLbl = cell?.contentView.viewWithTag(10000) as! UILabel
                
                var text = address
                if let arr = address.componentsSeparatedByString("市辖区") as? NSArray where arr.count == 2 {
                    text = (arr[0] as! String)+(arr[1] as! String)
                }
                if let arr = address.componentsSeparatedByString("市辖县") as? NSArray where arr.count == 2 {
                    text = (arr[0] as! String)+(arr[1] as! String)
                }
                rightLbl.text = text
                saveObjectToUserDefaults("location", value: text)
                self.dismissPopupView(areaView)
            }
            self.viewShowWithBg(areaView,showAnimation: .SlideInFromBottom,dismissAnimation: .SlideOutToBottom)
            return
        case .Address:
            type.didSelect(self.navigationController!)
        case .PayPassword:
            type.didSelect(self.navigationController!)
        case .Version:
            return
        default:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let vc = InputTextViewController()
            vc.finished = {(string)->Void in
                let rightLbl = cell?.contentView.viewWithTag(10000) as! UILabel
                rightLbl.text = string
                switch type {
                case .Name:
                    saveObjectToUserDefaults("realName", value: string)
                case .Phone:
                    saveObjectToUserDefaults("phone", value: string)
                case .WeiXin:
                    saveObjectToUserDefaults("weiXin", value: string)
                case .QQ:
                    saveObjectToUserDefaults("qq", value: string)
                case .Email:
                    saveObjectToUserDefaults("email", value: string)
                default:
                    break
                }
            }
            self.pushToViewController(vc, animated: true, hideBottom: true)
        }
    }
    
    //MARK: - TimePickerDelegate
    func getSelectDate(date: String!, type: DateType) {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
        let rightLbl = cell?.contentView.viewWithTag(10000) as! UILabel
        rightLbl.text = date
        saveObjectToUserDefaults("birthDay", value: date)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // 存储图片
        let size = CGSizeMake(image.size.width, image.size.height)
        let headImageData = UIImageJPEGRepresentation(self.imageWithImageSimple(image, scaledSize: size), 0.125) //压缩
        self.uploadUserFace(headImageData)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if self.picker?.sourceType == .Camera {
            return
        }
        let image = info["UIImagePickerControllerEditedImage"] as! UIImage
        // 存储图片
        let size = CGSizeMake(image.size.width, image.size.height)
        let headImageData = UIImageJPEGRepresentation(self.imageWithImageSimple(image, scaledSize: size), 0.125) //压缩
        self.uploadUserFace(headImageData)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
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
         QNNetworkTool.uploadCustomerHead(imageData, fileName: "image.jpeg", customerId: NSString(string: "\(g_customerId!)")) { (succeed, dic, error) -> Void in
            ZMDTool.hiddenActivityView()
            if succeed {
                self.headerView.image = UIImage(data: imageData)
//                self.postHeadImage(imageData: imageData)
            }else {
                ZMDTool.showPromptView( "上传失败,点击重试或者重新选择图片", nil)
            }
        }
    }
    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }

    //MARK:- Private Method
    private func subViewInit(){
        self.title = "账户设置"
        self.tableView = UITableView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64), style: UITableViewStyle.Plain)
        self.tableView.backgroundColor = RGB(245,245,245,1)
        self.tableView.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        let footV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(64+50+20)))
        footV.backgroundColor = UIColor.clearColor()
        let text = g_isLogin! ? "退出登陆" : "登陆"
        let btn = ZMDTool.getButton(CGRect(x: zoom(12), y: zoom(64), width: kScreenWidth - zoom(24), height: zoom(50)), textForNormal: text, fontSize: 17,textColorForNormal:RGB(173,173,173,1), backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            cleanPassword()
            g_customerId = nil
            if (sender as! UIButton).titleLabel?.text == "退出登陆" {
                ZMDTool.showPromptView("退出登陆成功")
                g_customer?.Avatar?.AvatarUrl = nil
                self.navigationController?.popViewControllerAnimated(true)
                (sender as! UIButton).setTitle("登陆", forState: .Normal)
            }else{
                let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
                vc.loginSucceed = {()->Void in
                    (sender as! UIButton).setTitle("退出登陆", forState: .Normal)
                }
                self.pushToViewController(vc, animated: true, hideBottom: true)
            }
        }
        btn.center = footV.center
        ZMDTool.configViewLayerWithSize(btn, size: zoom(20))
        ZMDTool.configViewLayerFrameWithColor(btn, color: defaultTextColor)
        footV.addSubview(btn)
        self.tableView.tableFooterView = footV
    }
    private func dataInit(){
        self.userCenterData = [[.Head,.Name,.Gender,.BirthDay,.Location],[.WeiXin,.Email,.Phone]/*,[.PayPassword]*/,[.Address,.Version]]
        self.picker = UIImagePickerController()
//        self.picker?.allowsEditing = true
        self.picker?.delegate = self
    }
    //MARK:创建moreView
    func moreViewUpdate() {
        if self.moreView == nil {
            let titles = ["消息":UIImage(named: "common_more_message"),"首页":UIImage(named: "common_more_home")]
            let view = UIView(frame: CGRect(x:kScreenWidth-150-12, y: 0, width: 150, height: 48*CGFloat(titles.count)))
            self.moreView = view
            var i = 0
            for title in titles {
                let btn = UIButton(frame: CGRect(x: 0, y: 48*i, width: 150, height: 48))
                btn.backgroundColor = UIColor(white: 0, alpha: 0.5)
                btn.tag = i + 100
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    let vc : UIViewController
//                    if (sender as!UIButton).tag == 100{
                    if title.0 == "消息"{
                        vc = MsgHomeViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
//                        self.navigationController?.popToRootViewControllerAnimated(true)
                        self.moreView.removeFromSuperview()
                        self.tabBarController?.selectedIndex = 0
                    }
                })
                let imgV = UIImageView(frame: CGRect(x: 10, y: 14, width: 20, height: 20))
                imgV.image = title.1
                btn.addSubview(imgV)
                let label = UILabel(frame: CGRect(x: 40, y: 0, width: 110, height: 48))
                label.text = title.0
                label.textColor = UIColor.whiteColor()
                btn.addSubview(label)
                view.addSubview(btn)
                i++
            }
            let line = UIView(frame: CGRect(x:0, y: 48, width: 150, height: 1))
            line.backgroundColor = UIColor.whiteColor()
            self.moreView.addSubview(line)
        }
    }
    
    //MARK:重写（点击moreBtn）
    override func gotoMore() {
        let containView = UIButton(frame: self.view.bounds)
        containView.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            self.isMoreViewShow = true
            self.dismissPopupView(self.moreView)
            containView.removeFromSuperview()
        }
        self.view.addSubview(containView)
        self.moreViewUpdate()
        if self.isMoreViewShow {
            self.presentPopupView(self.moreView, config: ZMDPopViewConfig())
        }else{
            self.dismissPopupView(self.moreView)
            containView.removeFromSuperview()
        }
        self.isMoreViewShow = !self.isMoreViewShow
    }
    
    //MARK:重写 -- alertDestructiveAction
    override func alertDestructiveAction() {
        ZMDTool.enterLoginViewController()
    }
    
    
    //MARK:清理缓存
    //计算缓存大小
    func fileSizeOfCache()-> Double {
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        // 取出文件夹下所有文件数组
        let fileArr = NSFileManager.defaultManager().subpathsAtPath(cachePath!)
        //快速枚举出所有文件名 计算文件大小
        var size = 0.00
        for file in fileArr! {
            // 把文件名拼接到路径中
            let path = cachePath?.stringByAppendingString("/\(file)")
            // 取出文件属性
            let floder = try! NSFileManager.defaultManager().attributesOfItemAtPath(path!)
            // 用元组取出文件大小属性
            for (abc, bcd) in floder {
                // 累加文件大小
                if abc == NSFileSize {
                    size += Double(bcd.integerValue)
                }
            }
        }
        size += Double(SDImageCache.sharedImageCache().getSize().hashValue)
        let mm = size / 1024 / 1024
        ZMDTool.hiddenActivityView()
        return mm
    }
    
    //清理缓存
    func clearCache() {
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        // 取出文件夹下所有文件数组
        let fileArr = NSFileManager.defaultManager().subpathsAtPath(cachePath!)
        // 遍历删除
        for file in fileArr! {
            let path = cachePath?.stringByAppendingString("/\(file)")
            if NSFileManager.defaultManager().fileExistsAtPath(path!) {
                
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path!)
                } catch {
                    
                }
            }
            SDImageCache.sharedImageCache().clearDisk()
        }
    }
    
    
}




    