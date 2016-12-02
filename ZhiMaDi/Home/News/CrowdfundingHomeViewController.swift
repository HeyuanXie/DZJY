//
//  CrowdfundingHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/11.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 新品众筹
var kTagCrowdfundBase = 10000
class CrowdfundingHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,ZMDInterceptorProtocol{

    enum ProjectType {
        case MyProject
        case HistoryType
        init(){
            self = MyProject
        }
    }
    var currentTableView: UITableView!
    var projectType = ProjectType()
    
    let kTagPageControl = kTagCrowdfundBase++
    let kTagScrollView = kTagCrowdfundBase++

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
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
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 600
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 0))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "OtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = RGB(66,221,211,1)
            
            let menuTitle = ["我参与的项目","历史项目"]
            let customJumpBtns = CustomJumpBtns(frame: CGRect(x: 0, y: 25, width: kScreenWidth, height: 55),menuTitle: menuTitle,textColorForNormal: UIColor.whiteColor(),textColorForSelect: UIColor.whiteColor())
            customJumpBtns.backgroundColor = UIColor.clearColor()
            customJumpBtns.addSeparatedLine(UIColor.whiteColor())
            customJumpBtns.redLine.backgroundColor = UIColor.clearColor()
            self.view.addSubview(customJumpBtns)
            customJumpBtns.finished = { (index) ->Void in
                self.projectType = [ProjectType.MyProject,ProjectType.HistoryType][index]
            }
            //在cell上添加一个ScrollView
            self.scrollView(80+44,cell: cell!)
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let cell = self.currentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let pageControl = cell!.viewWithTag(kTagPageControl) as! UIPageControl
        let scrollView = cell!.viewWithTag(kTagScrollView) as! UIScrollView
        let index = (scrollView.contentOffset.x+100)/(kScreenWidth - 100)
        pageControl.currentPage = Int(index)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    //MARK: -  PrivateMethod
    func updateUI() {
        self.title = "新品众筹"
        let lbl = ZMDTool.getLabel(CGRect(x: 0, y: 0, width: 70, height: 28), text: "了解众筹", fontSize: 14,textAlignment:.Center)
        lbl.backgroundColor = RGB(178,243,236,1)
        ZMDTool.configViewLayerWithSize(lbl, size: 7)
        let rightItem = UIBarButtonItem(customView: lbl)
        rightItem.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            
            return RACSignal.empty()
        })
        rightItem.customView?.tintColor = defaultTextColor
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64))
        self.currentTableView.backgroundColor = RGB(66,221,211,1)
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
    
    func scrollView(y:CGFloat,cell:UITableViewCell) {
        let height = kScreenWidth - 100 + 142
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: y, width: kScreenWidth, height: height))
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.scrollsToTop = false
        scrollView.pagingEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.tag = kTagScrollView
        cell.contentView.addSubview(scrollView)
        
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: CGRectGetMaxY(scrollView.frame)+32, width: kScreenWidth, height: 20))
        pageControl.backgroundColor = UIColor.clearColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.tag = kTagPageControl
        cell.contentView.addSubview(pageControl)
        
        let width = kScreenWidth - 100
        var i = 0
        for _ in ["","",""] {
            let projectV = self.projectView((width+22)*CGFloat(i))
            scrollView.addSubview(projectV)
            i++
        }
        scrollView.contentSize = CGSizeMake((width+22)*CGFloat(i), 0)
        scrollView.bounces = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        scrollView.contentOffset.x = -50
        pageControl.numberOfPages = i
    }
    
    func projectView(x:CGFloat) -> UIView {
        let width = kScreenWidth - 100,height = width + 142
        let view = UIButton(frame: CGRect(x: x, y: 0, width: width, height: height))
        view.backgroundColor = UIColor.whiteColor()
        view.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            let vc = CrowdfundDetailViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let imgV = UIImageView(frame: CGRect(x: 8, y: 8, width: width-16, height: width-16))
        imgV.backgroundColor = UIColor.grayColor()
        view.addSubview(imgV)
        
        let titleLbl = ZMDTool.getLabel(CGRect(x: 8, y: CGRectGetMaxY(imgV.frame) + 10, width: width-16, height: 17), text: "项目名称", fontSize: 17)
        view.addSubview(titleLbl)
        let hasMoneyLbl = ZMDTool.getLabel(CGRect(x: 0, y: CGRectGetMaxY(titleLbl.frame)+28, width: width/2, height: 44), text: "125000.0\n已筹金额", fontSize: 13,textAlignment: .Center)
        hasMoneyLbl.attributedText = "125000.0\n已筹金额".AttributeText(["125000.0","已筹金额"], colors: [defaultTextColor,defaultDetailTextColor],textSizes: [15,12])
        hasMoneyLbl.numberOfLines = 2
        view.addSubview(hasMoneyLbl)
        let timeLbl = ZMDTool.getLabel(CGRect(x: width/2, y: CGRectGetMaxY(titleLbl.frame)+28, width: width/2, height: 44), text: "23时23分58秒\n剩余时间", fontSize: 13,textAlignment: .Center)
        timeLbl.attributedText = "23时23分58秒\n剩余时间".AttributeText(["23时23分58秒","剩余时间"], colors: [defaultTextColor,defaultDetailTextColor],textSizes: [15,12])
        timeLbl.numberOfLines = 2
        view.addSubview(timeLbl)
        view.addSubview(ZMDTool.getLine(CGRect(x: 0, y: height-44.5, width: width, height: 0.5), backgroundColor: defaultLineColor))
        //星星图标
        let starImageView = UIImageView(frame: CGRect(x: 16, y: height-45, width: 10, height: 10))
        starImageView.image = UIImage(named: "")
        view.addSubview(starImageView)
        let targetMoneyLbl = ZMDTool.getLabel(CGRect(x: 32, y: height-45, width: width - 40, height: 44), text: "目标金额：250000.0元", fontSize: 15,textColor: defaultDetailTextColor)
        view.addSubview(targetMoneyLbl)
        return view
    }
}
