//
//  MineSupplyOrDemandViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//我的供应（我的求购）
class MineSupplyOrDemandViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    
    enum ContentType {
        case Supply,Demand
    }
    enum StatuType : Int {
        case kPublish = 0,kCheck,kDated
    }
    @IBOutlet weak var currentTableView : UITableView!
    var dataArray = NSMutableArray()
    var contentType = ContentType.Supply
    var statu = StatuType.kPublish
    
    
    //MARK: - ****************LifeCircle*******************
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataArray = ["",""]
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
        if indexPath.row == 1 {
            return zoom(54)
        }else if self.contentType == .Demand {
            return 170
        }else{
            return 335
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
        let titles = ["修改","查看详情"]
        let width = zoom(85)
        var index = -1
        let cellId = "actionsCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            for title in titles {
                index = index + 1
                let btn = ZMDTool.getButton(CGRect(x: kScreenWidth-zoom(12)-CGFloat(index)*zoom(10+85)-width, y: zoom(10), width: width, height: zoom(34)), textForNormal: title, fontSize: 13, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                    if (sender as! UIButton).tag == 1000 {
                        //详情
                    }else{
                        //修改
                    }
                })
                btn.tag = 1000+index
                ZMDTool.configViewLayer(btn)
                ZMDTool.configViewLayerFrameWithColor(btn, color: defaultLineColor)
                cell?.contentView.addSubview(btn)
            }
        }
        return cell!
    }
    func cellForDemandDetail(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "demandDetailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! SupplyDetailCell
        ZMDTool.configTableViewCellDefault(cell)
        cell.addLine()
        
        return cell
    }
    func cellForSupplyDetail(tableView:UITableView,indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "supplyDetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.addLine()
        }
        return cell!
    }
    
    //MARK: - ***************PrivateMethod******************
    func initUI() {
        
        self.viewForSearch()
        let segmentView = viewForSegment()
        self.view.addSubview(segmentView)
        
    }
    
    func fetchData() {
        //...
    }
    
    func viewForSearch() {
        let searchBar = ZMDTool.searchBar("输入关键词")
        searchBar.finished = {(text)->Void in
            self.view.endEditing(true)
            self.fetchData()
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
    
    
    
    //MARK: - ***************Override****************
    override func gotoMore() {
        
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

//MARK: - ****************OtherClass*****************
class DemandDetailCell : UITableViewCell {
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var detailLbl : UILabel!
    @IBOutlet weak var quantityLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var beginLbl : UILabel!
    @IBOutlet weak var endLbl : UILabel!
    var images : NSArray!
}
class SupplyDetailCell : UITableViewCell {
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var detailLbl : UILabel!
    @IBOutlet weak var quantityLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var beginLbl : UILabel!
    @IBOutlet weak var endLbl : UILabel!
}
