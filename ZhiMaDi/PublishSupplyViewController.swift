//
//  PublishSupplyViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/13.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//发布供应/发布求购
class PublishSupplyViewController: UIViewController,ZMDInterceptorProtocol,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate ,HZQDatePickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    enum ContentType {
        case Supply,Demand
    }
    enum CellType {
        case kPicture,kName,kSupplyQuantity,kDemandQuantity,kMiniQuantity,kSupplyPrice,kDemandPrice,kEndTime,kLocation,kContactName,kContactPhone,kDescription
        var title : String {
            switch self {
            case .kPicture:
                return "   添加产品图"
            case .kName:
                return " * 标题"
                
            case .kSupplyQuantity:
                return " * 供应量"
            case .kMiniQuantity:
                return "   起订量(不填则表示没有限定)"
            case .kSupplyPrice:
                return " * 供应价格"
                
            case .kDemandQuantity:
                return " * 采购量"
            case .kDemandPrice:
                return " * 期望价格"
                
            case .kEndTime:
                return " * 截止时间"
            case .kLocation:
                return " * 所在地"
            case .kContactName:
                return " * 联系人"
            case .kContactPhone:
                return "   联系电话"
            case .kDescription:
                return "   产品说明(最多可输入800个字)"
            }
        }
        
        var tag : Int {
            switch self {
            case .kName:
                return 10001
            case .kSupplyQuantity:
                return 10002
            case .kSupplyPrice:
                return 10003
            case .kEndTime:
                return 10004
            case .kLocation:
                return 10005
            case .kContactName:
                return 10006
            case .kContactPhone:
                return 10007
            case .kMiniQuantity:
                return 10008
                
            case .kDemandQuantity:
                return 10002
            case .kDemandPrice:
                return 10003
                
                
            default:
                return 0
            }
        }
        
        var placeholder : String {
            switch self {
            case .kPicture:
                return ""
            case .kName:
                return "请输入标题"
                
            case .kSupplyQuantity:
                return "请输入数量"
            case .kMiniQuantity:
                return "请输入数量"
            case .kSupplyPrice:
                return "请输入价格"
                
            case .kDemandQuantity:
                return "请输入数量"
            case .kDemandPrice:
                return "请输入价格"
                
            case .kEndTime:
                return "请选择时间"
            case .kLocation:
                return "请选择所在地"
            case .kContactName:
                return "请输入联系人"
            case .kContactPhone:
                return "请输入联系电话"
            case .kDescription:
                return "请输入..."
            }
        }

    }
    var contentType = ContentType.Supply
    var cellTypes = [CellType.kPicture,.kName,.kSupplyQuantity,.kMiniQuantity,.kSupplyPrice,.kEndTime,.kLocation,.kContactName,.kContactPhone,.kDescription]
    var id : Int = 0    // id == 0 表示新增，id != 0表示修改,默认为新增
    var data : ZMDSupplyProduct!
    
    var pictures = NSMutableArray() //修改供应时已经上传过的图片
    var images = NSMutableArray()   //从本地选择的照片
    
    @IBOutlet weak var currentTableView : UITableView!
    @IBOutlet weak var publishBtn: UIButton!
    var descriptionCellHeight = zoom(200)
    @IBAction func publishAction(sender: AnyObject) {
        if self.checkData() {
            if self.id == 0 {
                self.publishSupplyOrDemand()
            }else{
                self.updateSupplyOrDemand()
            }
        }
    }
    var pickerView : HZQDatePickerView!
    var picker : UIImagePickerController?
    
    var quantityUnit = "吨"
    var priceUnit = "吨"
    var minQuantityUnit = "吨"
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.dataInit()
        self.initUI()
        self.fetchData()
        // Do any additional setup after loading the view.
    }

    
    //MARK: - PrivateMethod
    func dataInit() {
        if self.contentType == .Demand {
            self.cellTypes = [CellType.kName,.kDemandQuantity,.kDemandPrice,.kEndTime,.kLocation,.kContactName,.kContactPhone,.kDescription]
        }
//        self.data = self.data == nil ? ZMDSupplyProduct() : self.data
        self.data = ZMDSupplyProduct()
        
    }
    func initUI() {
        self.title = self.contentType == .Supply ? "发布供应" : "发布求购"
        self.publishBtn.setTitle(self.id == 0 ? "发布" : "修改", forState: .Normal)
    }
    
    func fetchData() {
        //id == 0 表示新增供应
        if self.id == 0 {
            return
        }
        QNNetworkTool.supplyDemandDetail(self.id) { (success, supplyProduct, error) -> Void in
            if success! {
                self.data = supplyProduct
                if let pictures = self.data.SupplyDemandPictures {
                    self.pictures.addObjectsFromArray(pictures)
                }
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
    }
    
    func checkData() -> Bool {
        if let data = self.data {
            if data.Title == "" {
                ZMDTool.showPromptView("请输入标题")
                return false
            }
            if data.Quantity == 0 {
                ZMDTool.showPromptView(self.contentType == .Supply ? "请输入供应量" : "请输入采购量")
                return false
            }
            if data.Price == 0 {
                ZMDTool.showPromptView(self.contentType == .Supply ? "请输入供应价格" : "请输入期望价格")
                return false
            }
            if data.EndTime == "" {
                ZMDTool.showPromptView("请输入截止日期")
                return false
            }
            if data.AreaName == "" {
                ZMDTool.showPromptView("请输入所在地")
                return false
            }
            if data.UserName == "" {
                ZMDTool.showPromptView("请输入联系人")
                return false
            }
            if data.MinQuantity == 0 {
                data.MinQuantity = 0
            }
            
            
            if self.contentType == .Supply {
                data.Id = self.id
                data.Type = 1   //供应
            }else{
                data.Type = 2   //求购
            }
            data.PriceUnit = self.priceUnit
            data.QuantityUnit = self.quantityUnit
            data.MinQuantityUnit = self.minQuantityUnit
            data.CustomerId = g_customerId
        }else{
            ZMDTool.showPromptView(self.contentType == .Supply ? "请填写供应信息" : "请填写求购信息")
            return false
        }
        return true
    }
    
    func publishSupplyOrDemand() {
        ZMDTool.showActivityView(nil)
        QNNetworkTool.supplyDemandPublish(self.data) { (success, errorMsg, supplyDemandsId) -> Void in
            ZMDTool.hiddenActivityView()
            if success! {
                ZMDTool.showPromptView((self.contentType == .Supply ? "供应" : "求购") + "发布成功")
                self.uploadSupplyImages(supplyDemandsId!)
            }else{
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: errorMsg)
            }
        }
    }
    
    func updateSupplyOrDemand() {
        ZMDTool.showActivityView(nil)
        QNNetworkTool.supplyDemandAmend(self.data) { (success, errorMsg, supplyDemandsId) -> Void in
            ZMDTool.hiddenActivityView()
            if success! {
                ZMDTool.showPromptView((self.contentType == .Supply ? "供应" : "求购") + "修改成功")
                self.uploadSupplyImages(supplyDemandsId!)
            }else{
                ZMDTool.showErrorPromptView(nil, error: nil, errorMsg: errorMsg)
            }
        }
    }
    
    func uploadSupplyImages(id:Int) {
        var index = -1
        for image in self.images {
            index = index + 1
            let size = CGSizeMake(image.size.width, image.size.height)
            let headImageData = UIImageJPEGRepresentation(self.imageWithImageSimple(image as! UIImage, scaledSize: size), 0.125) //压缩
            QNNetworkTool.supplyPublishUploadImage(id,file: headImageData!, fileName: "image\(index)", completion: { (success, error) -> Void in
                if success == true {
                    
                }else{
                    ZMDTool.showPromptView("图片上传失败")
                }
            })
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellTypes.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.contentType == .Supply && section == 0 {
            return 1
        }
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .kPicture:
            return self.images.count+self.pictures.count != 0 ? 241 : 97
        case .kDescription:
            return indexPath.row == 0 ? 42 : self.descriptionCellHeight
        default:
            return indexPath.row == 0 ? 42 : 52
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .kPicture:
            return self.cellForUploadImage(tableView,indexPath:indexPath)
        case .kDescription:
            if indexPath.row == 0 {
                return self.cellForHead(tableView,indexPath:indexPath)
            }else{
                return self.cellForDescription(tableView,indexPath:indexPath)
            }
        default:
            if indexPath.row == 0 {
                return self.cellForHead(tableView,indexPath:indexPath)
            }else{
                return self.cellForTextField(tableView,indexPath:indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .kEndTime:
            self.pickerView = HZQDatePickerView.instanceDatePickerView()
            self.pickerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight + 20)
            self.pickerView.backgroundColor = UIColor.clearColor()
            self.pickerView.delegate = self
            self.pickerView.type = DateType.init(0)
            self.pickerView.datePickerView?.minimumDate = NSDate()
            self.view.addSubview(self.pickerView)
            break
        case .kLocation:
            let vc = AddressSelectViewController()
            vc.finished = {(text) -> Void in
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextFieldCell
                cell.textField.text = text
                self.data.AreaName = text
            }
            self.presentViewController(vc, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    //MARK: - TableViewCell
    func cellForUploadImage(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "uploadImageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        cell?.selectionStyle = .None
        let scrollView = cell?.contentView.viewWithTag(10000) as! UIScrollView
        scrollView.showsHorizontalScrollIndicator = false
        let addBtn = cell?.contentView.viewWithTag(10001) as! UIButton
        ZMDTool.configViewLayer(addBtn)
        if self.images.count+self.pictures.count == 5 {
            addBtn.backgroundColor = defaultGrayColor
            addBtn.userInteractionEnabled = false
        }else{
            addBtn.backgroundColor = appThemeColor
            addBtn.userInteractionEnabled = true
        }
        let countLbl = cell?.contentView.viewWithTag(10002) as! UILabel
        for subView in scrollView.subviews {
            subView.removeFromSuperview()
        }
        
        if self.images.count == 0 && self.pictures.count == 0 {
            scrollView.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(0)
                make.height.equalTo(0)
            })
        }else{
            scrollView.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(17)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(135)
            })
            scrollView.contentSize = CGSizeMake(12+CGFloat(self.images.count+self.pictures.count)*(135+10)+12, 0)
            var index = -1
            for item in self.pictures {
                index = index + 1
                let picture = item as! ZMDSupplyPicture
                let view = UIView(frame: CGRect(x: 12+CGFloat(index)*(135+10), y: 0, width: 135, height: 135))
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 135, height: 135))
                imgView.sd_setImageWithURL(NSURL(string: kImageAddressMain+picture.PictureUrl), placeholderImage: nil)
                view.addSubview(imgView)
                scrollView.addSubview(view)
            }
            for image in self.images {
                index = index + 1
                let view = UIView(frame: CGRect(x: 12+CGFloat(index)*(135+10), y: 0, width: 135, height: 135))
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 135, height: 135))
                imgView.image = image as? UIImage
                view.addSubview(imgView)
                let deleteBtn = UIButton(frame: CGRect(x: 105, y: 0, width: 30, height: 30))
                deleteBtn.setImage(UIImage(named: "删除图片"), forState: .Normal)
                deleteBtn.tag = index
                deleteBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    self.images.removeObjectAtIndex((sender as! UIButton).tag)
                    self.currentTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                    return RACSignal.empty()
                })
                view.addSubview(deleteBtn)
                scrollView.addSubview(view)
            }
        }
        
        addBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
            actionSheet.bk_addButtonWithTitle("从手机相册选择", handler: { () -> Void in
                if self.picker == nil {
                    self.picker = UIImagePickerController()
                    self.picker!.delegate = self
                    self.picker!.allowsEditing = true
                }
                self.picker?.sourceType = .SavedPhotosAlbum
                self.presentViewController(self.picker!, animated: true, completion: nil)
            })
            actionSheet.bk_addButtonWithTitle("拍照", handler: { () -> Void in
                if self.picker == nil {
                    self.picker = UIImagePickerController()
                    self.picker!.delegate = self
                    self.picker!.allowsEditing = true
                }
                self.picker?.sourceType = .Camera
                self.presentViewController(self.picker!, animated: true, completion: nil)
            })
            actionSheet.showInView(self.view)
            return RACSignal.empty()
        })
        countLbl.text = "(还可上传\(5-self.images.count-self.pictures.count)张,最多可上传5张)"
        
        return cell!
    }
    func cellForDescription(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "descriptionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            
            let textView = ZMDTool.getTextView(CGRect(x: zoom(10), y: zoom(10), width: kScreenWidth-zoom(20), height: zoom(180)), placeholder: "", fontSize: 14)
            ZMDTool.configViewLayerFrameWithColor(textView, color: defaultLineColor)
            ZMDTool.configViewLayerWithSize(textView, size: 2)
            textView.tag = 10000+indexPath.section
            textView.delegate = self
            cell?.contentView.addSubview(textView)
        }
        if let data = self.data {
            let textView = cell?.contentView.viewWithTag(10000+indexPath.section) as! UITextView
            textView.text = data.Description
        }
        return cell!
    }
    
    func cellForHead(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellType = self.cellTypes[indexPath.section]
        let cellId = "headCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.backgroundColor = defaultGrayColor
            
            let lbl = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: kScreenWidth, height: 42), text: cellType.title, fontSize: 15, textColor: defaultTextColor, textAlignment: .Left)
            lbl.tag = 10000
            cell?.contentView.addSubview(lbl)
        }
        let lbl = cell?.contentView.viewWithTag(10000) as! UILabel
        lbl.text = cellType.title
        for str in ["*","(不填则表示没有限定)","(最多可输入800个字)"] {
            if (lbl.text?.isConcludeSubString(str))! {
                if str == "*" {
                    lbl.attributedText = lbl.text?.AttributeText(["*"], colors: [appThemeColor], textSizes: [15])
                    lbl.attributedText = lbl.text?.AttributedText("*", color: appThemeColor)
                }else if str == "(不填则表示没有限定)" {
                    lbl.attributedText = lbl.text?.AttributeText(["*",str], colors: [appThemeColor,defaultDetailTextColor], textSizes: [15,13])
                }else{
                    lbl.attributedText = lbl.text?.AttributeText([str], colors: [defaultDetailTextColor], textSizes: [13])
                }
            }
        }
         return cell!
    }
    
    func cellForTextField(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellType = self.cellTypes[indexPath.section]
        let cellId = "textFieldCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! TextFieldCell
        cell.unitBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let sheet = UIAlertController(title: "单位", message: "", preferredStyle: .ActionSheet)
            for title in ["吨","kg","件","个"] {
                sheet.addAction(UIAlertAction(title: title, style: .Default, handler: { (sheet) -> Void in
                    cell.unitLbl.text = title
                    if cellType == .kSupplyQuantity || cellType == .kDemandQuantity {
                        self.quantityUnit = cell.unitLbl.text!
                        self.data.QuantityUnit = self.quantityUnit
                    }
                    if cellType == .kSupplyPrice || cellType == .kDemandPrice {
                        self.priceUnit = cell.unitLbl.text!
                        self.data.PriceUnit = self.priceUnit
                    }
                    if cellType == .kMiniQuantity {
                        self.minQuantityUnit = cell.unitLbl.text!
                        self.data.MinQuantityUnit = self.minQuantityUnit
                    }
                }))
            }
            sheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            self.presentViewController(sheet, animated: true, completion: nil)
            return RACSignal.empty()
        })
        ZMDTool.configTableViewCellDefault(cell)
        cell.textField.tag = cellType.tag
        cell.textField.placeholder = cellType.placeholder
        
        if cellType == .kName || cellType == .kEndTime || cellType == .kLocation || cellType == .kContactName || cellType == .kContactPhone {
            for subView in cell.contentView.subviews {
                if !(subView is UITextField) {
                    subView.hidden = true
                }
            }
        }else if cellType == .kDemandQuantity || cellType == .kSupplyQuantity || cellType == .kMiniQuantity {
            cell.priceUnitLbl.hidden = true
            cell.unitLbl.hidden = false
            cell.line.hidden = false
            cell.unitBtn.hidden = false
        }
        
        //设置时间、所在地
        if cellType == .kEndTime || cellType == .kLocation {
            cell.accessoryType = .DisclosureIndicator
            cell.textField.userInteractionEnabled = false
        }else{
            cell.accessoryType = .None
            cell.textField.userInteractionEnabled = true
        }
        //设置相关单位,解决cell复用问题
        if cellType == .kSupplyPrice || cellType == .kDemandPrice {
            cell.unitLbl.text = self.priceUnit
        }
        if cellType == .kSupplyQuantity || cellType == .kDemandQuantity {
            cell.unitLbl.text = self.quantityUnit
        }
        if cellType == .kMiniQuantity {
            cell.unitLbl.text = self.minQuantityUnit
        }
        //如果为修改供求，将已有数据加载到UI
        if let data = self.data {
            var text = ""
            switch cellType {
            case .kName:
                text = data.Title
            case .kSupplyQuantity:
                text = data.Quantity == 0 ? "" : "\(data.Quantity)"
                cell.unitLbl.text = data.QuantityUnit
            case .kDemandQuantity:
                text = data.Quantity == 0 ? "" : "\(data.Quantity)"
                cell.unitLbl.text = data.QuantityUnit
            case .kMiniQuantity:
                text = data.MinQuantity == 0 ? "" : "\(data.MinQuantity)"
                cell.unitLbl.text = data.MinQuantityUnit
            case .kSupplyPrice:
                text = data.Price == 0 ? "" : "\(data.Price)"
                cell.unitLbl.text = data.PriceUnit
            case .kDemandPrice:
                text = data.Price == 0 ? "" : "\(data.Price)"
                cell.unitLbl.text = data.PriceUnit
            case .kEndTime:
                text = data.EndTime.componentsSeparatedByString("T").first!
            case .kLocation:
                text = data.AreaName
            case .kContactName:
                text = data.UserName
            case .kContactPhone:
                text = data.Phone ?? ""
            default:
                break
            }
            
            cell.textField.text = text
        }
        return cell
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        btn.tag = 100
        self.view.addSubview(btn)
        btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //移除灰色背景btn
            btn.removeFromSuperview()
            textView.resignFirstResponder()
            return RACSignal.empty()
        })
    }

//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        let section = textView.tag - 10000
//        let size = textView.text.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: kScreenWidth-zoom(20))
//        if size.height > zoom(30) && self.descriptionCellHeight != zoom(50) + size.height-zoom(30) + 10 {
//            self.descriptionCellHeight = zoom(50) + size.height-zoom(30) + 10
//            textView.set("h", value: zoom(30)+size.height-zoom(30) + 10)
//            self.currentTableView.reloadSections(NSIndexSet(index: ), withRowAnimation: .None)
//        }else if self.descriptionCellHeight != zoom(50) {
//            self.descriptionCellHeight = zoom(50)
//            textView.set("h", value: zoom(30))
//            self.currentTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
//        }
//        return true
//    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let btn = self.view.viewWithTag(100) as? UIButton {
            btn.removeFromSuperview()
        }
        if self.data == nil {
            self.data = ZMDSupplyProduct()
        }
        self.data.Description = textView.text
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        btn.tag = 100
        self.view.addSubview(btn)
        btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //移除灰色背景btn
            btn.removeFromSuperview()
            textField.resignFirstResponder()
            return RACSignal.empty()
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let btn = self.view.viewWithTag(100) as? UIButton {
            btn.removeFromSuperview()
        }
        let text = textField.text
        if text == "" {
            return
        }
        let intValue = (text! as NSString).integerValue
        let floatValue = (text! as NSString).floatValue
        if self.data == nil {
            self.data = ZMDSupplyProduct()
        }
        switch textField.tag {
        case 10001:
            self.data.Title = text
        case 10002:
            self.data.Quantity = intValue
        case 10003:
            self.data.Price = floatValue
        case 10004:
            self.data.EndTime = text
        case 10005:
            self.data.AreaName = text
        case 10006:
            self.data.UserName = text
        case 10007:
            self.data.Phone = text
        case 10008:
            self.data.MinQuantity = intValue
        default:
            break
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //MARK: - TimePickerDelegate
    func getSelectDate(date: String!, type: DateType) {
        let section = self.contentType == .Supply ? 5 : 3
        let cell = self.currentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: section)) as! TextFieldCell
        cell.textField.text = date
        self.data.EndTime = date
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info["UIImagePickerControllerEditedImage"] as! UIImage
        // 存储图片
        self.images.addObject(image)
        self.currentTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    
    //MARK: - OverrideMethod
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


//MARK: - OtherClass
class TextFieldCell : UITableViewCell {
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var priceUnitLbl : UILabel!
    @IBOutlet weak var line : UILabel!
    @IBOutlet weak var unitLbl : UILabel!
    @IBOutlet weak var unitBtn : UIButton!
}
