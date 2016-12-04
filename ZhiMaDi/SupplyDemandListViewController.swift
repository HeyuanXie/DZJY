//
//  SupplyDemandListViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/4.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MJRefresh
//商品列表
class SupplyDemandListViewController: UIViewController ,ZMDInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var currentTableView: UITableView!
    
    var popView : UIView!
    var footer : MJRefreshAutoNormalFooter!
    var dataArray = NSMutableArray()
    var indexSkip = 1
    var IndexFilter = 0     //记录排序cell上的selected
    var isHasNext = true
    var orderbyPriceUp = true                       // 价格升序
    var orderBy : Int = 0  //默认为0
    var filterView : UIView!
    
    //跳转传递的值
    var vcTitle = ""        //vc的title
    
    //供求数据请求参数
    var customerId : NSNumber?
    var fromPrice : NSNumber?
    var toPrice : NSNumber?
    var page : Int = 1
    var q : String! = ""
    var type : Int = 1
    var check : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subViewInit()
        self.fetchData(self.orderBy)
        //        self.updateData(self.orderBy)   //第一次进来用orderby = 16的方式排序
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //        self.setupNewNavigation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
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
        return self.dataArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 52 + 10 : 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "goodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! SupplyDemandListCell
        //singleCell的收藏
        cell.contentView.bringSubviewToFront(cell.isCollectionBtnLeft)
        cell.isCollectionBtnLeft.setImage(UIImage(named: "list_collect_normal.png"), forState: UIControlState.Normal)
        cell.isCollectionBtnLeft.setImage(UIImage(named: "list_collect_selected.png"), forState: UIControlState.Selected)
        let product = self.dataArray[indexPath.section] as! ZMDSupplyProduct
        cell.isCollectionBtnLeft.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            cell.isCollectionBtnLeft.selected = !cell.isCollectionBtnLeft.selected
            return RACSignal.empty()
        })
        SupplyDemandListCell.configSupplyCell(cell, product: product)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let product = self.dataArray[indexPath.section] as! ZMDSupplyProduct
        self.pushDetailVc(product)
    }
    func pushDetailVc(product : ZMDSupplyProduct) {
        let vc = SupplyDemandDetailViewController.CreateFromMainStoryboard() as! SupplyDemandDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.productId = 353
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: -IBAction进入购物车
    
    @IBAction func goToShoppingCar(sender: UIButton) {
        let vc = ShoppingCartViewController.CreateFromMainStoryboard() as! ShoppingCartViewController
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar)  {
        self.view.endEditing(true)
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        homeBuyListViewController.titleForFilter = searchBar.text ?? ""
        homeBuyListViewController.hideSearch = true
        self.navigationController?.pushViewController(homeBuyListViewController, animated: false)
    }
    //MARK: -  PrivateMethod
    //创建目录视图，作为第0个section的headerView
    func createFilterMenu() {
        if let filterMenu = self.view.viewWithTag(10000) {
            filterMenu.removeFromSuperview()
        }
        let filterTitles = ["默认","价格","更多"]
        let countForBtn = CGFloat(filterTitles.count) //3
        //52+16，与tableView的delegate中设置的第0个section的heightForHeader一致
        self.filterView = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 44))
        self.filterView.backgroundColor = UIColor.clearColor()
        for var i=0;i<filterTitles.count;i++ {
            let index = i%filterTitles.count
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * (kScreenWidth)/countForBtn , 0, (kScreenWidth)/countForBtn, 52))
            btn.backgroundColor = UIColor.whiteColor()
            btn.selected = i == self.IndexFilter ? true : false
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.setTitleColor(appThemeColorNew, forState: .Selected)
            btn.setTitle(filterTitles[i], forState: .Normal)
            
            switch(filterTitles[i]){
            case "默认" :
                break
            case "更多" :
                let width = kScreenWidth/countForBtn
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
                btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                if self.IndexFilter == 2 {
                    btn.setTitleColor(appThemeColorNew, forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                }else{
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                }
                break
            default :
                let width = (kScreenWidth)/countForBtn
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (width-50)/2 + 25, bottom: 0, right: 0)
                btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (width-50)/2)
                if self.IndexFilter == 1 {
                    btn.setTitleColor(appThemeColorNew, forState: .Normal)
                    btn.selected = self.orderbyPriceUp
                    btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                }else{
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                }
                break
            }
            
            btn.titleLabel?.font = UIFont.systemFontOfSize(13)
            btn.tag = 1000 + i
            self.filterView.addSubview(btn)
            
            //btn间的分割线
            let line = ZMDTool.getLine(CGRect(x: CGRectGetWidth(btn.frame)-1, y: 19, width: 1, height: 15))
            btn.addSubview(line)
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                (sender as!UIButton).selected = !(sender as!UIButton).selected
                self.IndexFilter = sender.tag - 1000
                let orderbys = [(-1,-1),(17,18),(19,20),(10,11)]
                let title = filterTitles[sender.tag - 1000]
                let orderby = orderbys[sender.tag - 1000]
                switch title {
                case "默认" :
                    self.orderBy = 0
                    break
                case "更多" :
                    let pickView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil)[2] as! PickView
                    pickView.submitBtnFinished = {() -> Void in
                        if !pickView.checkData() {
                            return
                        }
                        self.dismissPopupView(pickView)
                        //updateData With self.lower、higher、limit
                        self.page = 1
                        self.fromPrice = pickView.lower
                        self.toPrice = pickView.higher
                        self.fetchData(self.orderBy)
                    }
                    self.viewShowWithBg(pickView, showAnimation: .SlideInFromTop, dismissAnimation: .SlideOutToTop)
                    return
                case "价格" :
                    self.orderbyPriceUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbyPriceUp ? orderby.0 : orderby.1
                    break
                default :
                    break
                }
                //点击上面的menu时让indexSkip=1(indexSkip==1时清除dataArray)，让后定义orderBy重新请求数据
                self.page = 1
                self.fetchData(self.orderBy)
            })
            
        }
        self.view.addSubview(self.filterView)
    }
    
    func subViewInit() {
        // 底部刷新
        footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: Selector("footerRefresh"))
        self.currentTableView.mj_footer = footer
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        
        // 创建筛选View
        self.createFilterMenu()
        self.currentTableView.snp_updateConstraints { (make) -> Void in
            make.top.equalTo(self.filterView.snp_bottom).offset(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        self.setVCTitle()   //设置导航栏标题
        self.configMoreButton()
    }
    
    func setVCTitle() {
        self.title = self.vcTitle
    }
    
    //
    func popWindow () {
        self.popView = UIView(frame: CGRectMake(0 , 64+52, kScreenWidth,  self.view.bounds.height - 100))
        self.popView.backgroundColor = UIColor.blueColor()
        self.popView.showAsPopAndhideWhenClickGray()
    }
    
    func fetchData(orderBy:Int!) {
        QNNetworkTool.supplyDemandSearch(self.customerId?.integerValue, page: self.page, pageSize: 12, check: self.check, q: self.q, type: self.type, orderBy: orderBy, fromPrice: self.fromPrice?.floatValue, toPrice: self.toPrice?.floatValue) { (error, products) -> Void in
            if let productsArr = products {
                if self.page == 1 {
                    self.dataArray.removeAllObjects()
                }
                self.indexSkip += 1
                self.dataArray.addObjectsFromArray(productsArr as [AnyObject])
                self.createFilterMenu()
                self.currentTableView.reloadData()
                if productsArr.count < 12 {
                    self.isHasNext = false
                    self.footer.endRefreshingWithNoMoreData()
                }else{
                    self.isHasNext = true
                    self.footer.endRefreshing()
                }
            }else{
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
    }
    
    // MARK:-底部刷新
    func footerRefresh(){
        //当上拉还有数据时，刷新
        if self.isHasNext {
            self.fetchData(self.orderBy)
        }else{
            self.currentTableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    
}

