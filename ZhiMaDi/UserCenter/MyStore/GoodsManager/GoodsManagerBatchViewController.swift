//
//  GoodsManagerBatchViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/6.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 批量管理
class GoodsManagerBatchViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {

    @IBOutlet weak var currentTableView: UITableView!
    var filtedBtnSelect : UIButton!             //筛选-高亮btn
    var filtedSortBtnSelect : UIButton!             //筛选-分类高亮btn
    var sellV,filtedV: UIView!
    var goods = NSArray()
    var indexS = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
        goods = ["","","","","","","","","","",""]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goods.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 16 + 55 : 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  150
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.createFilterMenu()
        } else {
            let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 0))
            headView.backgroundColor = UIColor.clearColor()
            return headView
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "GoodsCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? GoodsManagerBatchCell
        cell!.selectBtn.superview?.tag = indexPath.row + 1000
        cell!.selectBtn.selected =  self.indexS == indexPath.row - 1000
        cell!.selectBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            self.indexS = (sender as! UIButton).superview!.tag - 1000
            self.currentTableView.reloadData()
            return RACSignal.empty()
        })
        cell!.selectBtn.selected = self.indexS == indexPath.row
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
    }
    //MARK: -  PrivateMethod
    func createFilterMenu() -> UIView{
        let titles = ["出售中","筛选"]
        let countForBtn = CGFloat(titles.count)
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 55 + 16))
        view.backgroundColor = UIColor.clearColor()
        for var i=0;i<titles.count;i++ {
            let index = i%titles.count
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * (kScreenWidth)/countForBtn , 0, (kScreenWidth)/countForBtn, 55))
            btn.backgroundColor = UIColor.whiteColor()
            if titles[i] == "筛选" {
                btn.setImage(UIImage(named: "list_filter_normal"), forState: .Normal)
                btn.setImage(UIImage(named: "list_filter_selected"), forState: .Selected)
            }
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
            btn.titleLabel?.font = UIFont.systemFontOfSize(17)
            btn.tag = 1000 + i
            view.addSubview(btn)
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                if self.filtedBtnSelect != nil {
                    self.filtedBtnSelect.selected = false
                }
                self.filtedBtnSelect = (sender as! UIButton)
                self.filtedBtnSelect.selected = true
                
                let point = btn.convertPoint(btn.frame.origin, fromView: self.currentTableView)
                if self.sellV == nil {
                    self.sellV = self.viewForSell(-point.y+55)
                }
                if self.filtedV == nil {
                    self.filtedV = self.configFiltedView(-point.y + 55)
                }
                self.sellV.removeFromSuperview()
                self.filtedV.removeFromSuperview()
                
                let showVs = [self.sellV,self.filtedV]
                let tmp = (sender as! UIButton).tag
                self.currentTableView.scrollEnabled = false
                self.currentTableView.addSubview(showVs[sender.tag - 1000])
                //                let config = ZMDPopViewConfig()
                //                config.showAnimation = .SlideInFromTop
                //
                //                self.presentPopupView(showVs[sender.tag - 1000],config: config)
            })
            let line = ZMDTool.getLine(CGRectMake(CGRectGetWidth(btn.frame)-1, 20, 1, 13))
            btn.addSubview(line)
        }
        view.addSubview(ZMDTool.getLine(CGRectMake(0, 54.5, kScreenWidth, 0.5)))
        return view
    }
    //MARK: - Action
    
    @IBAction func changeSortBtnCli(sender: UIButton) {
        let sortV = self.viewForSort()
        self.viewShowWithBg(sortV,showAnimation: .SlideInFromBottom,dismissAnimation: .SlideOutToBottom)
    }
    private func subViewInit(){
//        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
//        self.currentTableView.separatorStyle = .None
//        self.currentTableView.dataSource = self
//        self.currentTableView.delegate = self
//        self.view.addSubview(self.currentTableView)
    }
    // 筛选 弹出的 view
    func viewForSell(y:CGFloat) ->UIView {
        let height = CGRectGetHeight(self.view.bounds)
        let sellV = UIButton(frame: CGRect(x: 0, y: y, width: kScreenWidth, height: height))
        sellV.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        sellV.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            sellV.removeFromSuperview()
            return RACSignal.empty()
        })
        let titles = ["出售中","未上架"]
        var i = 0
        for title in titles {
            let size = title.sizeWithFont(UIFont.systemFontOfSize(17), maxWidth: 200)
            let btn = ZMDTool.getButton(CGRect(x: 0, y: 55 * CGFloat(i++), width: kScreenWidth, height: 55), textForNormal: title, fontSize: 17, backgroundColor: UIColor.whiteColor(), blockForCli: { (sender) -> Void in
                let tmp =  (sender as! UIButton)
                
                self.currentTableView.scrollEnabled = true
                sellV.removeFromSuperview()
                tmp.selected = !tmp.selected
            })
            btn.setTitle(title, forState: .Normal)
            btn.setTitle(title, forState: .Selected)
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
            btn.setImage(UIImage(named:"user_wallet_unselected"), forState: .Normal)
            btn.setImage(UIImage(named:"user_wallet_selected"), forState: .Selected)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: kScreenWidth - size.width - 12 - 26)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: kScreenWidth - 26, bottom: 0, right: 0)
            sellV.addSubview(btn)
        }
        sellV.addSubview(ZMDTool.getLine(CGRect(x: 0, y: 55, width: kScreenWidth, height: 0.5)))
        return sellV
    }
    func configFiltedView (y:CGFloat) -> UIView{
        let height = CGRectGetHeight(self.view.bounds) - y
        let mainV = UIView(frame: CGRectMake(0 , y, kScreenWidth,  height))
        mainV.backgroundColor = UIColor.whiteColor()
        
        let filtedView = UIScrollView(frame: CGRectMake(0 , 0, kScreenWidth,  height - 58))
        filtedView.backgroundColor = UIColor.whiteColor()
        mainV.addSubview(filtedView)
        
        let filtedTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 100, height: 16), text: "商品分类", fontSize: 16, textColor: defaultTextColor)
        filtedView.addSubview(filtedTitleLbl)
        let filetTitle = ["全部","分销商品","代销商品","自营商品","租赁"]
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
            btn.setTitleColor(defaultDetailTextColor, forState: .Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
            ZMDTool.configViewLayer(btn)
            filtedView.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.filtedSortBtnSelect.selected = false
                self.filtedSortBtnSelect = sender as! UIButton
                self.filtedSortBtnSelect.selected = true
            })
            if i == 0 {
                btn.selected = true
                self.filtedSortBtnSelect = btn
            }
            i++
            if i == filetTitle.count {
                maxY = CGRectGetMaxY(btn.frame)
            }
        }
        filtedView.addSubview( ZMDTool.getLine(CGRect(x: 0, y: maxY + 16, width: kScreenWidth, height: 0.5)))
        
        let leaseTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: maxY + 32, width: 100, height: 16), text: "租期", fontSize: 16, textColor: defaultTextColor)
        filtedView.addSubview(leaseTitleLbl)
        let leaseTitle = ["全部","床上用品","家具","日用品","植物","装饰品","未分类"]
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
            ZMDTool.configViewLayer(btn)
            filtedView.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                //                self.leaseBtnSelect.selected = false
                //                self.leaseBtnSelect = sender as! UIButton
                self.filtedBtnSelect.selected = true
            })
            if j == 0 {
                btn.selected = true
                //                self.leaseBtnSelect = btn
            }
            j++
            if j == leaseTitle.count {
                maxLeaseY = CGRectGetMaxY(btn.frame)
            }
        }
        filtedView.addSubview( ZMDTool.getLine(CGRect(x: 0, y: maxLeaseY + 16, width: kScreenWidth, height: 0.5)))
        
        filtedView.contentSize = CGSize(width: kScreenWidth, height: maxLeaseY + 16)
        
        let okBtn = ZMDTool.getButton(CGRect(x: 0, y: CGRectGetHeight(mainV.frame) - 58, width: kScreenWidth, height: 58), textForNormal: "确定",fontSize: 20,textColorForNormal :UIColor.whiteColor(), backgroundColor:  RGB(235,61,61,1.0), blockForCli: ({ (sender) -> Void in
            self.currentTableView.scrollEnabled = true
            mainV.removeFromSuperview()
        }))
        mainV.addSubview(okBtn)
        return mainV
    }
    func viewForSort () -> UIView{
        let filtedView = UIView(frame: CGRectMake(0 , self.view.bounds.height - 220, kScreenWidth, 220))
        filtedView.backgroundColor = UIColor.whiteColor()
        
        let filtedTitleLbl = ZMDTool.getLabel(CGRect(x: 12, y: 16, width: 200, height: 16), text: "选择分类（可多选）", fontSize: 16, textColor: defaultTextColor)
        filtedView.addSubview(filtedTitleLbl)
        let filetTitle = ["床上用品","家具","日用品","植物","装饰品"]
        var i = 0
        var maxY : CGFloat = 0
        for title in filetTitle {
            let width = (kScreenWidth - 24 - 2 * 8)/3
            let Tmp = i%3 , Tmp2 = i/3
            let x = 12 + CGFloat(Tmp) * width + CGFloat(Tmp) * 8
            let y = 16 + 16 + 20 + CGFloat(Tmp2) * (38 + 8)
            
            let btn = UIButton(frame: CGRect(x: x, y: y, width: width, height: 38))
            btn.setBackgroundImage(UIImage.imageWithColor(RGB(240,240,240,1), size: btn.frame.size), forState: .Normal)
            btn.setBackgroundImage(UIImage.imageWithColor(RGB(235,61,61,1.0), size: btn.frame.size), forState: .Selected)
            
            btn.tag = 1000 + NSInteger(i)
            btn.titleLabel!.font = defaultSysFontWithSize(15)
            btn.setTitle(title, forState: .Normal)
            btn.setTitle(title, forState: .Selected)
            btn.setTitleColor(defaultDetailTextColor, forState: .Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
            ZMDTool.configViewLayer(btn)
            filtedView.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.filtedSortBtnSelect.selected = false
                self.filtedSortBtnSelect = sender as! UIButton
                self.filtedSortBtnSelect.selected = true
            })
            if i == 0 {
                btn.selected = true
                self.filtedSortBtnSelect = btn
            }
            i++
            if i == filetTitle.count {
                maxY = CGRectGetMaxY(btn.frame)
            }
        }
        filtedView.addSubview( ZMDTool.getLine(CGRect(x: 0, y: CGRectGetHeight(filtedView.frame) - 58.5, width: kScreenWidth, height: 0.5)))
        
        let okBtn = ZMDTool.getButton(CGRect(x: 0, y: CGRectGetHeight(filtedView.frame) - 58, width: kScreenWidth, height: 58), textForNormal: "确定",fontSize: 20,textColorForNormal :defaultTextColor, backgroundColor:  RGB(247,247,247,1.0), blockForCli: ({ (sender) -> Void in
            filtedView.removeFromSuperview()
        }))
        filtedView.addSubview(okBtn)
        return filtedView
    }
}
