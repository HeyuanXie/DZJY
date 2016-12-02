//
//  MineHomeHelpViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/14.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import MWPhotoBrowser
// 意见反馈
class MineHomeHelpViewController: UIViewController,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,MWPhotoBrowserDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    
    var scoreTextField : UITextField!
    var contactTextField : UITextField!
    var countLbl : UILabel!
    var pickBtn : UIButton!
    let picker: UIImagePickerController = UIImagePickerController()
    var photoView: UIView!
    var tmp : UIButton!
    var goodsScoreRigthLbl : UILabel!
    var logisticsScoreRigthLbl : UILabel!
    var photos : NSMutableArray = NSMutableArray()
    
    var isTabBarVC = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.view.backgroundColor = RGB(245,245,245,1)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let mulStr = NSMutableString(string: textField.text!)
        mulStr.replaceCharactersInRange(range, withString: string)
        let checkText = { (count : Int) -> Void in
            if count - mulStr.length < 0 {
                ZMDTool.showPromptView( "输入字数在200以内", nil)
            }
            self.countLbl.text = "\(count - mulStr.length)"
        }
        checkText(200)
        
        let submitBtn = self.view.viewWithTag(1000) as!UIButton
        submitBtn.backgroundColor = mulStr.length == 0 ? RGB(215,215,215,1) : defaultSelectColor
        submitBtn.userInteractionEnabled = mulStr.length == 0 ? false : true
        return true
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let size = CGSizeMake(image.size.width, image.size.height)
        let headImageData = UIImageJPEGRepresentation(image.imageWithImageSimple(size), 0.125)
        photos.addObject(UIImage(data: headImageData!)!)
        self.configurePhotoBtn()
        //        self.uploadImg(headImageData)
        self.picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - MWPhotoBrowserDelegate
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if Int(index) < self.photos.count {
            let photo:MWPhoto = MWPhoto(image: self.photos[Int(index)] as! UIImage)
            return photo
        }
        return nil
    }
    func photoBrowserDidFinishModalPresentation(photoBrowser:MWPhotoBrowser) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "帮助与反馈"
        self.picker.delegate = self
        let headViewBg = UIView(frame: CGRect(x: 12, y: 15, width: kScreenWidth-24, height: 250))
        headViewBg.backgroundColor = UIColor.whiteColor()
        ZMDTool.configViewLayer(headViewBg)
        ZMDTool.configViewLayerFrame(headViewBg)
        self.view.addSubview(headViewBg)
        self.scoreTextField = ZMDTool.getTextField(CGRect(x: 16, y: 15, width: CGRectGetWidth(headViewBg.frame), height: 130), placeholder: "感谢您的宝贵意见", fontSize: 17)
        self.scoreTextField.contentVerticalAlignment = .Top //方向
        self.scoreTextField.delegate = self
        headViewBg.addSubview(self.scoreTextField)
        
        photoView = UIView(frame: CGRect(x: 0, y: 130, width: kScreenWidth-24, height: 116))
        photoView.backgroundColor = UIColor.clearColor()
        headViewBg.addSubview(photoView)
        
        countLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth-24-12-30, y: 250-12-15, width: 30, height: 15), text: "200", fontSize: 15,textColor: defaultDetailTextColor,textAlignment: .Right)
        headViewBg.addSubview(countLbl)
        self.configurePhotoBtn()
        
        
        let contactViewBg = UIView(frame: CGRect(x: 12, y: CGRectGetMaxY(headViewBg.frame) + 16, width: kScreenWidth-24, height: 55))
        contactViewBg.backgroundColor = UIColor.whiteColor()
        ZMDTool.configViewLayer(contactViewBg)
        ZMDTool.configViewLayerFrame(contactViewBg)
        self.view.addSubview(contactViewBg)
        self.contactTextField = ZMDTool.getTextField(CGRect(x: 12, y: 0, width:kScreenWidth-24-24 , height: 55), placeholder: "邮箱/电话", fontSize: 17)
        self.contactTextField.backgroundColor = UIColor.clearColor()
        contactViewBg.addSubview(self.contactTextField)
        
        let submitBtn = ZMDTool.getButton(CGRect(x: 12, y: CGRectGetMaxY(contactViewBg.frame) + 20 , width: kScreenWidth-24, height: 50), textForNormal: "提交", fontSize: 17,textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(215,215,215,1)) { (sender) -> Void in
            //MARK: -提交意见
            var message = " "
            if let userName = g_customer?.FirstName {
                message = "\"\(userName)\"您好,您的意见已提交成功!"
                if let usrName = getObjectFromUserDefaults("nickName") as? String {
                    message = "\"\(usrName)\"您好,您的意见已提交成功!"
                }
            }else{
                message = "您的意见已提交成功,感谢您对我们的支持!"
            }
            self.commonAlertShow(false,title: "意见反馈", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        }
        submitBtn.tag = 1000
        submitBtn.userInteractionEnabled = false
        ZMDTool.configViewLayerWithSize(submitBtn, size: 25)
        self.view.addSubview(submitBtn)
    }
    
    func configurePhotoBtn(){
        for subView in self.photoView.subviews {
            subView.removeFromSuperview()
        }
        if self.pickBtn == nil {
            self.pickBtn = UIButton(type: .Custom)
            pickBtn.backgroundColor = UIColor.clearColor()
            pickBtn.frame =  CGRectMake(8, 10, 75 , 75)
            pickBtn.setImage(UIImage(named: "common_add_pho"), forState: .Normal)
            self.pickBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) -> Void in
                if let strongSelf = self {
                    let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
                    actionSheet.addButtonWithTitle("从手机相册选择")
                    actionSheet.addButtonWithTitle("拍照")
                    actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                        if let indexInt = index as? Int {
                            switch indexInt {
                            case 1, 2:
                                strongSelf.picker.sourceType = (indexInt == 1) ? .SavedPhotosAlbum : .Camera
                                //strongSelf.picker.allowsEditing = true
                                strongSelf.presentViewController(strongSelf.picker, animated: true, completion: nil)
                            default: break
                            }
                        }
                    })
                    actionSheet.showInView(strongSelf.view)
                }
            }
        }
        self.photoView.addSubview(self.pickBtn)
        if self.photos.count > 0 {
            let y: CGFloat = 10
            let padding = (CGRectGetWidth(photoView.frame) - 75*3) / 4
            for var i = 0 ; i < self.photos.count; i++ {
                let x : CGFloat =  CGFloat(75 * i  + Int(padding) * (i + 1) )
                let imgV: UIButton = UIButton(type: .Custom)
                imgV.frame = CGRectMake(x, y, 75 , 75)
                imgV.tag = i+1
                imgV.setImage(self.photos[i] as? UIImage, forState: .Normal)
                imgV.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                    if let strongSelf = self {
                        // Create browser
                        let  browser = PhotoBroswerViewController(delegate: self)
                        browser.photos = strongSelf.photos.count
                        browser.setCurrentPhotoIndex(UInt((input as! UIButton).tag - 1))
                        browser.deleteImages = {(index)-> Void in
                            strongSelf.photos.removeObjectAtIndex(index)
                            strongSelf.configurePhotoBtn()
                        }
                        strongSelf.navigationController?.pushViewController(browser, animated: true)
                    }
                    return RACSignal.empty()
                    });
                let deleteBtn = UIButton(frame: CGRect(x: 75-3-18, y: 3, width: 18, height: 18))
                deleteBtn.setImage(UIImage(named: "common_delete_pho"), forState: .Normal)
                deleteBtn.tag = i
                deleteBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    self.photos.removeObjectAtIndex(sender.tag)
                    self.configurePhotoBtn()
                })
                imgV.addSubview(deleteBtn)
                self.photoView.addSubview(imgV)
                self.pickBtn.frame = CGRectMake(x + 75 + padding, y, 75 , 75)
                self.pickBtn.hidden = i == 2 ? true : false
                //
                self.tmp = imgV
            }
        }else {
            self.pickBtn.frame = CGRectMake(8, 10, 75 , 75)
            self.pickBtn.hidden = false
        }
    }
    
    override func alertCancelAction() {
        self.back()
    }
}
