//
//  PersonInfoViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/1.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import SDWebImage
//个人资料
class PersonInfoViewController:UIViewController,UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,ZMDInterceptorMoreProtocol {
    enum UserCenterCellType{
        case Head
        case NickN
        case RealName
        case ChangePs
        case Address
        case Clean
        
        init(){
            self = Head
        }
        
        var title : String{
            switch self{
            case Head:
                return "头像"
            case NickN:
                return "昵称"
            case RealName :
                return "实名认证"
            case ChangePs:
                return "修改登陆密码"
            case Address:
                return "管理收货地址"
                
            case Clean:
                return "清理缓存"
            }
        }

        var pushViewController :UIViewController{
            let viewController: UIViewController
            switch self{
            case Head:
                viewController = UIViewController()
            case NickN:
                viewController = InputTextViewController()
            case RealName :
                viewController = RealAuthenticationViewController()
            case ChangePs:
                viewController = PsWordFindViewController.CreateFromLoginStoryboard() as! PsWordFindViewController
            case Address:
                viewController = AddressViewController.CreateFromMainStoryboard() as! AddressViewController
            case Clean:
                viewController = UIViewController()
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
    
    var userCenterData: [UserCenterCellType]!
    
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
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.userCenterData.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == self.userCenterData.count - 1) ? 16 : 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 85 : tableViewCellDefaultHeight
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell\(indexPath.row)\(indexPath.section)"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell!
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell)
            cell.selectionStyle = .None
        }
        
        let content = self.userCenterData[indexPath.section]
        cell.textLabel?.text = content.title
        switch content {
        case .Head://选择图像
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if self.headerView == nil {
                self.headerView = UIImageView(frame: CGRectMake(kScreenWidth - 60 - 38, (85-60)/2, 60, 60))
                self.headerView.layer.masksToBounds = true
                self.headerView.layer.cornerRadius = self.headerView.frame.width/2
                cell.contentView.addSubview(self.headerView)
            }
            //如果headerView.iamge == nil刷新，避免每次拖动table都从ulr取图片
            if self.headerView.image == nil ,let urlStr = g_customer?.Avatar?.AvatarUrl,url = NSURL(string:urlStr) {
                self.headerView.sd_setImageWithURL(url, placeholderImage: nil)
            }
        case .NickN:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if self.nameLB == nil {
                self.nameLB = UILabel(frame: CGRectMake(kScreenWidth - 100 - 58, 0, 120, tableViewCellDefaultHeight))
                self.nameLB.font = UIFont.systemFontOfSize(17)
                self.nameLB.textAlignment = NSTextAlignment.Right
                self.nameLB.textColor = defaultDetailTextColor
                cell.contentView.addSubview(self.nameLB)
            }
            
            self.nameLB.text = g_customer?.FirstName ?? ""      //目前FirstName为phonenumber，所以用下面的
            if g_isLogin! {
                self.nameLB.text  = getObjectFromUserDefaults("nickName") as? String
            }else{
                self.nameLB.text = " "
            }
            
        case .RealName:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            self.sexLB = UILabel(frame: CGRectMake(kScreenWidth - 100 - 38, 0,100, tableViewCellDefaultHeight))
            self.sexLB.font = UIFont.systemFontOfSize(17)
            self.sexLB.textAlignment = NSTextAlignment.Right
            self.sexLB.text = "未认证"
            self.sexLB.textColor = defaultDetailTextColor
            cell.contentView.addSubview(self.sexLB)
        case .Address:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            self.addressLB = UILabel(frame: CGRectMake(kScreenWidth - 100 - 38,0,100,tableViewCellDefaultHeight))
            self.addressLB.font = UIFont.systemFontOfSize(17)
            self.addressLB.text = ""
            self.addressLB.textAlignment = NSTextAlignment.Right
            self.addressLB.textColor = defaultDetailTextColor
            cell.contentView.addSubview(self.addressLB)
        case .ChangePs:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        case .Clean:
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        ZMDTool.configTableViewCellDefault(cell)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let type = self.userCenterData[indexPath.section]
        if indexPath.section == 0 {
            switch type {
            case .Head :
                if !g_isLogin {
                    self.commonAlertShow(true, title: "提示:未登录!", message: "是否立即登录?", preferredStyle: UIAlertControllerStyle.Alert)
                    return
                }
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
                actionSheet.showInView(self.view)
            default: return
            }
        } else if indexPath.section == self.userCenterData.count - 1 {
            //计算缓存，计算完成菊花消失，显示alertView
//            ZMDTool.showActivityView("请稍候")
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
        }else if indexPath.section == 1 {
            //点击昵称
            let inputTextViewController = InputTextViewController()
            inputTextViewController.hidesBottomBarWhenPushed = true
            inputTextViewController.finished = { (text) -> Void in
                self.nameLB.text = text
                saveObjectToUserDefaults("nickName", value: text)
            }
            self.navigationController?.pushViewController(inputTextViewController, animated: true)
        }else {
            type.didSelect(self.navigationController!)
        }
    }

    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
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
        self.title = "个人设置"
        self.tableView = UITableView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64), style: UITableViewStyle.Plain)
        self.tableView.backgroundColor = RGB(245,245,245,1)
        self.tableView.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        let footV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 64+50+20))
        footV.backgroundColor = UIColor.clearColor()
        let text = g_isLogin! ? "退出登陆" : "登陆"
        let btn = ZMDTool.getButton(CGRect(x: 12, y: 64, width: kScreenWidth - 24, height: 50), textForNormal: text, fontSize: 17,textColorForNormal:RGB(173,173,173,1), backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            cleanPassword()
            g_customerId = nil
            ZMDTool.enterLoginViewController()
        }
        btn.center = footV.center
        ZMDTool.configViewLayerWithSize(btn, size: 20)
        ZMDTool.configViewLayerFrameWithColor(btn, color: defaultTextColor)
        footV.addSubview(btn)
        self.tableView.tableFooterView = footV
    }
    private func dataInit(){
        self.userCenterData = [UserCenterCellType.Head,UserCenterCellType.NickN /*,UserCenterCellType.RealName*/, UserCenterCellType.Address, UserCenterCellType.ChangePs, UserCenterCellType.Clean]
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




    