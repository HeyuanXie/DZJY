//
//  OrderGoodsScoreViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/13.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import MWPhotoBrowser
// 商品评分
class OrderGoodsScoreViewController: UIViewController,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate,/*TZImagePickerControllerDelegate,*/ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    
    var scoreTextField : UITextField!
    var pickBtn : UIButton!
    var faceScoreView : UIView!
    var headViewBg : UIView!
    var currentScrollView : UIScrollView!
    let picker: UIImagePickerController = UIImagePickerController()
    var imagePickerVc : UIImagePickerController!
    var photoView: UIView!
    var tmp : UIButton!
    var selectedFaceBtn : UIButton!
    var goodsScoreRigthLbl : UILabel!
    var serverScoreRightLbl : UILabel!
    var logisticsScoreRigthLbl : UILabel!
    
    var photos : NSMutableArray = NSMutableArray()
    var selectedAssets = NSMutableArray() //目前已选中的图片数组
    var isSelectOriginalPhoto = false
    var maxImagesCount = 5
    
    var contentSizeH : CGFloat! //记录self.currentScrollView的contentSize的height
    var frameArr = NSMutableArray() //记录self.currentScrollView所有子视图的frame
    
    var products = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initImagePickerVc()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: TextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let mulStr = NSMutableString(string: textField.text!)
        mulStr.replaceCharactersInRange(range, withString: string)
        let submitBtn = self.view.viewWithTag(20000) as!UIButton
        submitBtn.backgroundColor = mulStr.length == 0 ? grayButtonBackgroundColor : defaultSelectColor
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
    func initImagePickerVc() {
        if (self.imagePickerVc == nil) {
            imagePickerVc = UIImagePickerController()
            imagePickerVc.delegate = self;
            // set appearance / 改变相册选择页的导航栏外观
            imagePickerVc.navigationBar.barTintColor = self.navigationController!.navigationBar.barTintColor;
            imagePickerVc.navigationBar.tintColor = self.navigationController!.navigationBar.tintColor;
            var tzBarItem:UIBarButtonItem,BarItem:UIBarButtonItem
            /*if ((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 9.0) {
                //iOS 9.0后的方法
                tzBarItem = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([TZImagePickerController.classForCoder()])
                BarItem = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([TZImagePickerController.classForCoder()])
            } else {
                //iOS 9.0前的方法
//                #pragma clang diagnostic push
//                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
//                tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
//                BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
//                #pragma clang diagnostic pop
            }*/
            if #available(iOS 9.0, *) {
                tzBarItem = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([TZImagePickerController.classForCoder()])
                BarItem = UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UIImagePickerController.classForCoder()])
                let titleTextAttributes = tzBarItem.titleTextAttributesForState(.Normal)
                BarItem.setTitleTextAttributes(titleTextAttributes, forState: .Normal)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    func updateUI() {
        self.title = "商品评分"
        self.view.backgroundColor = RGB(245,245,245,1)
        self.picker.delegate = self
        
        let currentScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-50-68))
        currentScrollView.showsVerticalScrollIndicator = false
        currentScrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(currentScrollView)
        self.currentScrollView = currentScrollView
        
        let headViewBg = UIView(frame: CGRect(x: 12, y: 15, width: kScreenWidth-24, height: 250+60))
        headViewBg.backgroundColor = UIColor.whiteColor()
        ZMDTool.configViewLayer(headViewBg)
        ZMDTool.configViewLayerFrame(headViewBg)
        currentScrollView.addSubview(headViewBg)
        self.headViewBg = headViewBg

        self.scoreTextField = ZMDTool.getTextField(CGRect(x: 16, y: 15, width: CGRectGetWidth(headViewBg.frame), height: 130), placeholder: "感谢您的宝贵评价~", fontSize: 17)
        self.scoreTextField.contentVerticalAlignment = .Top //方向
        self.scoreTextField.delegate = self 
        headViewBg.addSubview(self.scoreTextField)
        
        photoView = UIView(frame: CGRect(x: 0, y: 130, width: kScreenWidth-24, height: 116))
        photoView.backgroundColor = UIColor.clearColor()
        headViewBg.addSubview(photoView)
        
        faceScoreView = UIView(frame: CGRect(x: 0, y: 140+116, width: kScreenWidth-24, height: 60))
        faceScoreView.backgroundColor = UIColor.clearColor()
        headViewBg.addSubview(faceScoreView)
        
        faceScoreView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(photoView.snp_bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(60)
        }
        
        self.configurePhotoBtn()
        self.configureFaceScoreView()
        
        
        
        // 商品评分
        let scoreLbl = ZMDTool.getLabel(CGRectMake(12, CGRectGetMaxY(headViewBg.frame)+30, 120, 17), text: "商品评分 :", fontSize: 18)
        scoreLbl.textAlignment = .Left
        currentScrollView.addSubview(scoreLbl)
        
        // 描述相符
        let goodsScoreTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(scoreLbl.frame)+17, width: 96, height: 17), text: "描述相符 :", fontSize: 17)
        currentScrollView.addSubview(goodsScoreTitleLbl)
        let goodsScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(scoreLbl.frame)+12, width: 32*5, height: 26)){(str,point) ->Void in
            self.goodsScoreRigthLbl.text = str as String
        }
        currentScrollView.addSubview(goodsScoreView)
        self.goodsScoreRigthLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(scoreLbl.frame)+17, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        currentScrollView.addSubview(goodsScoreRigthLbl)
        
        
        // 服务态度
        let serverScoreLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+22, width: 96, height: 17), text: "服务态度 :", fontSize: 17)
        currentScrollView.addSubview(serverScoreLbl)

        let serverScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+17, width: 32*5, height: 26)){(str,point) ->Void in
            self.serverScoreRightLbl.text = str as String
        }
        currentScrollView.addSubview(serverScoreView)

        self.serverScoreRightLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+22, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        currentScrollView.addSubview(serverScoreRightLbl)

        
        // 物流态度
        let logisticsitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(serverScoreLbl.frame)+22, width: 96, height: 17), text: "物流态度 :", fontSize: 17)
//        self.view.addSubview(logisticsitleLbl)
        currentScrollView.addSubview(logisticsitleLbl)
        let logisticsScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(serverScoreLbl.frame)+17, width: 32*5, height: 26)){(str,point) ->Void in
            self.logisticsScoreRigthLbl.text = str as String
        }
//        self.view.addSubview(logisticsScoreView)
        currentScrollView.addSubview(logisticsScoreView)
        self.logisticsScoreRigthLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(serverScoreLbl.frame)+22, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
//        self.view.addSubview(logisticsScoreRigthLbl)
        currentScrollView.addSubview(logisticsScoreRigthLbl)
        //设置currentScrollView滚动范围
        self.contentSizeH = CGRectGetMaxY(logisticsScoreView.frame)+20
        currentScrollView.contentSize = CGSizeMake(0, self.contentSizeH)
        
        let submitBtn = ZMDTool.getButton(CGRect(x: 12, y: kScreenHeight - 64 - 50 - 10, width: kScreenWidth-24, height: 50), textForNormal: "提交", fontSize: 17, backgroundColor: RGB(215,215,215,1)) { (sender) -> Void in
            
            self.commonAlertShow(false,title: "商品评价", message: "您好,您的评价已提交!", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        submitBtn.tag = 20000
        submitBtn.userInteractionEnabled = false
        ZMDTool.configViewLayerWithSize(submitBtn, size: 25)
        self.view.addSubview(submitBtn)
        
        //所有控件放好后记录self.currentScrollView上subViews的frame，方便添加图片时初始化他们位置
        for view in self.currentScrollView.subviews {
            let value = NSValue(CGRect: view.frame)
            self.frameArr.addObject(value)
        }
    }
    
    
    //MARK: commemAlert确定action的重写
    override func alertDestructiveAction() {
        print("评分")
        //点击确定时返回上一个页面
    }
    
    override func alertCancelAction() {
        self.back()
    }
    
    func configurePhotoBtn(){
        for subView in self.photoView.subviews {
            subView.removeFromSuperview()
        }
        if self.pickBtn == nil {
            self.pickBtn = UIButton(type: .Custom)
            pickBtn.backgroundColor = UIColor.clearColor()
            pickBtn.frame =  CGRectMake(10, 10, 75 , 75)
            pickBtn.setImage(UIImage(named: "common_add_pho"), forState: .Normal)
            self.pickBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ [weak self](sender) -> Void in
                if let strongSelf = self {
                    let imagePickerVc = TZImagePickerController(maxImagesCount: strongSelf.maxImagesCount, columnNumber: 4, delegate: nil, pushPhotoPickerVc: true)
                    //MARK: - 四类个性化设置，这些参数都可以不传，此时会走默认设置
                    imagePickerVc.isSelectOriginalPhoto = true
                    
                    if (strongSelf.maxImagesCount > 1) {
                        // 1.设置目前已经选中的图片数组
                        imagePickerVc.selectedAssets = strongSelf.selectedAssets // 目前已经选中的图片数组
                    }
                    imagePickerVc.allowTakePicture = true // 在内部显示拍照按钮
                    
                    // 2. 在这里设置imagePickerVc的外观
//                     imagePickerVc.navigationBar.barTintColor = navigationBackgroundColor
//                     imagePickerVc.oKButtonTitleColorDisabled = UIColor.lightGrayColor()
//                     imagePickerVc.oKButtonTitleColorNormal = defaultSelectColor //UIColor.whiteColor()
                    
                    // 3. 设置是否可以选择视频/图片/原图
                    imagePickerVc.allowPickingVideo = true
                    imagePickerVc.allowPickingImage = true
                    imagePickerVc.allowPickingOriginalPhoto = true
                    
                    // 4. 照片排列按修改时间升序
                    imagePickerVc.sortAscendingByModificationDate = true
                    
                     imagePickerVc.minImagesCount = 0
                     imagePickerVc.alwaysEnableDoneBtn = true
                    
                    //设置可选照片的尺寸规定
//                     imagePickerVc.minPhotoWidthSelectable = 3000
//                     imagePickerVc.minPhotoHeightSelectable = 2000

                    //MARK - 到这里为止
                    // 你可以通过block或者代理，来得到用户选择的照片.
                    imagePickerVc.didFinishPickingPhotosHandle = {(photos:[UIImage]!,assets:[AnyObject]!,isSelectOriginalPhoto:Bool)->Void in
                        strongSelf.photos = NSMutableArray(array: photos)
                        strongSelf.selectedAssets = NSMutableArray(array:assets)
                        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
                        strongSelf.configurePhotoBtn()
                    }
                    strongSelf.presentViewController(imagePickerVc, animated: true, completion: nil)
                }
            })
            
           /* self.pickBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ [weak self](sender) -> Void in
                if let strongSelf = self {
                    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let action1 = UIAlertAction(title: "从手机中选择照片", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
                        strongSelf.picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                        self?.presentViewController((self?.picker)!, animated: true, completion: nil)
                    })
                    let action2 = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default, handler: { (sender) -> Void in
                        strongSelf.picker.sourceType = UIImagePickerControllerSourceType.Camera
                        self?.presentViewController((self?.picker)!, animated: true, completion: nil)
                    })
                    let action3 = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
                    actionSheet.addAction(action1)
                    actionSheet.addAction(action2)
                    actionSheet.addAction(action3)
                    self?.presentViewController(actionSheet, animated: true, completion: nil)
                }
                })*/
            
            let bottomLbl = ZMDTool.getLabel(CGRect(x:0, y: CGRectGetMaxY(pickBtn.frame)+8, width: 75, height: 14), text: "晒图", fontSize: 14)
            bottomLbl.textAlignment = .Center
            pickBtn.addSubview(bottomLbl)
        }
        self.photoView.addSubview(self.pickBtn)
        if self.photos.count > 0 {
            let padding = (CGRectGetWidth(photoView.frame) - 75*3) / 4
            var y: CGFloat = 10
            var x: CGFloat = padding
            for var i = 0 ; i < self.photos.count; i++ {
                let imgV: UIButton = UIButton(type: .Custom)
                imgV.frame = CGRectMake(x, y, 75 , 75)
                x = x + CGFloat((75+Int(padding)))
                //每次添加图片setPhotoBtn之前让currentScrollView上的subView回到初始位置，包括currentScrollView的contentSize
                self.headViewBg.set("h", value: 250+60)
                self.photoView.set("h", value: 116)
                self.currentScrollView.contentSize = CGSizeMake(0, self.contentSizeH)
                var index = 0
                for view in self.currentScrollView.subviews {
                    let value = self.frameArr[index++] as! NSValue
                    view.frame = NSValue.CGRectValue(value)()
                }
                if i==2 {   //第三张图片添加后就换行
                    y = y+75+10
                    x = padding
                }
                if i>=2 {   //第三张图添加后就改变headViewBg、photoView的frame和currentScrollView的contentSize
                    self.headViewBg.add("h", value: 75+10)
                    self.photoView.add("h", value: 75+10)
                    self.currentScrollView.contentSize = CGSizeMake(0, self.contentSizeH+75+10)
                    for view in self.currentScrollView.subviews {
                        if view.isKindOfClass(UILabel) || view.isKindOfClass(GoodsScoreView) {
                            view.add("y", value: 75+10)
                        }
                    }
                }
                imgV.tag = i+1
                imgV.setImage(self.photos[i] as? UIImage, forState: .Normal)
                imgV.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                    if let strongSelf = self {
                        // Create browser
                        let  browser = PhotoBroswerViewController(delegate: self)
                        browser.isDelete = true //隐藏删除按钮
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
                    self.selectedAssets.removeObjectAtIndex(sender.tag)
                    self.configurePhotoBtn()
                })
                imgV.addSubview(deleteBtn)
                self.photoView.addSubview(imgV)
                self.pickBtn.frame = CGRectMake(x, y, 75 , 75)
                self.pickBtn.hidden = i == 4 ? true : false
                self.tmp = imgV
            }
        }else {
            self.pickBtn.frame = CGRectMake(8, 10, 75 , 75)
            self.pickBtn.hidden = false
        }
    }
    
    func configureFaceScoreView() {
        for subView in self.faceScoreView.subviews {
            subView.removeFromSuperview()
        }
        self.faceScoreView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: CGRectGetWidth(self.faceScoreView.frame), height: 0.5), backgroundColor: defaultLineColor))
        let titles = ["好评","中评","差评"]
        let images = [("user_pingfen_unselected","user_pingfen_selected"),("user_pingfen_unselected","user_pingfen_selected"),("user_pingfen_unselected","user_pingfen_selected")]
        let width = self.faceScoreView.frame.width/3
        for i in 0..<3 {
            let faceBtn = UIButton(type: .Custom)
            faceBtn.frame = CGRect(x: CGFloat(i)*width, y: 0, width: width, height: 50)
            faceBtn.tag = 1000 + i
            faceScoreView.addSubview(faceBtn)
            faceBtn.setTitle(titles[i], forState: .Normal)
            faceBtn.setTitleColor(defaultTextColor, forState: .Normal)
            faceBtn.setTitleColor(defaultSelectColor, forState: .Selected)
            faceBtn.setImage(UIImage(named: images[i].0), forState: .Normal)
            faceBtn.setImage(UIImage(named: images[i].1), forState: .Selected)
            faceBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            faceBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            if i == 0 {
                self.selectedFaceBtn = faceBtn
                self.selectedFaceBtn.selected = true
            }
            
            faceBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                if self.selectedFaceBtn == (sender as! UIButton) {
                    return RACSignal.empty()
                }
                self.selectedFaceBtn.selected = false
                self.selectedFaceBtn = sender as! UIButton
                self.selectedFaceBtn.selected = true
                
                return RACSignal.empty()
            })
        }
    }
}
