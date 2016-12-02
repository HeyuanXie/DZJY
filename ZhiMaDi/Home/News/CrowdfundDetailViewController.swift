//
//  CrowdfundDetailViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/12.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import MJRefresh
// 众筹详情
class CrowdfundDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,QNShareViewDelegate {
    enum CrowdfundCellType{
        case ContentTypeAd                      /* 广告显示页 */
        case ContentTypeDetail                   /* 菜单参数栏目 */
        case ontentTypeStore                   /* 发起人栏目 */
        case ContentTypeLottery            /* 商品抽奖栏目 */
        case ContentTypeReturn                   /*  回报*/
        case ContentTypeNextMenu                /* 下面展示菜单 */
        init(){
            self = ContentTypeAd
        }
        var height : CGFloat {
            switch self {
            case .ContentTypeAd :
                return kScreenWidth
            case .ContentTypeDetail :
                return 186
            case .ontentTypeStore :
                return 56
            case .ContentTypeLottery :
                return 56
            case .ContentTypeReturn :
                return 56
            case .ContentTypeNextMenu :
                return 60
            }
        }
    }
    enum SecondTableViewCellType {
        case ImageTextExplain
        case Supporter
        case ProjectExplain
        init() {
            self = ImageTextExplain
        }
    }
    enum ProjectExplainCellType {
        case ContentTypeNextMenu                /* 下面展示菜单 */
        
        case ProjectSchedule
        case TargetMoney
        case StartTime
        case EndTime
        case ExpectTime
        
        case Explain
        init(){
            self = ProjectSchedule
        }
        var title : String {
            switch self{
            case ContentTypeNextMenu:
                return ""
                
            case ProjectSchedule:
                return "项目进度"
            case TargetMoney:
                return "目标金额"
            case StartTime:
                return "众筹发起时间"
            case EndTime:
                return "众筹截止时间"
            case ExpectTime:
                return "预计回报发放时间 ：项目筹款成功后的30天内"
                
            case Explain:
                return "风险说明"
            }
        }
        var height : CGFloat {
            switch self {
            case ContentTypeNextMenu:
                return 60
            case .ProjectSchedule :
                return 144
            case .Explain :
                return 88
            default :
                return 56
            }
        }
        var projectCellType :[[ProjectExplainCellType]] {
            return [[.ContentTypeNextMenu],[.ProjectSchedule,.TargetMoney,.StartTime,.EndTime,.ExpectTime],[.Explain]]
        }
    }
    var currentTableView: UITableView!
    var secondTableView: UITableView!
    var bottomV: UIView!
    
    var cellTypes: [CrowdfundCellType]!
    var secondTableViewCellType = SecondTableViewCellType.Supporter
    var supportersData : NSArray!
    var projectExplainCellType : [[ProjectExplainCellType]]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.setupNewNavigation()
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
        if tableView == self.secondTableView {
            switch self.secondTableViewCellType {
            case .Supporter :
                return self.supportersData[section].count
            case .ProjectExplain:
                return self.projectExplainCellType[section].count
            default :
                if section == 0{
                    return 1
                } else {
                    //commentView
                    return 3
                }
            }
        }
        //第一个table中除了回报section是两行，其他全是一行
        let cellType = self.cellTypes[section]
        switch cellType {
        case .ContentTypeReturn :
            return 2
        default :
            return 1
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.secondTableView {
            switch self.secondTableViewCellType {
            case .Supporter :
                return self.supportersData.count
            case .ProjectExplain:
                return self.projectExplainCellType.count
            default :
                return 2
            }
        }
        
        return self.cellTypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.secondTableView {
            switch self.secondTableViewCellType {
            case .Supporter :
                return section == 1 ? 16 : 0.5
            case .ProjectExplain:
                return section == 0 ? 0 : 16
            default :
                return 0
            }
        }
        let cellType = self.cellTypes[section]
        switch cellType {
        case .ContentTypeNextMenu :
            return 16
        default :
            return 0.5
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.secondTableView {
            switch self.secondTableViewCellType {
            case .Supporter :
                return indexPath.section == 0 ? 60 : 65
            case .ProjectExplain :
                let projectCellType = self.projectExplainCellType[indexPath.section][indexPath.row]
                return projectCellType.height
            default :
                //60为nextMenu，140为commentView
                return indexPath.section == 0 ? 60 : 140
            }
        }
        
        let type = self.cellTypes[indexPath.section]
        return type.height
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //第二个table
        if tableView == self.secondTableView {
            switch self.secondTableViewCellType {
            case .Supporter :
                //支持者
                if indexPath.section == 0 {
                    return cellForHomeNextMenu(tableView, indexPath: indexPath)
                } else {
                    return cellSupportForSecond(tableView, indexPath: indexPath)
                }
            case .ProjectExplain :
                //项目说明
                let projectCellType = self.projectExplainCellType[indexPath.section][indexPath.row]
                switch projectCellType {
                case .ContentTypeNextMenu :
                    return cellForHomeNextMenu(tableView, indexPath: indexPath)
                case .ProjectSchedule :
                    return cellProjectScheduleForSecond(tableView, indexPath: indexPath)
                case .Explain :
                    return cellProjectExplainForSecond(tableView, indexPath: indexPath)
                default :
                    return cellProjectOtherForSecond(tableView, indexPath: indexPath)
                }
            case .ImageTextExplain :
                //图文详情
                if indexPath.section == 0 {
                    return cellForHomeNextMenu(tableView, indexPath: indexPath)
                } else {
                    return cellImageTextForSecond(tableView, indexPath: indexPath)
                }
            default :
                break
            }
        }
        
        //第一个table
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .ContentTypeAd :
            return cellForHomeAd(tableView, indexPath: indexPath)
        case .ContentTypeDetail :
            return cellForHomeDetail(tableView, indexPath: indexPath)
        case .ontentTypeStore :
            return cellForHomeStore(tableView, indexPath: indexPath)
        case .ContentTypeLottery :
            return cellForHomeDistribution(tableView, indexPath: indexPath,isLottery: true)
        case .ContentTypeReturn :
            return cellForHomeDistribution(tableView, indexPath: indexPath,isLottery: false)
        case .ContentTypeNextMenu :
            return cellForHomeNextMenu(tableView, indexPath: indexPath)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .ContentTypeReturn :
            //回报
            let vc = CrowdfundReturnViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default :
            break
        }
    }
    //MARK: QNShareViewDelegate
    func qnShareView(view: ShareView) -> (image: UIImage, url: String, title: String?, description: String)? {
        return (UIImage(named: "Share_Icon")!, "http://www.baidu.com", self.title ?? "", "成为喜特用户，享有更多服务!")
    }
    func present(alert: UIAlertController) -> Void {
        self.presentViewController(alert, animated: false, completion: nil)
    }
    //MARK: -  PrivateMethod
    //MARK: -  SecondTableView      cell
    //支持者
    func cellSupportForSecond(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "SupportCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            let leftLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth-12-200, y: 0, width: 200, height: 65), text: "", fontSize: 13,textColor: defaultDetailTextColor,textAlignment: .Right)
            leftLbl.numberOfLines = 2
            leftLbl.tag = 10001
            cell?.contentView.addSubview(leftLbl)
        }
        let image = UIImage(named: "home_banner02")
        cell?.imageView?.image = image!.imageWithImageSimple(CGSize(width: 40, height: 40))
        ZMDTool.configViewLayerWithSize((cell?.imageView)!, size: 20)
        cell?.textLabel?.textColor = defaultDetailTextColor
        cell?.textLabel!.text = "开档"
        let leftLbl = cell?.contentView.viewWithTag(10001) as! UILabel
        leftLbl.text = "1.0\n\(QNFormatTool.dateString02(NSDate()))"
        return cell!
    }
    
    //MARK: - 工程进度
    func cellProjectScheduleForSecond(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ScheduleCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            var i = 10000
            let titleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 20, width: kScreenWidth/2, height: 17), text: "", fontSize: 17)
            titleLbl.tag = i++
            cell?.contentView.addSubview(titleLbl)
            let hasMoneylbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(titleLbl.frame)+27, width: kScreenWidth/2, height: 15), text: "", fontSize: 15,textColor: defaultDetailTextColor)
            hasMoneylbl.tag = i++
            cell?.contentView.addSubview(hasMoneylbl)
            let reachLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(hasMoneylbl.frame)+12, width: kScreenWidth/2, height: 15), text: "", fontSize: 15,textColor: defaultDetailTextColor)
            reachLbl.tag = i++
            cell?.contentView.addSubview(reachLbl)
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 143.5, width: kScreenWidth, height: 0.5)))
            
            let view = CircleScaleCustomView(frame: CGRect(x: kScreenWidth - 36 - 100, y: 25, width: 100, height: 100),percentage: 0.5)
            view.clipsToBounds = true
            view.backgroundColor = UIColor.clearColor()
            cell?.contentView.addSubview(view)
        }
        let type = self.projectExplainCellType[indexPath.section][indexPath.row]
        var i = 10000
        let titleLbl = cell?.contentView.viewWithTag(i++) as! UILabel
        let hasMoneylbl = cell?.contentView.viewWithTag(i++) as! UILabel
        let reachLbl = cell?.contentView.viewWithTag(i++) as! UILabel
        titleLbl.text = type.title
        hasMoneylbl.text = "已筹金额 ：1295343.0"
        reachLbl.text = "达成率 ：50%"
        
        return cell!
    }
    //secondtable中的其他cell
    func cellProjectOtherForSecond(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ScheduleCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
            cell?.contentView.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55.5, width: kScreenWidth, height: 0.5)))
        }
        let type = self.projectExplainCellType[indexPath.section][indexPath.row]
        var title = ""
        switch type {
        case .TargetMoney :
            title = "\(type.title)250000.0"
            break
        case .StartTime :
            title = "\(type.title)2016-1-32"
            break
        case .EndTime :
            title = "\(type.title)2016-1-32"
            break
        case .ExpectTime :
            title = "\(type.title)"
            break
        default :
            break
        }
        cell?.textLabel?.text = title
        return cell!
    }
    //风险说明cell
    func cellProjectExplainForSecond(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ExplainCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            ZMDTool.configTableViewCellDefault(cell!)
        }
        let type = self.projectExplainCellType[indexPath.section][indexPath.row]
        cell?.textLabel?.text = type.title
        cell?.detailTextLabel?.text = "内容"
        return cell!
    }
    
    //图文详情commentView
    func cellImageTextForSecond(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "testCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let nibView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: nil, options: nil) as NSArray
            let remarkV = nibView.objectAtIndex(0) as? UIView
            remarkV!.frame = CGRectMake(0,0, kScreenWidth, 325)
            cell?.contentView.addSubview(remarkV!)
        }
        return cell!
    }
    //MARK: - First TableView
    //MARK: 广告 cell
    func cellForHomeAd(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ProductImgCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let cycleScroll = CycleScrollView(frame: CGRectMake(0, 0, kScreenWidth, kScreenWidth))
            cycleScroll.backgroundColor = UIColor.blueColor()
            let image = ["product_pic","product_pic"]
            cycleScroll.imgArray = image
            //            cycleScroll.delegate = self
            cycleScroll.autoScroll = true
            cycleScroll.autoTime = 2.5
            cell?.addSubview(cycleScroll)
        }
        return cell!
    }
    //MARK: 商品详请 cell
    func cellForHomeDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "DetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        let titleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: kScreenWidth - 24, height: 17), text: "彩色气球系列", fontSize: 17)
        cell?.contentView.addSubview(titleLbl)
        let detailLbl = ZMDTool.getLabel(CGRect(x: 12, y: CGRectGetMaxY(titleLbl.frame)+12, width: kScreenWidth - 24, height: 38), text: "此项目须在2016/05/02前，获得250000.00的支持才可成功", fontSize: 15,textColor: defaultDetailTextColor)
        detailLbl.numberOfLines = 2
        cell?.contentView.addSubview(detailLbl)
        
        let line = UIView(frame: CGRect(x: 12, y: CGRectGetMaxY(detailLbl.frame)+18, width: kScreenWidth - 24, height: 8))
        line.backgroundColor = RGB(229,229,229,1.0)
        ZMDTool.configViewLayer(line)
        cell?.contentView.addSubview(line)
        let blueLine = UIView(frame: CGRect(x: 0, y: 0, width: (kScreenWidth - 24)*0.5, height: 8))
        blueLine.backgroundColor = RGB(66,221,221,1.0)
        line.addSubview(blueLine)
        let title = ["50%\n达成率","125000.0\n已筹金额","23时24分05秒\n剩余时间"]
        let detailTitle = ["达成率","已筹金额","剩余时间"]
        for index in [0,1,2] {
            let lbl = ZMDTool.getLabel(CGRect(x: kScreenWidth/3*CGFloat(index), y: CGRectGetMaxY(line.frame), width: kScreenWidth/3, height: 75), text: title[index], fontSize: 14,textAlignment:.Center)
            lbl.attributedText = title[index].AttributeText([detailTitle[index]], colors: [defaultDetailTextColor], textSizes: [13])
            lbl.numberOfLines = 2
            cell?.contentView.addSubview(lbl)
        }
        return cell!
    }
    //MARK:抽奖和回报cell(通过isLottery判断)
    func cellForHomeDistribution(tableView: UITableView,indexPath: NSIndexPath,isLottery: Bool)-> UITableViewCell {
        let cellId = "DistributionCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.accessoryType = .DisclosureIndicator
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            ZMDTool.configTableViewCellDefault(cell!)
        }
        cell?.textLabel?.textColor = RGB(66,221,210,1)
        cell?.textLabel?.text = "¥1.0"
        let detailLbl = ZMDTool.getLabel(CGRect(x: kScreenWidth-38-200, y: 0, width: 200, height: 55), text: "抽奖", fontSize: 17, textColor: defaultDetailTextColor, textAlignment: .Right)
        if !isLottery {
            detailLbl.text = "回报\(indexPath.row+1)"
        }
        cell!.contentView.addSubview(detailLbl)
        return cell!
    }
    //MARK: 店家 cell
    func cellForHomeStore(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "StoreCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        cell?.textLabel?.text = "发起人  葫芦堡旗舰店"
        return cell!
    }
    //MARK:  下一页菜单 cell
    func cellForHomeNextMenu(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "NextMenuCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            cell?.addSubview(self.createFilterMenu())
        }
        return cell!
    }
    
    func createFilterMenu() -> UIView{
        let titles = ["图文详情","支持者","项目说明"]
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 60))
        for var i=0;i<titles.count;i++ {
            let btn = UIButton(frame:  CGRectMake(CGFloat(i) * kScreenWidth/3 , 0, kScreenWidth/3, 60))
            btn.backgroundColor = UIColor.clearColor()
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.setTitleColor(UIColor.yellowColor(), forState: .Selected)
            btn.titleLabel?.font = UIFont.systemFontOfSize(17)
            btn.tag = 1000 + i
            view.addSubview(btn)
            //点击btn时切换secondTable的cell类型
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                let index = sender.tag - 1000
                self.secondTableViewCellType = [SecondTableViewCellType.ImageTextExplain,.Supporter,.ProjectExplain][index]
                self.secondTableView.reloadData()
            })
            if i < 2{
                let lineView = UIView(frame: CGRectMake(CGFloat(i + 1) * kScreenWidth/3, 18, 0.5, 21))
                lineView.backgroundColor = defaultLineColor
                view.addSubview(lineView)
            }
        }
        return view
    }
    func setupNewNavigation() {
    }
    private func dataInit(){
        self.supportersData = [[""],[""],[""],[""]]
        self.projectExplainCellType = ProjectExplainCellType().projectCellType
        self.cellTypes = [.ContentTypeAd,.ContentTypeDetail,.ontentTypeStore,.ContentTypeLottery,.ContentTypeReturn,.ContentTypeNextMenu]
    }
    func footerRefresh(){
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.currentTableView.frame
            self.secondTableView.frame = frame
            frame.origin = CGPoint(x: 0, y: frame.origin.y - frame.size.height)
            self.currentTableView.frame = frame
            }, completion: { (bool) -> Void in
                self.currentTableView.mj_footer.endRefreshing()
        })
    }
    // 顶部刷新
    func headerRefresh(){
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.secondTableView.frame
            self.currentTableView.frame = frame
            frame.origin = CGPoint(x: 0, y: 64 + frame.size.height)
            self.secondTableView.frame = frame
            }, completion: { (bool) -> Void in
                self.secondTableView.mj_header.endRefreshing()
        })
    }
    func updateUI() {
        self.title = "众筹详情"
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 58, height: 22))
        let collectBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        collectBtn.setImage(UIImage(named: "product_collect_03"), forState: .Normal)
        collectBtn.setImage(UIImage(named: "product_collect_04"), forState: .Selected)
        collectBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            //众筹的收藏
        }
        rightView.addSubview(collectBtn)
        let shareBtn = UIButton(frame: CGRect(x: 22 + 14, y: 0, width: 22, height: 22))
        shareBtn.setImage(UIImage(named: "product_share_02"), forState: .Normal)
        shareBtn.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) -> Void in
            //众筹分享
            
        }
        rightView.addSubview(shareBtn)
        
        let rightItem = UIBarButtonItem(customView: rightView)
        self.navigationItem.rightBarButtonItem = rightItem
        
        var frame = self.view.bounds
        frame.size.height = frame.size.height - 56 - 64
        self.currentTableView = UITableView(frame: frame)
        self.currentTableView.backgroundColor  = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
        // 底部刷新
        let footer = MJRefreshAutoNormalFooter()
        let tmp_ = NSMutableAttributedString()
        tmp_.appendAttributedString(NSAttributedString(string: "继续往下拖动，查看详情"))
        tmp_.appendAttributedString("".AttributedStringWithImage(UIImage(named: "product_down")!,size: CGSize(width: 20, height: 20)))
        footer.setTitle("继续往下拖动，查看详情", forState: .Idle)
        footer.stateLabel?.attributedText = tmp_
        footer.setRefreshingTarget(self, refreshingAction: Selector("footerRefresh"))
        self.currentTableView.mj_footer = footer
        self.configSecondTableView()
        self.configeBottomView()
    }
    
    func configSecondTableView() {
        // 顶部刷新
        let header = MJRefreshNormalHeader()
        header.setRefreshingTarget(self, refreshingAction: Selector("headerRefresh"))
        secondTableView = UITableView(frame: CGRect(x: 0, y: CGRectGetMaxY(self.currentTableView.frame), width: kScreenWidth, height: self.currentTableView.frame.size.height))
        secondTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.separatorStyle = .None
        self.view.addSubview(secondTableView)
        self.secondTableView.mj_header = header
    }
    
    func configeBottomView() {
        self.bottomV = UIView(frame: CGRect(x: 0, y: kScreenHeight - 64 - 56, width: kScreenWidth, height: 56))
        self.bottomV.backgroundColor = RGB(247,247,247,1)
        self.view.addSubview(self.bottomV)
        let consultationBtn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: 100, height: 56), textForNormal: "咨询", fontSize: 17, backgroundColor: UIColor.clearColor()) { (sender) -> Void in
            //咨询
        }
        consultationBtn.setImage(UIImage(named: "product_chat"), forState: .Normal)
        self.bottomV.addSubview(consultationBtn)
        let supportBtn = ZMDTool.getButton(CGRect(x: kScreenWidth - 110-12, y: 10, width: 110, height: 36), textForNormal: "去支持", fontSize: 17,textColorForNormal:UIColor.whiteColor(), backgroundColor: RGB(66,221,211,1)) { (sender) -> Void in
            //支持
        }
        ZMDTool.configViewLayerWithSize(supportBtn, size: 18)
        self.bottomV.addSubview(supportBtn)
        
    }
}
