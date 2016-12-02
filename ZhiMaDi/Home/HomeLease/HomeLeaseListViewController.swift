//
//  HomeLeaseViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/28.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//租赁列表
class HomeLeaseListViewController: UIViewController ,ZMDInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{
    enum TypeSetting {
        case Horizontal
        case vertical
    }
    @IBOutlet weak var currentTableView: UITableView!
    var popView : UIView!
    var cityPop : FindDoctorCityPopView!
    var filtedView : UIView!                    //选择分类和租期的View
    var filtedBtnSelect : UIButton!             //筛选-分类高亮btn
    var leaseBtnSelect : UIButton!              //筛选-租期高亮btn
    var dataArray = ["","","",""]
    var typeSetting = TypeSetting.Horizontal      // 横屏
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.setupNewNavigation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
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
        return self.typeSetting == .Horizontal ? (self.dataArray.count/2 + 1) : self.dataArray.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 52 + 16 : 10
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.typeSetting == .Horizontal ? 581/750 * kScreenWidth + 10 : 300/750 * kScreenWidth
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.createFilterMenu()
        } else {
            let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
            headView.backgroundColor = UIColor.clearColor()
            return headView
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = self.typeSetting == .Horizontal ? "doubleLeaseCell" : "goodsLeaseCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DoubleGoodsLeaseTableViewCell
        cell.goodsImgVLeft.image = UIImage(named: "home_banner02")
        if self.typeSetting == .Horizontal {
            let size = cell.currentPriceLblLeft.text?.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 160)
            cell.currentPriceWidthLayout.constant = (size?.width)!
        } else {
            
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = HomeLeaseDetailViewController.CreateFromMainStoryboard() as! HomeLeaseDetailViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -  PrivateMethod
    //MARK: 创建目录View
    func createFilterMenu() -> UIView{
        let menuTitles = ["默认","人气","价格","筛选",""]
        var btnArr = NSMutableArray()
        let countForBtn = CGFloat(menuTitles.count) - 1
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 52 + 16))
        view.backgroundColor = UIColor.clearColor()
        for var i=0;i<menuTitles.count;i++ {
            let index = i%menuTitles.count
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * (kScreenWidth-54)/countForBtn , 0, (kScreenWidth-54)/countForBtn, 52))
            btn.backgroundColor = UIColor.whiteColor()
            if menuTitles[i] == "" {
                btn.frame = CGRectMake(CGFloat(index) * (kScreenWidth-54)/countForBtn, 0, 54, 52)
                btn.setImage(UIImage(named: "list_hengpai"), forState: .Normal)
                btn.setImage(UIImage(named: "list_shupai"), forState: .Selected)
                btn.selected = self.typeSetting == .Horizontal ? false : true
            } else {
                btn.setTitle(menuTitles[i], forState: .Normal)
                btn.setTitle(menuTitles[i], forState: .Normal)
            }
            if menuTitles[i] == "价格" {
                btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                
                let width = (kScreenWidth-54)/countForBtn
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (width-50)/2+40, bottom: 0, right: 0)
                btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (width-50)/2+16)
            }
            if menuTitles[i] == "默认" {
                btn.selected = true
            }
            
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.setTitleColor(defaultSelectColor, forState: .Selected)
            btn.titleLabel?.font = UIFont.systemFontOfSize(13)
            btn.tag = 1000 + i
            view.addSubview(btn)
            btnArr.addObject(btn)
            //MARK:Menu响应
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                //控制按钮高亮状态
//                (sender as! UIButton).selected = !(sender as! UIButton).selected
                for tmp in btnArr{
                    let btn = tmp as! UIButton
                    if(btn.tag == (sender as! UIButton).tag){
                        btn.selected = true
                    }else{
                        btn.selected = false
                    }
                }
                //横竖排按钮
                if (sender.tag - 1000) == menuTitles.count - 1 {
                    self.typeSetting = self.typeSetting == .Horizontal ? .vertical : .Horizontal
                    self.currentTableView.reloadData()
                    return
                }
//                if self.cityPop == nil {
//                    let height = kScreenHeight/3 * 2 - kScreenHeight/3 * 2 % 40
//                    self.cityPop = FindDoctorCityPopView(frame: CGRectMake(0, CGRectGetMaxY(btn.frame), kScreenWidth,height))
//                    //                    if self.currentCity != nil {
//                    //                        cityPop.titleLbl.text = self.currentCity
//                    //                    }
//                }
                //其他按钮
                //点击筛选，弹出filterView
                if (sender.tag - 1000) == menuTitles.count - 2 {
                    let config = ZMDPopViewConfig()
                    config.showAnimation = .SlideInFromTop
                    //创建FiltedView
                    self.configFiltedView(CGRectGetMaxY(btn.frame) + 1, height: self.view.bounds.height - CGRectGetMaxY(btn.frame))
                    self.filtedView.hidden = false
                    self.presentPopupView(self.filtedView,config: config)
                }
                //点击价格
                if (sender.tag - 1000) == menuTitles.count - 3 {
//                    self.orderBy = ?
                    //根据self.orderBy刷新table
                }
                //点击人气
                if (sender.tag - 1000) == menuTitles.count - 4 {
//                    self.orderBy = ?
                }
                //点击默认
                if (sender.tag - 1000) == menuTitles.count - 5 {
//                    self.orderBy = ?
                }
            })
            let line = ZMDTool.getLine(CGRectMake(CGRectGetMaxX(btn.frame)-1, 20, 1, 13))
            btn.addSubview(line)
        }
        return view
    }
    //MARK:设置导航栏
    func setupNewNavigation() {
        let rightItem = UIBarButtonItem(image: UIImage(named: "home_search")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        rightItem.tintColor = navigationTextColor
        rightItem.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let homeBuyGoodsSearchViewController = HomeBuyGoodsSearchViewController.CreateFromMainStoryboard() as! HomeBuyGoodsSearchViewController
            self.navigationController?.pushViewController(homeBuyGoodsSearchViewController, animated: true)
            return RACSignal.empty()
        })
        rightItem.customView?.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightItem
    }
    //MARK:设置FiltedView
    func configFiltedView (y:CGFloat,height:CGFloat) {
        let filtedView = UIView(frame: CGRectMake(0 , y, kScreenWidth,  height))
        filtedView.backgroundColor = UIColor.whiteColor()
        let filtedTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 100, height: 16), text: "商品分类", fontSize: 16, textColor: defaultTextColor)
        filtedView.addSubview(filtedTitleLbl)
        let filetTitle = ["全部","床上用品","家具","日用品","植物","装饰品"]
        var i = 0
        var maxY : CGFloat = 0
        for title in filetTitle {
            let width = (kScreenWidth - 24 - 2 * 8)/3
            let Tmp = i%3 , Tmp2 = i/3
            let x = 12 + CGFloat(Tmp) * width + CGFloat(Tmp) * 8
            let y = 16 + 16 + 12 + CGFloat(Tmp2) * (38 + 8)
            
            let btn = UIButton(frame: CGRect(x: x, y: y, width: width, height: 38))
            btn.setBackgroundImage(UIImage.imageWithColor(RGB(240,240,240,1), size: btn.frame.size), forState: .Normal)
            btn.setBackgroundImage(UIImage.imageWithColor(RGB(235,61,61,1.0), size: btn.frame.size), forState: .Selected)

            btn.tag = 1000 + NSInteger(i)
            btn.titleLabel!.font = defaultSysFontWithSize(15)
            btn.setTitle(title, forState: .Normal)
            btn.setTitle(title, forState: .Selected)
            btn.setTitleColor(RGB(192,192,192,1), forState: .Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
            filtedView.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.filtedBtnSelect.selected = false
                self.filtedBtnSelect = sender as! UIButton
                self.filtedBtnSelect.selected = true
            })
            //默认全部是 高亮
            if i == 0 {
                btn.selected = true
                self.filtedBtnSelect = btn
            }
            i++
            //根据分类中最后一个btn来求maxY，用来确定 租期的frame
            if i == filetTitle.count {
                maxY = CGRectGetMaxY(btn.frame)
            }
        }
        
        filtedView.addSubview( ZMDTool.getLine(CGRect(x: 0, y: maxY + 16, width: kScreenWidth, height: 0.5)))
        
        
        let leaseTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: maxY + 32, width: 100, height: 16), text: "租期", fontSize: 16, textColor: defaultTextColor)
        filtedView.addSubview(leaseTitleLbl)
        let leaseTitle = ["全部","半年","一年半","两年"]
        var j = 0
        var maxLeaseY : CGFloat = 0
        for title in leaseTitle {
            let width = (kScreenWidth - 24 - 2 * 8)/3
            let Tmp = j%3 , Tmp2 = j/3
            let x = 12 + CGFloat(Tmp) * width + CGFloat(Tmp) * 8
            let y = maxY + 32 + 16 + 12 + CGFloat(Tmp2) * (38 + 8)
            let btn = UIButton(frame: CGRect(x: x, y: y, width: width, height: 38))
            btn.setBackgroundImage(UIImage.imageWithColor(RGB(240,240,240,1), size: btn.frame.size), forState: .Normal)
            btn.setBackgroundImage(UIImage.imageWithColor(RGB(235,61,61,1.0), size: btn.frame.size), forState: .Selected)
            btn.tag = 1000 + NSInteger(i)
            btn.titleLabel!.font = defaultSysFontWithSize(15)
            btn.setTitle(title, forState: .Normal)
            btn.setTitle(title, forState: .Selected)
            btn.setTitleColor(RGB(192,192,192,1), forState: .Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
            filtedView.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.leaseBtnSelect.selected = false
                self.leaseBtnSelect = sender as! UIButton
                self.leaseBtnSelect.selected = true
            })
            if j == 0 {
                btn.selected = true
                self.leaseBtnSelect = btn
            }
            j++
            if j == leaseTitle.count {
                maxLeaseY = CGRectGetMaxY(btn.frame)
            }
        }
        filtedView.addSubview( ZMDTool.getLine(CGRect(x: 0, y: maxLeaseY + 16, width: kScreenWidth, height: 0.5)))

        //确定 按钮
        let btn = UIButton(frame: CGRect(x: 0, y: height - 56 , width: kScreenWidth, height: 56))
        btn.backgroundColor = RGB(235,61,61,1.0)
        btn.titleLabel!.font = defaultSysFontWithSize(18)
        btn.setTitle("确定", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        filtedView.addSubview(btn)
        btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
            //点击确定按钮
            self.filtedView.hidden = true
            //根据选好条件刷新tableView
        })
    
        self.filtedView = filtedView
    }
    
}
