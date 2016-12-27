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
//供求列表
class SupplyDemandListViewController: UIViewController ,ZMDInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var currentTableView: UITableView!
    var popView : UIView!
    var footer : MJRefreshAutoNormalFooter!
    var dataArray = NSMutableArray()
    var IndexFilter = 0     //记录排序cell上的selected
    var isHasNext = false
    var orderbyPriceUp = true                       // 价格升序
    var orderBy : Int = 0  //默认为0
    var filterView : UIView!
    var pickView : PickView!
    
    
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
        return section == 0 ? 44 + 10 : 10
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
        cell.isCollectionBtnLeft.setImage(UIImage(named: "collect01"), forState: UIControlState.Normal)
        cell.isCollectionBtnLeft.setImage(UIImage(named: "collect02"), forState: UIControlState.Selected)
        let product = self.dataArray[indexPath.section] as! ZMDSupplyProduct
        cell.isCollectionBtnLeft.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            cell.isCollectionBtnLeft.selected = !cell.isCollectionBtnLeft.selected
            return RACSignal.empty()
        })
        if self.type == 2 {
            cell.goodsImgVBotConstraint.constant = 150-12
            cell.goodsImgVLeft.hidden = true
            SupplyDemandListCell.configSupplyCell(cell, product: product,isDemand: true)
        }else{
            SupplyDemandListCell.configSupplyCell(cell, product: product)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let product = self.dataArray[indexPath.section] as! ZMDSupplyProduct
        self.pushDetailVc(product)
    }
    func pushDetailVc(product : ZMDSupplyProduct) {
        let vc = SupplyDemandDetailViewController.CreateFromMainStoryboard() as! SupplyDemandDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.supplyProductId = product.Id.integerValue
        vc.type = self.type
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
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * (kScreenWidth)/countForBtn , 0, (kScreenWidth)/countForBtn, 44))
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
                    btn.setImage(UIImage(named: "more02"), forState: .Normal)
                    btn.setImage(UIImage(named: "more02"), forState: .Selected)
                }else{
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    btn.setImage(UIImage(named: "more01"), forState: .Normal)
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
            let line = ZMDTool.getLine(CGRect(x: CGRectGetWidth(btn.frame)-1, y: 15, width: 1, height: 15))
            btn.addSubview(line)
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                (sender as!UIButton).selected = !(sender as!UIButton).selected
                self.IndexFilter = sender.tag - 1000
                //0：默认 5 ： 名称升序，6 ：名称降序 10：价格升，11：价格降15：日期升，16：日期降
                let orderbys = [(0,0),(10,11),(0,0)]
                let title = filterTitles[sender.tag - 1000]
                let orderby = orderbys[sender.tag - 1000]
                switch title {
                case "默认" :
                    self.orderBy = 0
                    break
                case "更多" :
                    self.createFilterMenu() //更新filterMenu上的UI
                    //MARK:pickView
                    let pickView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil)[2] as! PickView
                    pickView.submitBtnFinished = {() -> Void in
                        if !pickView.checkData() {
                            return
                        }
                        self.dismissPopupView(pickView)
                        //updateData With self.lower、higher、limit
                        self.page = 1
                        self.isHasNext = false
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
                //点击上面的menu时让page=1(page==1时清除dataArray)，让后定义orderBy重新请求数据
                self.createFilterMenu()     //更新filterMenu上的UI
                self.page = 1
                self.isHasNext = false
                self.dataArray.removeAllObjects()
                self.currentTableView.reloadData()
                self.currentTableView.contentOffset = CGPoint(x: 0, y: 0)
                self.fetchData(self.orderBy)
            })
            
        }
        self.filterView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 43.5, width: kScreenWidth, height: 0.5)))
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
        if self.type == 1 {
            self.title = "供应"
        }else{
            self.title = "求购"
        }
    }
    
    //
    func popWindow () {
        self.popView = UIView(frame: CGRectMake(0 , 64+52, kScreenWidth,  self.view.bounds.height - 100))
        self.popView.backgroundColor = UIColor.blueColor()
        self.popView.showAsPopAndhideWhenClickGray()
    }
    
    func fetchData(orderBy:Int!) {
        ZMDTool.showActivityView(nil)
        QNNetworkTool.supplyDemandSearch(0, page: self.page, pageSize: 12, check: self.check, q: self.q, type: self.type, orderBy: orderBy, fromPrice: self.fromPrice?.floatValue, toPrice: self.toPrice?.floatValue) { (error, products) -> Void in
            ZMDTool.hiddenActivityView()
            if let productsArr = products {
                if self.page == 1 {
                    self.dataArray.removeAllObjects()
                }
                self.page = self.page + 1
                self.dataArray.addObjectsFromArray(productsArr as [AnyObject])
                self.currentTableView.reloadData()
                if productsArr.count == 12 {
                    self.isHasNext = true
                }else{
                    self.isHasNext = false
                    self.footer.endRefreshingWithNoMoreData()
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
            self.footer.endRefreshingWithNoMoreData()
        }
    }
    
}

