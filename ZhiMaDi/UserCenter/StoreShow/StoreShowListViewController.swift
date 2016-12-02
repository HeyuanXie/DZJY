//
//  StoreShowListViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/8/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
class StoreShowListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var currentTableView: UITableView!
    
    let kServerAddress  = "http://www.xjnongte.com"

    var IndexFilter = 0
    var orderby = 16
    var orderBy : Int?
    var indexSkip = 0
    var orderbySaleUp = true    //默认都是升序
    var orderbyPopularUp = true
    var titleForFilter = ""
    
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.updateData(self.orderby)
        // Do any additional setup after loading the view.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataArray.count
//        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.createFilterMenu()
        } else {
            let headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
            headView.backgroundColor = tableViewdefaultBackgroundColor
            return headView
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 52
        } else {
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        } else {
            return 130
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let store = self.dataArray[indexPath.section] as! ZMDStoreDetail
        if indexPath.row == 0{
            let cellId = "StoreCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            
            let headGrayView = cell?.viewWithTag(10000)
            headGrayView?.backgroundColor = UIColor.lightGrayColor()
            
            let storeImage = cell?.viewWithTag(10001) as! UIImageView
            storeImage.image = UIImage(named: "default-image-100.jpg")
            ZMDTool.configViewLayerRound(storeImage)
            let store = self.dataArray[indexPath.section] as! ZMDStoreDetail
            if let urlStr = store.PictureUrl,url = NSURL(string: kServerAddress + urlStr) {
                storeImage.sd_setImageWithURL(url, placeholderImage: nil)
            }
            
            let nameLabel = cell?.viewWithTag(10002) as! UILabel
            nameLabel.text = "疆南Style"
            nameLabel.text = store.Name
            let mainLabel = cell?.viewWithTag(10003) as! UILabel
            mainLabel.text = "主营:...."
            mainLabel.text = store.Host == nil ? "主营:化肥、农药、农产品" : "主营:\(store.Host)"
            
            let gotoBtn = cell?.viewWithTag(10004) as! UIButton
            ZMDTool.configViewLayerFrameWithColor(gotoBtn, color: defaultSelectColor)
            ZMDTool.configViewLayerWithSize(gotoBtn, size: 5)
            gotoBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
                vc.storeId = store.Id
                if let array = store.AvailableCategories {
                    vc.availableCategories = NSMutableArray(array: array)   //临时
                }
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
                return RACSignal.empty()
            })
            return cell!
        } else {
            let cellId = "GoodsCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! StoreShowListGoodCell
            ZMDTool.configTableViewCellDefault(cell)
            
            let count = min(4, store.Products.count)
            for i in 0..<count {
                let btn = cell.BtnArray[i]
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    let vc = HomeBuyGoodsDetailViewController.CreateFromMainStoryboard() as!HomeBuyGoodsDetailViewController
                    vc.productId = store.Products[i].Id.integerValue
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    return RACSignal.empty()
                })
            }
            for i in count..<4{
                let btn = cell.BtnArray[i]
                btn.removeFromSuperview()
            }
            //设置goodsCell上的UI
            cell.configCellWith(store.Products)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    //MARK:PrivateMethod
    func createFilterMenu() -> UIView{
        let filterTitles = ["默认","销量","人气"]
        let countForBtn = CGFloat(filterTitles.count)
        //52+16，与tableView的delegate中设置的第0个section的heightForHeader一致
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 52 + 16))
        view.backgroundColor = UIColor.clearColor()
        for var i=0;i<filterTitles.count;i++ {
            let index = i%filterTitles.count
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * kScreenWidth/countForBtn , 0, kScreenWidth/countForBtn, 52))
            btn.backgroundColor = UIColor.whiteColor()
            btn.selected = i == self.IndexFilter ? true : false
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
            
            btn.setTitle(filterTitles[i], forState: .Normal)
            btn.setTitle(filterTitles[i], forState: .Selected)
            if filterTitles[i] == "销量" || filterTitles[i] == "人气" {
                let width = (kScreenWidth)/countForBtn
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (width-50)/2+40, bottom: 0, right: 0)
                btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (width-50)/2+16)
                
                if self.IndexFilter == i {
                    let upArr = [self.orderbySaleUp,self.orderbyPopularUp]
                    btn.selected = upArr[i-1]
                    btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                    btn.setTitleColor(RGB(235,61,61,1.0), forState: .Normal)
                } else {
                    btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                }
            }
            
            btn.titleLabel?.font = UIFont.systemFontOfSize(13)
            btn.tag = 1000 + i
            view.addSubview(btn)
            //btn间的分割线
            let line = ZMDTool.getLine(CGRectMake(btn.frame.size.width-1, 20, 1, 13))
            btn.addSubview(line)
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                if filterTitles[sender.tag - 1000] == "销量" || filterTitles[sender.tag - 1000] == "人气"{
                    (sender as! UIButton).selected = !(sender as! UIButton).selected
                }
                self.IndexFilter = sender.tag - 1000
                let orderbys = [(-1,-1),(17,18),(10,11),(15,16)]
                let title = filterTitles[sender.tag - 1000]
                let orderby = orderbys[sender.tag - 1000]
                switch title {
                case "默认" :
                    self.orderBy = nil
                    break
                case "销量" :
                    self.orderbySaleUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbySaleUp ? orderby.0 : orderby.1
                    break
                case "人气" :
                    self.orderbyPopularUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbyPopularUp ? orderby.0 : orderby.1
                case "最新" :
                    self.orderBy = orderby.1
                    break
                default :
                    break
                }
                self.indexSkip = 0
                self.updateData(self.orderBy)
            })
        }
        return view
    }
    
    //MARK: initUI
    func initUI() {
        self.title = self.titleForFilter
        self.configBackButton()
    }
        
    //MARK: updateData
    func updateData(orderby:Int?) {
        QNNetworkTool.fetchStoreList(12, pageNumber: self.indexSkip, orderBy: orderby!, Q: self.titleForFilter) { (storeArray, Error, dictionary) -> Void in
            if self.indexSkip == 0 {
                self.dataArray.removeAllObjects()
            }
            if let storeArray = storeArray {
                self.dataArray.addObjectsFromArray(storeArray as [AnyObject])
            }
            self.currentTableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


class StoreShowListGoodCell: UITableViewCell {
    @IBOutlet weak var firstView:UIView!
    @IBOutlet weak var secondView:UIView!
    @IBOutlet weak var thirdView:UIView!
    @IBOutlet weak var fourthView:UIView!
    
    let kServerAddress  = "http://www.xjnongte.com"

    override func awakeFromNib() {

    }
    
    @IBOutlet var BtnArray: [UIButton]!
    
    func configCellWith(products:NSArray){
        var view : UIView!
        let count = min(4, products.count)
        for i in count..<4 {
            let view = self.viewWithTag(1000+i)
            view?.alpha = 0
        }
        for i in 0..<count {
            let product = products[i] as! ZMDProduct
            switch i {
            case 0:
                view = self.firstView
                break
            case 1:
                view = self.secondView
                break
            case 2:
                view = self.thirdView
                break
            case 3:
                view = self.fourthView
                break
            default:
                break
            }
            (view.viewWithTag(100) as!UIImageView).sd_setImageWithURL(NSURL(string: kServerAddress + (product.DefaultPictureModel?.ImageUrl)!), placeholderImage: nil)
            let productName = product.Name.stringByReplacingOccurrencesOfString("（代购）", withString: "").stringByReplacingOccurrencesOfString("【代购】", withString: "").stringByReplacingOccurrencesOfString("（预售）", withString: "")
            (view.viewWithTag(101) as!UILabel).text = productName
            (view.viewWithTag(102) as!UILabel).text = product.ProductPrice?.Price
        }
    }
}