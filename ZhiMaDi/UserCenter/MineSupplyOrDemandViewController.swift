//
//  MineSupplyOrDemandViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import MJRefresh
//我的供应（我的求购）
class MineSupplyOrDemandViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    
    enum ContentType {
        case Supply,Demand
    }
    enum StatuType : Int {
        case kPublish = 0,kCheck,kDated
    }
    @IBOutlet weak var currentTableView : UITableView!
    @IBOutlet weak var currentTableViewTopConstraint : NSLayoutConstraint!
    var footer : MJRefreshAutoFooter!
    
    var dataArray = NSMutableArray()
    var pageIndex = 1
    var check = 0
    var type = 1
    var keyword = ""
    var haveNext = false
    
    var contentType = ContentType.Supply
    var statu = StatuType.kPublish
    
    
    //MARK: - ****************LifeCircle*******************
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData(self.statu, keyword: self.keyword)
        self.initUI()
        // Do any additional setup after loading the view.
    }

    //MARK: - ***************UITableViewDelegate************
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : zoom(12)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(12)))
        view.backgroundColor = defaultGrayColor
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = self.dataArray[indexPath.section] as! ZMDSupplyProduct
        if indexPath.row == 1 {
            return zoom(54)
        }else if self.contentType == .Demand {
            return data.Description == "" ? 120 : 170
        }else{
            if let pictures = data.SupplyDemandPictures where pictures.count != 0 {
                if let des = data.Description where des != "" {
                    return 320
                }else{
                    return 240
                }
            }else{
                if let des = data.Description where des != "" {
                    return 185
                }else{
                    return 115
                }
            }
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            return self.cellForActions(tableView,indexPath:indexPath)
        }else if self.contentType == .Demand {
            return self.cellForDemandDetail(tableView,indexPath:indexPath)
        }else{
            return self.cellForSupplyDetail(tableView,indexPath:indexPath)
        }
    }
    
    //MARK: - ***************TableViewCell****************
    func cellForActions(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let titles = self.statu == .kDated ? ["查看详情"] : ["修改","查看详情"]
        let width = zoom(85)
        var index = -1
        let cellId = "actionsCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)

        }
        for subView in (cell?.contentView.subviews)! {
            if subView is UIButton {
                subView.removeFromSuperview()
            }
        }
        for title in titles {
            index = index + 1
            let btn = ZMDTool.getButton(CGRect(x: kScreenWidth-zoom(12)-CGFloat(index)*zoom(10+85)-width, y: zoom(10), width: width, height: zoom(34)), textForNormal: title, fontSize: 13, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                let data = self.dataArray[indexPath.section] as! ZMDSupplyProduct
                if (sender as! UIButton).titleLabel?.text == "查看详情" {
                    //详情
                    let vc = SupplyDemandDetailViewController.CreateFromMainStoryboard() as! SupplyDemandDetailViewController
                    vc.supplyProductId = data.Id.integerValue
                    vc.type = self.contentType == .Supply ? 1 : 2
                    self.pushToViewController(vc, animated: true, hideBottom: true)
                }else{
                    //修改
                    let vc = PublishSupplyViewController.CreateFromMainStoryboard() as! PublishSupplyViewController
//                    vc.data = data
                    vc.id = data.Id.integerValue
                    vc.contentType = self.contentType == .Supply ? .Supply : .Demand
                    self.pushToViewController(vc, animated: true, hideBottom: true)
                }
            })
            btn.tag = 1000+index
            ZMDTool.configViewLayer(btn)
            ZMDTool.configViewLayerFrameWithColor(btn, color: defaultLineColor)
            cell?.contentView.addSubview(btn)
        }
        return cell!
    }
    func cellForDemandDetail(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "demandDetailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DemandDetailCell
        ZMDTool.configTableViewCellDefault(cell)
        cell.addLine()
        
        let data = self.dataArray[indexPath.section]
        cell.configCell(cell, data: data as! ZMDSupplyProduct)
        return cell
    }
    func cellForSupplyDetail(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "supplyDetailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! SupplyDetailCell
        ZMDTool.configTableViewCellDefault(cell)
        cell.addLine()
        
        let data = self.dataArray[indexPath.section] as! ZMDSupplyProduct
        if let pictures = data.SupplyDemandPictures where pictures.count != 0 {
            cell.scrollView.snp_updateConstraints { (make) -> Void in
                make.top.equalTo(12)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(115)
            }
        }else{
            cell.scrollView.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(0)
                make.height.equalTo(0)
            })
        }
        
        cell.detailLblWidthConstraint.constant = data.Description == "" ? 0 : 60
        cell.detailLblBotConstraint.constant = data.Description == "" ? 0 : 10
        for subView in cell.scrollView.subviews {
            subView.removeFromSuperview()
        }
        cell.configCell(cell, data: data)
        return cell
    }
    
    //MARK: - ***************PrivateMethod******************
    func initUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableViewTopConstraint.constant = zoom(60)
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: Selector("footerRefresh"))
        self.currentTableView.mj_footer = footer
        self.viewForSearch()
        let segmentView = viewForSegment()
        self.view.addSubview(segmentView)
    }
    
    func fetchData(statu:StatuType,keyword:String) {
        ZMDTool.showActivityView(nil)
        switch statu {
        case .kPublish:
            self.check = 2
        case .kCheck:
            self.check = 1
        case .kDated:
            self.check = 4
        }
        self.type = self.contentType == .Supply ? 1 : 2
        QNNetworkTool.supplyDemandSearch(g_customerId!, page: self.pageIndex, pageSize: 12, check: self.check, q: keyword, type: self.type, orderBy: 0, fromPrice: nil, toPrice: nil) { (error, products) -> Void in
            ZMDTool.hiddenActivityView()
            if let products = products {
                if self.pageIndex == 1 {
                    self.dataArray.removeAllObjects()
                }
                self.pageIndex = self.pageIndex + 1
                if products.count == 12 {
                    self.haveNext = true
                    self.currentTableView.mj_footer.endRefreshing()
                }else{
                    self.haveNext = false
                    self.currentTableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self.dataArray.addObjectsFromArray(products as [AnyObject])
                self.currentTableView.reloadData()
            }else{
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
    }
    
    func viewForSearch() {
        let searchBar = ZMDTool.searchBar("输入关键词")
        searchBar.finished = {(text)->Void in
            self.view.endEditing(true)
            self.pageIndex = 1
            self.keyword = text
            self.fetchData(self.statu,keyword:self.keyword)
        }
        self.navigationItem.titleView = searchBar
    }
    
    func viewForSegment() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(60)))
        view.backgroundColor = defaultGrayColor
        let bgV = UIView(frame: CGRect(x: zoom(70), y: zoom(12), width: kScreenWidth-zoom(140), height: zoom(36)))
        bgV.backgroundColor = UIColor.clearColor()
        ZMDTool.configViewLayer(bgV)
        ZMDTool.configViewLayerFrameWithColor(bgV, color: defaultDetailTextColor)
        let titles = ["发布中","待审核","已过期"]
        let btnArray = NSMutableArray()
        let (titleNormalColor,bgNormalColor) = (defaultTextColor,UIColor.clearColor())
        let (titleSelectColor,bgSelectColor) = (UIColor.whiteColor(),appThemeColor)
        var index = -1
        let width = (kScreenWidth-zoom(140.0))/3
        for title in titles {
            index = index + 1
            let btn = ZMDTool.getButton(CGRect(x:CGFloat(index) * width, y: 0, width: width, height: zoom(36)), textForNormal: title, fontSize: 15, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                if (sender as! UIButton).selected {return}
                for item in btnArray {
                    if (item as! UIButton).tag == (sender as! UIButton).tag {
                        (item as! UIButton).selected = true
                        self.statu = StatuType(rawValue: (item as! UIButton).tag)!
                    }else{
                        (item as! UIButton).selected = false
                    }
                }
                self.pageIndex = 1
                self.fetchData(self.statu,keyword: self.keyword)
            })
            btnArray.addObject(btn)
            if index != 2 {
                btn.addSubview(ZMDTool.getLine(CGRect(x: width-0.5, y: 0, width: 0.5, height: zoom(36)), backgroundColor: defaultLineColor))
            }
            btn.tag = index
            btn.setTitleColor(titleNormalColor, forState: UIControlState.Normal)
            btn.setTitleColor(titleSelectColor, forState: UIControlState.Selected)
            btn.setBackgroundImage(UIImage.colorImage(bgNormalColor, size: CGSize(width: width, height: zoom(35))), forState: .Normal)
            btn.setBackgroundImage(UIImage.colorImage(bgSelectColor, size: CGSize(width: width, height: zoom(35))), forState: .Selected)
            bgV.addSubview(btn)
            btn.selected = index == 0
        }
        view.addSubview(bgV)
        return view
    }
    
    func footerRefresh() {
        if self.haveNext {
            self.fetchData(self.statu, keyword: self.keyword)
        }else{
            self.currentTableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    
    //MARK: - ***************Override****************
    override func gotoMore() {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: - ****************OtherClass*****************
class DemandDetailCell : UITableViewCell {
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var detailLbl : UILabel!
    @IBOutlet weak var quantityLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var beginLbl : UILabel!
    @IBOutlet weak var endLbl : UILabel!
    
    func configCell(cell:DemandDetailCell,data:ZMDSupplyProduct) {
        cell.nameLbl.text = data.Title
        cell.detailLbl.text = data.Description
        cell.quantityLbl.text = "\(data.Quantity.integerValue)"+"/\(data.QuantityUnit)"
        cell.priceLbl.text = "\(data.Price.floatValue)/\(data.PriceUnit)"
        cell.beginLbl.text = "\(data.CreatedOn.componentsSeparatedByString("T").first!)"
        let endTime = data.EndTime.componentsSeparatedByString("T").first
        let days = QNFormatTool.getDaysWithDateString(endTime!)
        cell.endLbl.text = (days as NSString).integerValue < 0 ? endTime! + "(已过期)" : endTime! + "(剩余\(days)天)"
    }
}

class SupplyDetailCell : UITableViewCell {
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var detailLbl : UILabel!
    @IBOutlet weak var quantityLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var beginLbl : UILabel!
    @IBOutlet weak var endLbl : UILabel!
    @IBOutlet weak var detailLblWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var detailLblBotConstraint : NSLayoutConstraint!
    
    func configCell(cell:SupplyDetailCell,data:ZMDSupplyProduct) {
        cell.scrollView.showsHorizontalScrollIndicator = false
        cell.nameLbl.text = data.Title
        cell.detailLbl.text = data.Description
        cell.quantityLbl.text = "\(data.Quantity.integerValue)"+"/\(data.QuantityUnit)"
        cell.priceLbl.text = "\(data.Price.floatValue)/\(data.PriceUnit)"
        cell.beginLbl.text = data.CreatedOn
        let endTime = data.EndTime.componentsSeparatedByString("T").first
        let daysStr = QNFormatTool.getDaysWithDateString(endTime!)
        let days = (daysStr as NSString).integerValue
        cell.endLbl.text = days <= 0 ? endTime!+"(已过期)" : endTime! + "(剩余\(days)天)"
        
        if let pictures = data.SupplyDemandPictures {
            cell.scrollView.contentSize = CGSizeMake(12+CGFloat(pictures.count)*(115+10), 0)
            for _ in data.SupplyDemandPictures {
                var index = -1
                for pic in pictures {
                    index = index + 1
                    let view = UIView(frame: CGRect(x: 12+CGFloat(index)*(115+10), y: 0, width: 115, height: 115))
                    let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 115, height: 115))
                    imgView.sd_setImageWithURL(NSURL(string: kImageAddressMain+pic.PictureUrl), placeholderImage: nil)
                    view.addSubview(imgView)
                    cell.scrollView.addSubview(view)
                }
            }
        }

    }
}
