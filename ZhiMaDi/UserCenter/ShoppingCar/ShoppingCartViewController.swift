//
//  ShoppingCartViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 购物车
class ShoppingCartViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol {
    @IBOutlet weak var currentTableView: UITableView!
    @IBOutlet weak var settlementBtn: UIButton!
    @IBOutlet weak var allSelectBtn: UIButton!
    @IBOutlet weak var totalLbl: UILabel!
    var productAttrV : ZMDProductAttrView!
    var dataArray = NSMutableArray()    //fetchShoppingCar得到的商品一维数组
    var storeArray = NSMutableArray()   //将dataArray按店铺分组得到的商品二维数组
    var hideStore = false
    var attrSelects = NSMutableArray()         //所有的购物车内的数据
    var scis = NSMutableArray()             // 选中的购物单
    var countForBounght = 0                 // 购买数量
    var subTotal = ""
    
    var isAllSelected = false
    
    var hiddenLbl : UILabel!        //是否登陆的label
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.dataUpdate()
        if g_isLogin! && self.hiddenLbl != nil {
            self.hiddenLbl.removeFromSuperview()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + self.storeArray[section].count   //头部灰色cell + storeCell + goodCell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.storeArray.count    //storeArray为商品按店铺id分类的二维数组
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 16
        } else {
            return indexPath.row == 1 ? 48 : 110
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //当有多个商家时，采用group样式tableView，section的headerView 采用这个headView
        //*****通过xib自定义的headerView
//        let headView = NSBundle.mainBundle().loadNibNamed("StoreHeaderView", owner: nil, options: nil).first as! StoreHeaderView
//        headView.storeBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
//            //选中当前section中所有cell
//            return RACSignal.empty()
//        })
//        headView.detailBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
//            //进入商家页面
//            return RACSignal.empty()
//        })
//        headView.backgroundColor = UIColor.whiteColor()
//        return headView
        let view = ZMDTool.getLine(CGRect(x: 0, y: 0, width: kScreenWidth, height: 1))
        return view
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //每个店家头部灰色cell
            let cellId = "HeadGrayCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                ZMDTool.configTableViewCellDefault(cell!)
                cell?.selectionStyle = .None
                cell?.contentView.backgroundColor = tableViewdefaultBackgroundColor
            }
            return cell!
        }
        if indexPath.row == 1 {
            
            let cellId = "StoreCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            let line = ZMDTool.getLine(CGRect(x: 0, y: 47.5, width: kScreenWidth, height: 0.5))
            cell?.contentView.addSubview(line)
            let product = self.storeArray[indexPath.section].firstObject as! ZMDShoppingItem
            (cell?.viewWithTag(10001) as!UILabel).text = product.Store.Name
            
            let selectBtn = cell?.viewWithTag(10000) as! UIButton
            //判断店内商品是否全部选中
            selectBtn.selected = self.isStoreAllSelected(indexPath)
            selectBtn.setImage(UIImage(named: "common_01unselected"), forState: .Normal)
            selectBtn.setImage(UIImage(named: "common_02selected"), forState: .Selected)
            
            selectBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                (sender as!UIButton).selected = !(sender as!UIButton).selected
                //点击商家cell上的selectBtn，将商家内的商品全部加入或移出scis
                for item in self.storeArray[indexPath.section] as! NSMutableArray {
                    let shoppingItem = item as! ZMDShoppingItem
                    if (sender as!UIButton).selected == true {
                        self.scis.addObject(shoppingItem)
                    }else{
                        self.scis.removeObject(shoppingItem)
                    }
                }
                self.updateTotal()
                self.currentTableView.reloadData()
                return RACSignal.empty()
            })
            return cell!

        } else {
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! OrderGoodsTableViewCell
            cell.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: cell.bounds.height-0.5, width: kScreenWidth, height: 0.5), backgroundColor: defaultLineColor))
            
            let item = self.storeArray[indexPath.section][indexPath.row - 2] as! ZMDShoppingItem
            cell.configCellInShoppingCar(item,scis:self.scis)
            cell.editFinish = { (productDetail,item) -> Void in
                self.attrSelects.removeAllObjects()
                for var i = 0;i<productDetail.ProductVariantAttributes!.count;i++ {
                    self.attrSelects.addObject(";")
                }
                self.editViewShow(productDetail,item: item)
            }
            cell.selectFinish = { (Sci,isAdd) -> Void in
                if isAdd {
                    self.scis.addObject(Sci)
                } else {
                    self.scis.removeObject(Sci)
                }
                self.allSelectBtn.selected = self.scis.count == self.dataArray.count
                self.currentTableView.reloadData()
                self.updateTotal()
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            return
        }
        if indexPath.row == 1 {
            let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
            let product = self.storeArray[indexPath.section].firstObject as! ZMDShoppingItem
            //传递vc页面数据请求的参数
            vc.storeId = product.Store.Id
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let item = self.storeArray[indexPath.section][indexPath.row - 2] as!ZMDShoppingItem
        let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as! HomeBuyGoodsDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.productId = item.ProductId.integerValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -Action
    //全选
    @IBAction func selectAllBtnCli(sender: UIButton) {
        self.allSelectBtn.selected = !self.allSelectBtn.selected
        if self.allSelectBtn.selected {
            self.scis.removeAllObjects()
            for item in self.dataArray {
                self.scis.addObject(item)
            }
        } else {
            self.scis.removeAllObjects()
        }
        self.updateTotal()
        self.currentTableView.reloadData()
    }
    // MARK: - 结算
    @IBAction func settlementBtnCli(sender: UIButton) {
        if self.scis.count == 0 {
            return 
        }
        ZMDTool.showActivityView(nil)
        //点击结算，下订单
        QNNetworkTool.selectCart(self.getSciids(),completion: { (succeed, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if succeed! {
                let vc = ConfirmOrderViewController.CreateFromMainStoryboard() as! ConfirmOrderViewController
                vc.hidesBottomBarWhenPushed = true
                vc.scis = self.scis
                vc.total = self.subTotal
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
            }
        })
    }
    //MARK: -  PrivateMethod
    //购买数量View（- qulatiy +）
    func editViewShow(productDetail:ZMDProductDetail,item:ZMDShoppingItem) {
        let theNumber = self.getResponsitoryNumber(item.ProductId.integerValue)
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.whiteColor()
        // top
        let countLbl = UILabel(frame: CGRect(x: 12, y: 0, width: 200, height: 60))
        let kucunText = "（库存: \(theNumber)）"
        var countText = "购买数量\(kucunText)"
        countText = "购买数量"
        countLbl.attributedText = countText.AttributedMutableText(["购买数量",countText], colors: [defaultTextColor,defaultDetailTextColor])
        countLbl.font = defaultSysFontWithSize(16)
        view.addSubview(countLbl)
        
        let countView = CountView(frame: CGRect(x: kScreenWidth - 12 - 120, y: 10, width: 120, height: 40))
        countView.theMaxNumber = theNumber
        countView.finished = {(count)->Void in
            self.countForBounght = count
        }
        countView.countForBounght = item.Quantity.integerValue
        self.countForBounght = countView.countForBounght
        countView.updateUI()
        view.addSubview(countView)
       
        productAttrV = ZMDProductAttrView(frame: CGRect.zero, productDetail: productDetail)
        productAttrV.SciId = item.Id.integerValue
        productAttrV.frame = CGRectMake(0, 60,kScreenWidth, productAttrV.getHeight())
        view.addSubview(productAttrV)
        // bottom
        let okBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 14 - 110, y:CGRectGetMaxY(productAttrV.frame)+12, width: 110, height: 36), textForNormal: "确定", fontSize: 17,textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(235,61,61,1.0)) { (sender) -> Void in
            self.editCart()
            self.dismissPopupView(view)
        }
        ZMDTool.configViewLayerWithSize(okBtn, size: 18)
        view.addSubview(okBtn)
        let cancelBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 14 - 110 - 8 - 80, y: CGRectGetMaxY(productAttrV.frame)+12, width: 80, height: 36), textForNormal: "取消", fontSize: 17, backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            self.dismissPopupView(view)
        }
        view.addSubview(cancelBtn)
        var i = 0
        for _ in ["","","",""] {
            i++
            let line = ZMDTool.getLine(CGRect(x: 0, y: 60*CGFloat(i), width: kScreenWidth, height: 0.5))
            view.addSubview(line)
        }
        self.viewShowWithBg(view,showAnimation: .SlideInFromBottom,dismissAnimation: .SlideOutToBottom)
        view.frame = CGRect(x: 0, y: self.view.bounds.height - (CGRectGetMaxY(productAttrV.frame) + 60), width: kScreenWidth, height: CGRectGetMaxY(productAttrV.frame) + 60)
    }
    
    //MARK:获取商品库存
    func getResponsitoryNumber(productId:Int) -> Int {
        var theNumber = 15
        QNNetworkTool.fetchRepositoryNumber(productId) { (number, error) in
            if let number = number {
                theNumber = number
            }
        }
        return theNumber
    }
    
    //MARK:initUI
    func initUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        ZMDTool.configViewLayerWithSize(settlementBtn,size: 16)
        let rightBtn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 65, height: 44), textForNormal: "删除", fontSize: 16,backgroundColor: UIColor.clearColor(), blockForCom: nil)
        rightBtn.setImage(UIImage(named: "common_delete"), forState: .Normal)
        //        rightBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        //        rightBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
        rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            if self.scis.count != 0 {
                self.deleteCartItem()
                self.allSelectBtn.selected = false
            }
            return RACSignal.empty()
        })
        let item = UIBarButtonItem(customView: rightBtn)
        item.customView?.tintColor = defaultDetailTextColor
        self.navigationItem.rightBarButtonItem = item
        //设置角标
        self.tabBarItem.badgeValue = "\(self.dataArray.count)"
        
        self.hiddenLbl = ZMDTool.getLabel(CGRect(x: 0, y: kScreenHeight/3, width: kScreenWidth, height: 20), text: "您还没有登陆额!", fontSize: 16, textColor: defaultTextColor, textAlignment: NSTextAlignment.Center)
        self.view.addSubview(self.hiddenLbl)
        
        if g_isLogin! {
            self.hiddenLbl.removeFromSuperview()
        }
    }
    
    //请求购物车页面数据
    func dataUpdate() {
        if g_isLogin! {
            ZMDTool.showActivityView(nil)
        }
        QNNetworkTool.fetchShoppingCart(1) { (shoppingItems, dictionary, error) -> Void in
            ZMDTool.hiddenActivityView()
            if shoppingItems != nil {
                self.dataArray = NSMutableArray(array: shoppingItems!)
                //进入购物车默认全选
                self.scis.removeAllObjects()
                self.scis.addObjectsFromArray(self.dataArray as [AnyObject])
                self.allSelectBtn.selected = true
//                //模拟产生storeId
//                var index = 0
//                for item in self.dataArray {
//                    let shoppingItem = item as! ZMDShoppingItem
//                    shoppingItem.StoreId = (index++) % 2
//                }
                
                //将self.dataArray中的商品按店铺分组,得到一个类似于[[item1,item2],[item1,item2],...]的数组self.storeArray
                self.getTheStoreArray()
                //通过updateTotal计算选中物品总金额
                self.updateTotal()
                
                self.currentTableView.reloadData()
            } else {
                ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: nil)
            }
        }
    }
    
    //MARK:按店铺分组，得到二维数组
    func getTheStoreArray() {
        let storeArray = NSMutableArray()
        for(var i=0;i<self.dataArray.count;i++){
            let item = self.dataArray[i] as! ZMDShoppingItem
            item.Store.Id = i%2
            var j = 0
            for (;j<storeArray.count;j++){
                let arr = storeArray[j] as! NSMutableArray
                if item.Store.Id == (arr.firstObject as! ZMDShoppingItem).Store.Id {
                    arr.addObject(item)
                    break
                }
            }
            if j == storeArray.count {
                let arr = NSMutableArray(array: [item])
                storeArray.addObject(arr)
            }
        }
        self.storeArray.removeAllObjects()
        self.storeArray = NSMutableArray(array: storeArray as [AnyObject])
    }
    
    //MARK:判断某个店铺内商品是否全部选中，来设置店铺cell上selectBtn的UI
    func isStoreAllSelected(indexPath:NSIndexPath) -> Bool{
        
        for item in self.storeArray[indexPath.section] as!NSMutableArray {
            let shoppingItem = item as!ZMDShoppingItem
            var count = 0
            for item in self.scis {
                let scisShoppintItem = item as! ZMDShoppingItem
                if shoppingItem.Id == scisShoppintItem.Id {
                    count++
                }
            }
            if count == 0 {
                return false
            }
        }
        return true
    }
    //编辑购物车item
    func editCart() {
        let dic = self.productAttrV.getPostData(self.countForBounght)
        if dic == nil {
            return
        }
        if g_isLogin! {
            QNNetworkTool.editCartItemAttribute(dic!, completion: { (succeed, dictionary, error) -> Void in
                if succeed! {
                    self.dataUpdate()
                } else {
                    ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "修改失败")
                }
            })
        }
    }
    
    //MARK: 计算总金额updateTotal->setTotal
    func setTotal(subTotal:Double) {
        self.subTotal = "\(subTotal)"
        self.totalLbl.text = String(format: "合计:%.2f", subTotal)
    }
    func updateTotal() {
        var scisNes = NSMutableArray()
        //总金额
        var tmp = Double(0)
        var index = -1
        for item in self.scis {
            index++
            for tmp in self.dataArray {
                if (item as! ZMDShoppingItem).Id == (tmp as! ZMDShoppingItem).Id {
                    self.scis.replaceObjectAtIndex(index, withObject: tmp)
                    scisNes.addObject(tmp)
                }
            }
        }
        //计算选中物品总金额
        self.scis = scisNes
        for item in self.scis {
            let subTotal = (item as! ZMDShoppingItem).SubTotal.stringByReplacingOccurrencesOfString("¥", withString: "").stringByReplacingOccurrencesOfString(",", withString: "")
            tmp = tmp + Double(subTotal)!
        }
        //把计算的总金额更新到UI
        self.setTotal(tmp)
    }
    
    //MARK:删除购物车item：getSciids(作为参数)->deleteCarItem
    func deleteCartItem() {
        //得到选中items.id 拼接成的字符串，作为删除请求的参数
        let items = self.getSciids()
        if g_isLogin! {
            QNNetworkTool.deleteCartItem(items,carttype: 1,completion: { (succeed, dictionary, error) -> Void in
                if succeed! {
                    //删除成功，清空选中的购物单，然后在刷新UI
                    self.scis.removeAllObjects()
                    //****这里可以注释，因为在dataUpdate中含有updateTotal方法
//                    self.updateTotal()
                    self.dataUpdate()
                } else {
                    ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "删除失败")
                }
            })
        }
    }
    
    //将选中的item的id用;拼接成字符串
    func getSciids()  -> String {
        let items = NSMutableString()
        var index = -1
        for tmp in self.scis {
            index++
            let sciId = (tmp as! ZMDShoppingItem).Id
            let scid = index == self.scis.count - 1 ? "\(sciId)" : "\(sciId),"
            items.appendString(scid)
        }
        return items as String
    }

}
