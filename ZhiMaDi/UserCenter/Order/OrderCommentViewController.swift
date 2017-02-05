//
//  OrderCommentViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/11/18.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import MWPhotoBrowser

class OrderCommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,ZMDInterceptorProtocol,MWPhotoBrowserDelegate/*,TZImagePickerControllerDelegate*/ {
    
    var isCommented = false    //区分返回按钮 调到那个页面
    
    var currentTableView: UITableView!
    var goodsScoreRigthLbl : UILabel!
    var serverScoreRightLbl : UILabel!
    var logisticsScoreRigthLbl : UILabel!
    var checkBtn : UIButton!
    var submitBtn : UIButton!
    var canSubmit = false
    var IsAnonymous = false     //匿名评价
    
    var descriptionPoint = 1//描述相符
    var servicePoint = 1    //服务态度
    var logisticsPoint = 1  //物流态度
    
    //MARK:--
    var orderId : NSNumber!         //当前订单id
    var reviews = NSMutableArray()  //OrderItemModel数组
    var comments = NSMutableArray() //ReviewText数组
    //记录currentTableVIew的cell的高度
    var cellHeights = NSMutableArray()
    
    //用来判断faceBtn的选中状态
    var rates = NSMutableArray()
    var rateBtns = NSMutableArray()
    
    let picker: UIImagePickerController = UIImagePickerController()
    var tmp : UIButton!
    
    //MARK:--TZImagePicker相关属性
    var maxImagesCount = 5
    var isSelectOriginalPhoto = true
    
    //记录选中的图片
    var photos = NSMutableArray()       //二维数组
    var selectedAssets = NSMutableArray()   //二维
    
    //用来判断是点击哪个section进入MWPhotoBrowser
    var photoIndex = 0
    
    
    //MARK: -LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateData()
        self.subViewInit()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    
    //MARK: -PrivateMethod
    //MARK: 初始化UI
    func subViewInit() {
        self.view.backgroundColor = defaultBackgroundGrayColor
        let rect = self.view.bounds
        let navigationBarH = self.navigationController?.navigationBar.frame.height
        let statusBarH = UIApplication.sharedApplication().statusBarFrame.height
        self.currentTableView = UITableView(frame:CGRect(x: 0, y: 0, width: rect.width, height: rect.height-100-navigationBarH!-statusBarH), style: .Plain)
        self.currentTableView.delegate = self
        self.currentTableView.dataSource = self
        self.currentTableView.separatorStyle = .None
        self.currentTableView.bounces = false
        self.currentTableView.backgroundColor = RGB(246,246,246,1.0)
        self.view.addSubview(self.currentTableView)
        
        let botView = self.configFootView()
        self.view.addSubview(botView)
        botView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(100)
        }
    }
    
    //MARK:数据请求
    func updateData() {
        QNNetworkTool.fetchCommentsList(self.orderId.integerValue) { (success, error, reviews) -> Void in
            if success == true {
                self.reviews.removeAllObjects()
                self.reviews.addObjectsFromArray(reviews as![AnyObject])
                for _ in self.reviews {
                    self.rates.addObject(100)
                    self.cellHeights.addObject(250+60+15)     //用于记录cell的height
                    self.photos.addObject(NSMutableArray())
                    self.selectedAssets.addObject(NSMutableArray())
                    self.rateBtns.addObject(NSMutableArray())
                    self.comments.addObject("")
                }
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: error)
            }
        }
    }
    
    //MARK:数据判断
    func checkData() {
        var count = 0
        for i in 0..<self.reviews.count {
            let rate = self.rates[i] as! Int
            let comment = self.comments[i] as! String
            if rate != 5 && comment == "" {
                break
            }
            count = count + 1
        }
        if count == self.reviews.count {
            self.canSubmit = true
            self.submitBtn.backgroundColor = defaultSelectColor
        }else{
            self.canSubmit = false
            self.submitBtn.backgroundColor = grayButtonBackgroundColor
        }
    }
    
    //MARK: 提交评论
    func submitComments() {
        let arr = NSMutableArray()
        for i in 0..<self.reviews.count {
            let review = self.reviews[i] as! ZMDProductComment
            let orderItemModel = review.OrderItemModel
            let reviewText = self.comments[i] as! String
            let rate = self.rates[i] as! Int
            let dic : NSDictionary = ["CustomerId":g_customerId!,"ReviewText":reviewText,"Rating":rate,"OrderItemId": orderItemModel.Id.integerValue,"ProductId": orderItemModel.ProductId.integerValue,"OrderId": self.orderId.integerValue,"IsAnonymous": self.IsAnonymous]
            arr.addObject(dic)
        }
        let params = ["customerId":g_customerId!,"reviews":arr]
        
        //1.文字、rate评价 -> 晒图
        QNNetworkTool.addComments(params as NSDictionary) { (success, error, productReviews) -> Void in
            if success! {
                if let productReviews = productReviews {
                    for i in 0..<productReviews.count {
                        let productReview = productReviews[i] as! ZMDCommentItem
                        let params : NSDictionary = ["productReviewId":productReview.Id.integerValue,"displayOrder":0]
                        let datas = self.photos[i] as! NSArray
                        let group = dispatch_group_create()
                        for i in 0..<datas.count {
                            //在group中开启异步任务上传图片
                            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                                let image = datas[i] as! UIImage
                                let size = CGSizeMake(image.size.width, image.size.height)
                                let file = UIImageJPEGRepresentation(self.imageWithImageSimple(image, scaledSize: size), 0.125) //压缩
                                let fileName = QNFormatTool.dateString(NSDate()) + "\(i).png"
                                
                                QNNetworkTool.uploadCommentPicture(file!, fileName: fileName, params: params, completion: { (succeed, error) -> Void in
                                    if succeed == true {
                                        
                                    }else{
                                        //                                        ZMDTool.showErrorPromptView(nil, error: error, errorMsg: "上传图片失败")
                                    }
                                })
                            })
                        }
                        //监听group完成后 UI提示
                        dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                            self.commonAlertShow(false, title: "评价成功", message: "您的评价已提交成功!", preferredStyle: .Alert)
                            self.isCommented = true
                        })
                    }
                }
            }else{
                self.commonAlertShow(false, title: "评价失败", message: "评论失败,请稍后再试!", preferredStyle: .Alert)
            }
        }
        
        
        //2.店铺评分
        QNNetworkTool.addStoreComments(self.descriptionPoint, service: self.servicePoint, logistics: self.logisticsPoint, orderId: self.orderId.integerValue, customerId: g_customerId!) { (success, error) -> Void in
            if success! {
            
            }else{
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: error)
            }
        }
    }
    //MARK: -Override Method
    override func alertCancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: -UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let mulStr = NSMutableString(string: textView.text!)
        mulStr.replaceCharactersInRange(range, withString: text)
        submitBtn.backgroundColor = mulStr.length == 0 ? grayButtonBackgroundColor : defaultSelectColor
        submitBtn.userInteractionEnabled = mulStr.length == 0 ? false : true
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let label = textView.viewWithTag(10000) as! UILabel
        label.hidden = textView.text != ""
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        let section = textView.tag
        self.comments.replaceObjectAtIndex(section, withObject: textView.text)
        self.checkData()
    }
    //MARK: -UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let size = CGSizeMake(image.size.width, image.size.height)
        let headImageData = UIImageJPEGRepresentation(image.imageWithImageSimple(size), 0.125)
        photos.addObject(UIImage(data: headImageData!)!)
        //        self.configurePhotoBtn()
        //        self.uploadImg(headImageData)
        self.picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - MWPhotoBrowserDelegate
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        let photos = self.photos[self.photoIndex]
//        return photos.count
        return UInt(photos.count)
    }
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let photos = self.photos[self.photoIndex]
        if Int(index) < photos.count {
            let photo:MWPhoto = MWPhoto(image: photos[Int(index)] as! UIImage)
            return photo
        }
        return nil
    }
    func photoBrowserDidFinishModalPresentation(photoBrowser:MWPhotoBrowser) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.reviews.count == 0 ? 0 : self.reviews.count + 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == self.reviews.count {
            return 158
        }else{
            return self.cellHeights[indexPath.section] as! CGFloat
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == self.reviews.count {
            return self.cellForStoreComment(tableView, indexPath: indexPath)
        }else{
            return self.cellForProductComment(tableView, indexPath: indexPath)
        }
    }
    
    
    
    //MARK: - TableViewCell
    //MARK: --HeaderViewBg更新UI
    func updateHeaderViewBg(headerViewBg:UIView,review:ZMDProductComment) {
        let imgView = headerViewBg.viewWithTag(10001) as! UIImageView
        if let urlStr = review.OrderItemModel.PictureUrl,url = NSURL(string: kImageAddressMain + urlStr) {
            imgView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "product_default"))
        }
    }
    //MARK: --商品评分Cell
    func cellForProductComment(tableView:UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "ProductComment"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = RGB(246,246,246,1.0)
            cell?.selectionStyle = .None
            cell?.selectionStyle = .None
            
            let headerViewBg = self.configHeadViewBg(indexPath.section)
            headerViewBg.tag = 10000
            cell?.contentView.addSubview(headerViewBg)
        }
        let review = self.reviews[indexPath.section] as! ZMDProductComment
        let headerViewBg = cell?.contentView.viewWithTag(10000)
        self.updateHeaderViewBg(headerViewBg!,review:review)
        return cell!
    }
    //MARK: --店铺评分Cell
    func cellForStoreComment(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        
        let cellId = "StoreComment"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = RGB(246,246,246,1.0)
            cell?.selectionStyle = .None
            
            let storeCommentView = self.configStoreComment()
            storeCommentView.tag = 10000
            cell?.contentView.addSubview(storeCommentView)
        }
        return cell!
    }
    
    //MARK: - SubViewUI
    //MARK: --configureFootView
    func configFootView() -> UIView {
        
        let botView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 100))
        botView.backgroundColor = RGB(246,246,246,1.0)
        let font = UIFont.systemFontOfSize(15)
        let width = "匿名评价".sizeWithFont(font, maxWidth: 120).width+22
        self.checkBtn = UIButton(frame: CGRect(x: kScreenWidth-15-width, y: 10, width: width, height: 20))
        checkBtn.setImage(UIImage(named: "cb_glossy_off"), forState: .Normal)
        checkBtn.setImage(UIImage(named: "cb_glossy_on"), forState: .Selected)
        checkBtn.setTitle("匿名评价", forState: .Normal)
        checkBtn.setTitleColor(defaultTextColor, forState: .Normal)
        checkBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        checkBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        checkBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as! UIButton).selected = !(sender as! UIButton).selected
            self.IsAnonymous = (sender as! UIButton).selected
            return RACSignal.empty()
        })
        botView.addSubview(checkBtn)
        
        self.submitBtn = ZMDTool.getButton(CGRect(x: 12, y: /*kScreenHeight - 64 - 50 - 10*/CGRectGetMaxY(checkBtn.frame)+10, width: kScreenWidth-24, height: 50), textForNormal: "提交", fontSize: 17, backgroundColor: grayButtonBackgroundColor) { (sender) -> Void in
            if self.canSubmit == false {
                ZMDTool.showPromptView("请完善商品评价信息")
                return
            }
            self.submitComments()
        }
        botView.addSubview(submitBtn)
        ZMDTool.configViewLayerWithSize(submitBtn, size: 25)
        
        return botView
    }
    
    //MARK: --configureStoreComment
    func configStoreComment() -> UIView {
        let storeCommentView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 158)) //146 = (26+17)*3+17+15+9)
        
        // 商品评分
        let scoreLbl = ZMDTool.getLabel(CGRectMake(12, 12, 120, 17), text: "店铺评分 :", fontSize: 18)
        scoreLbl.textAlignment = .Left
        storeCommentView.addSubview(scoreLbl)
        
        // 描述相符
        let goodsScoreTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(scoreLbl.frame)+17, width: 96, height: 17), text: "描述相符 :", fontSize: 17)
        storeCommentView.addSubview(goodsScoreTitleLbl)
        let goodsScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(scoreLbl.frame)+12, width: 32*5, height: 26)) { (str, point) -> Void in
            self.goodsScoreRigthLbl.text = str as String
            self.descriptionPoint = 2*(point+1)
        }
        storeCommentView.addSubview(goodsScoreView)
        self.goodsScoreRigthLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(scoreLbl.frame)+17, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        storeCommentView.addSubview(goodsScoreRigthLbl)
        
        // 服务态度
        let serverScoreLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+22, width: 96, height: 17), text: "服务态度 :", fontSize: 17)
        storeCommentView.addSubview(serverScoreLbl)
        let serverScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+17, width: 32*5, height: 26)){(str, point) ->Void in
            self.serverScoreRightLbl.text = str as String
            self.servicePoint = 2*(point+1)
        }
        storeCommentView.addSubview(serverScoreView)
        self.serverScoreRightLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(goodsScoreTitleLbl.frame)+22, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        storeCommentView.addSubview(serverScoreRightLbl)
        
        // 物流态度
        let logisticsitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(serverScoreLbl.frame)+22, width: 96, height: 17), text: "物流态度 :", fontSize: 17)
        storeCommentView.addSubview(logisticsitleLbl)
        let logisticsScoreView = GoodsScoreView(frame: CGRect(x: 108, y: CGRectGetMaxY(serverScoreLbl.frame)+17, width: 32*5, height: 26)){(str, point) ->Void in
            self.logisticsScoreRigthLbl.text = str as String
            self.logisticsPoint = 2*(point+1)
        }
        storeCommentView.addSubview(logisticsScoreView)
        self.logisticsScoreRigthLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth - 12 - 96, y: CGRectGetMaxY(serverScoreLbl.frame)+22, width: 96, height: 17), text: "满意", fontSize: 17,textColor: defaultDetailTextColor,textAlignment: .Right)
        storeCommentView.addSubview(logisticsScoreRigthLbl)
        
        return storeCommentView
    }
    
    //MARK: --configureHeadViewBg
    func configHeadViewBg(section:Int) -> UIView {
        let height = 250+60
        let headViewBg = UIView(frame: CGRect(x: 12, y: 12, width: Int(kScreenWidth-24), height: height))
        headViewBg.backgroundColor = UIColor.whiteColor()
        ZMDTool.configViewLayer(headViewBg)
        ZMDTool.configViewLayerFrame(headViewBg)
        //左上角商品图片
        let padding = (CGRectGetWidth(headViewBg.frame)-75*3)/4
        let imgView = UIImageView(frame: CGRect(x: padding, y: padding, width: 75, height: 75))
        headViewBg.addSubview(imgView)
        imgView.tag = 10001
        //评论
        let scoreTextView = ZMDTool.getTextView(CGRect(x: padding+75+5, y: 12, width: CGRectGetWidth(headViewBg.frame)-5*2-75-padding, height: 130), placeholder: "感谢您的宝贵评价~", fontSize: 16)
        scoreTextView.delegate = self
        headViewBg.addSubview(scoreTextView)
        scoreTextView.tag = section
        //买家秀
        let photoView = UIView(frame: CGRect(x: 0, y: 130, width: kScreenWidth-24, height: 116))
        photoView.backgroundColor = UIColor.clearColor()
        headViewBg.addSubview(photoView)
        photoView.tag = 10003
        //差评、中评、好评
        let faceScoreView = UIView(frame: CGRect(x: 0, y: 140+116, width: kScreenWidth-24, height: 60))
        faceScoreView.backgroundColor = UIColor.clearColor()
        headViewBg.addSubview(faceScoreView)
        faceScoreView.tag = 10004
        
        faceScoreView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(photoView.snp_bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(60)
        }
        
        self.configurePhotoBtn(photoView,section: section)
        self.configureFaceScoreView(faceScoreView,section: section)
        return headViewBg
    }
    
    //MARK: --configurePhotoBtn
    func configurePhotoBtn(photoView:UIView,section:Int){
        for subView in photoView.subviews {
            subView.removeFromSuperview()
        }
        let padding = (CGRectGetWidth(photoView.frame)-3*75)/4
        let pickBtn = UIButton(type: .Custom)
        pickBtn.backgroundColor = UIColor.clearColor()
        pickBtn.frame =  CGRectMake(padding, 10, 75 , 75)
        pickBtn.setImage(UIImage(named: "common_add_pho"), forState: .Normal)
        pickBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ [weak self](sender) -> Void in
            if let strongSelf = self {
                let imagePickerVc = TZImagePickerController(maxImagesCount: strongSelf.maxImagesCount, columnNumber: 4, delegate: nil, pushPhotoPickerVc: true)
                //四类个性化设置，这些参数都可以不传，此时会走默认设置
                imagePickerVc.isSelectOriginalPhoto = true
                
                if (strongSelf.maxImagesCount > 1) {
                    // 1.设置目前已经选中的图片数组
                    imagePickerVc.selectedAssets = strongSelf.selectedAssets[section] as! NSMutableArray
                    
                    //                    imagePickerVc.selectedAssets = strongSelf.selectedAssets // 目前已经选中的图片数组
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
                
                //MARK - 到这里为止
                // 你可以通过block或者代理，来得到用户选择的照片.
                imagePickerVc.didFinishPickingPhotosHandle = {(photos:[UIImage]!,assets:[AnyObject]!,isSelectOriginalPhoto:Bool)->Void in
                    let selectPhoto = strongSelf.photos[section] as! NSMutableArray
                    let selectAsset = strongSelf.selectedAssets[section] as! NSMutableArray
                    selectPhoto.removeAllObjects()
                    selectAsset.removeAllObjects()
                    selectPhoto.addObjectsFromArray(photos)
                    selectAsset.addObjectsFromArray(assets)
                    
                    strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
                    strongSelf.configurePhotoBtn(photoView,section: section)
                }
                strongSelf.presentViewController(imagePickerVc, animated: true, completion: nil)
            }
            })
        let bottomLbl = ZMDTool.getLabel(CGRect(x:0, y: CGRectGetMaxY(pickBtn.frame)+8, width: 75, height: 14), text: "晒图", fontSize: 14)
        bottomLbl.textAlignment = .Center
        pickBtn.addSubview(bottomLbl)
        photoView.addSubview(pickBtn)
        
        if (self.photos[section] as!NSArray).count > 0 {
            if (self.photos[section] as! NSArray).count > 2 {
                self.cellHeights[section] = 250+75+10+60+15
            }else{
                self.cellHeights[section] = 250+60+15
            }
            let padding = (CGRectGetWidth(photoView.frame) - 75*3) / 4
            var y: CGFloat = 10
            var x: CGFloat = padding
            for var i = 0 ; i < self.photos[section].count; i++ {
                let imgV: UIButton = UIButton(type: .Custom)
                imgV.frame = CGRectMake(x, y, 75 , 75)
                x = x + CGFloat((75+Int(padding)))
                //每次添加图片setPhotoBtn之前让currentScrollView上的subView回到初始位置，包括currentScrollView的contentSize
                let headViewBg = photoView.superview!
                headViewBg.set("h", value: 250+60)
                photoView.set("h", value: 116)
                
                if i==2 {   //第三张图片添加后就换行
                    y = y+75+10
                    x = padding
                }
                if i>=2 {   //第三张图添加后就改变headViewBg、photoView的frame和currentScrollView的contentSize
                    headViewBg.add("h", value: 75+10)
                    photoView.add("h", value: 75+10)
                }
                imgV.tag = i+1
                let photos = self.photos[section] as! NSMutableArray
                let assets = self.selectedAssets[section] as! NSMutableArray
                imgV.setImage(photos[i] as? UIImage, forState: .Normal)
                imgV.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                    if let strongSelf = self {
                        // Create browser
                        let  browser = PhotoBroswerViewController(delegate: self)
                        strongSelf.photoIndex = section
                        browser.isDelete = true //隐藏删除按钮
                        browser.photos = photos.count
                        browser.setCurrentPhotoIndex(UInt((input as! UIButton).tag - 1))
                        browser.deleteImages = {(index)-> Void in
                            photos.removeObjectAtIndex(index)
                            assets.removeObjectAtIndex(index)
                            strongSelf.configurePhotoBtn(photoView,section: section)
                        }
                        strongSelf.navigationController?.pushViewController(browser, animated: true)
                    }
                    return RACSignal.empty()
                    });
                let deleteBtn = UIButton(frame: CGRect(x: 75-3-18, y: 3, width: 18, height: 18))
                deleteBtn.setImage(UIImage(named: "common_delete_pho"), forState: .Normal)
                deleteBtn.tag = i
                deleteBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    photos.removeObjectAtIndex(sender.tag)
                    assets.removeObjectAtIndex(sender.tag)
                    self.configurePhotoBtn(photoView,section: section)
                })
                imgV.addSubview(deleteBtn)
                photoView.addSubview(imgV)
                pickBtn.frame = CGRectMake(x, y, 75 , 75)
                pickBtn.hidden = i == 4 ? true : false
                self.tmp = imgV
            }
        }else {
            pickBtn.frame = CGRectMake(padding, 10, 75 , 75)
            pickBtn.hidden = false
        }
        self.currentTableView.reloadData()
    }
    
    //MARK: --configureFaceScoreView
    func configureFaceScoreView(faceScoreView:UIView,section:Int) {
        for subView in faceScoreView.subviews {
            subView.removeFromSuperview()
        }
        faceScoreView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 0, width: CGRectGetWidth(faceScoreView.frame), height: 0.5), backgroundColor: defaultLineColor))
        let titles = ["好评","中评","差评"]
        let images = [("good_normal","good_select"),("soso_normal","soso_select"),("bad_normal","bad_select")]
        let width = faceScoreView.frame.width/3
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
            faceBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            faceBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.rateBtns[section].addObject(faceBtn)
            faceBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                self.rates.replaceObjectAtIndex(section, withObject: 5-(sender as! UIButton).tag+1000)
                self.checkData()
                for btn in self.rateBtns[section] as! NSMutableArray {
                    let btn = btn as! UIButton
                    btn.selected = 5-btn.tag+1000 == self.rates[section] as? Int
                }
                return RACSignal.empty()
            })
        }
    }
    
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    
    override func back() {
        if self.isCommented {
            //评价过，返回到订单类别
            let viewControllers = self.navigationController?.viewControllers
            let vc = viewControllers![1]
            self.navigationController?.popToViewController(vc, animated: true)
        }else{
            //放弃评价，回到上一级
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
