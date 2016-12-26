//
//  EnterpirseListViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/14.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class EnterpirseListViewController: UIViewController,ZMDInterceptorProtocol,UITableViewDataSource,UITableViewDelegate {

    //MARK: - Property
    @IBOutlet weak var currentTableView : UITableView!
    
    var enterpriseArray = NSMutableArray()
    var selectView : UIView!
    
    var selectBtn1 : UIButton!
    var selectBtn2 : UIButton!
    var selectLbl1 : UILabel!
    var selectLbl2 : UILabel!
    
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchData()
        self.initUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(animated: Bool) {
        if let selectView = self.selectView {
            selectView.removeFromSuperview()
        }
    }

    
    //MARK: - PrivateMethod
    func fetchData() {
        QNNetworkTool.fetchHomeEnterprise { (success, enterprises, error) -> Void in
            if success {
                self.enterpriseArray.removeAllObjects()
                self.enterpriseArray.addObjectsFromArray(enterprises as! [AnyObject])
                self.currentTableView.reloadData()
            }
        }
    }
    func initUI() {
        self.title = "交易企业"
        self.viewForSelect()
    }
    
    func viewForSelect() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 46))
        self.view.addSubview(bgView)
        //确定btn
        let confirmBtn = ZMDTool.getButton(CGRectMake(kScreenWidth-zoom(70), 10, zoom(55), 26), textForNormal: "确定", fontSize: 14, textColorForNormal: defaultTextColor, backgroundColor: UIColor.clearColor()) { (sender) in
            //
            self.fetchData()
        }
        ZMDTool.configViewLayer(confirmBtn)
        ZMDTool.configViewLayerFrameWithColor(confirmBtn, color: defaultLineColor)
        bgView.addSubview(confirmBtn)
        
        //删选View
        let width = (kScreenWidth-zoom(90))/2
        let left = zoom(10)
        for i in 0..<2 {
            let view = UIView(frame: CGRect(x: CGFloat(i)*width, y: 0, width: width, height: 46))
            let label = ZMDTool.getLabel(CGRect(x: left, y: 0, width: width-zoom(35), height: 46), text: "行业 : 不限", fontSize: 14, textColor: defaultDetailTextColor, textAlignment: .Center)
            label.attributedText = label.text?.AttributedText("行业 :", color: defaultTextColor)
            let btn = ZMDTool.getButton(CGRectMake(width-zoom(35), 0, zoom(35), 46), textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) in
                
                //背景btn
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
                btn.tag = 100
                self.view.addSubview(btn)
                btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                    //移除灰色背景btn
                    btn.removeFromSuperview()
                    self.selectView.removeFromSuperview()
                    return RACSignal.empty()
                })
                
                
                let downBtn = sender as! UIButton     //downBtn
                downBtn.selected = !downBtn.selected
                if self.selectView != nil {
                    self.selectView.removeFromSuperview()
                }
                self.selectView = UIView(frame: CGRect(x: zoom(65), y: 64, width: zoom(80), height: 3*zoom(36)))
                if downBtn == self.selectBtn2 {
                    self.selectView.frame = CGRectMake(zoom(207), 64, zoom(80), 3*zoom(36))
                }
                self.selectView.backgroundColor = RGB(253,124,76,1.0)
                self.selectView.alpha = 1.0
                ZMDTool.configViewLayer(self.selectView)
                let titles = ["水果","蔬菜","农产品"]
                for i in 0..<3 {
                    let title = titles[i]
                    let btn = UIButton(frame: CGRect(x: 0, y: 36*CGFloat(i)*kScreenWidth/375, width: 80*kScreenWidth/375, height: 36*kScreenWidth/375))
                    btn.tag = 1000+i
                    btn.setTitle(title, forState: .Normal)
                    btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                    btn.backgroundColor = UIColor.clearColor()
                    btn.addSubview(ZMDTool.getLine(CGRect(x: 0, y: btn.frame.height-0.5, width: btn.frame.width, height: 0.5), backgroundColor: UIColor.whiteColor()))
                    btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                        //移除背景btn
                        if let view = self.view.viewWithTag(100) {
                            view.removeFromSuperview()
                        }
                        //移除selectView
                        self.selectView.removeFromSuperview()
                        if downBtn == self.selectBtn1 {
                            if let title = (sender as! UIButton).titleLabel?.text {
                                self.selectLbl1.text = "行业 : \(title)"
                            }
                            self.selectLbl1.attributedText = self.selectLbl1.text!.AttributedText("行业 :", color: defaultTextColor)
                        }else{
                            if let title = (sender as! UIButton).titleLabel?.text {
                                self.selectLbl2.text = "行业 : \(title)"
                            }
                            self.selectLbl2.attributedText = self.selectLbl2.text!.AttributedText("行业 :", color: defaultTextColor)
                        }
                        return RACSignal.empty()
                    })
                    self.selectView.addSubview(btn)
                }
                self.selectView.showAsPop(setBgColor: false)
            })
            btn.tag = 10001
            btn.setImage(UIImage(named: "arrow01"), forState: .Normal)
            
            view.addSubview(label)
            view.addSubview(btn)
            view.addSubview(ZMDTool.getLine(CGRect(x: width-0.5, y: 15, width: 0.5, height: 16)))
            bgView.addSubview(view)
            if i == 0 {
                self.selectBtn1 = btn
                self.selectLbl1 = label
            }else{
                self.selectBtn2 = btn
                self.selectLbl2 = label
                self.selectBtn2.hidden = true
                self.selectLbl2.hidden = true
            }
        }
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.enterpriseArray.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return zoom(12)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(12)))
        view.backgroundColor = tableViewdefaultBackgroundColor
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = self.enterpriseArray[indexPath.section] as! ZMDEnterprise
        if indexPath.row == 1 {
            return zoom(56)
        }else{
            return data.Products.count == 0 ? 90 : 220
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.cellForImageCell(tableView,indexPath:indexPath)
        }else{
            return self.cellForBotCell(tableView,indexPath:indexPath)
        }
    }
    
    //MARK: - TableViewCell
    func cellForImageCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "imageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        ZMDTool.configTableViewCellDefault(cell!)
        cell?.addLine()
        let titleLbl = cell?.contentView.viewWithTag(10000) as! UILabel
        let mainLbl = cell?.contentView.viewWithTag(10001) as! UILabel
        let countLbl1 = cell?.contentView.viewWithTag(10002) as! UILabel
        let countLbl2 = cell?.contentView.viewWithTag(10003) as! UILabel
        let detailBtn = cell?.contentView.viewWithTag(10004) as! UIButton
        let scrollView = cell?.contentView.viewWithTag(10005) as! UIScrollView

        let data = self.enterpriseArray[indexPath.section] as! ZMDEnterprise
        titleLbl.text = data.Name
//        mainLbl.text = data.main
        mainLbl.attributedText = mainLbl.text?.AttributedText("主营产品", color: defaultDetailTextColor)
        detailBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
            vc.enterpriseId = data.Id.integerValue
            self.pushToViewController(vc, animated: true, hideBottom: true)
            return RACSignal.empty()
        })
        if data.Products.count == 0 {
            scrollView.hidden = true
        }
        for i in 0..<data.Products.count {
            let product = data.Products[i]
            let view = UIView(frame: CGRect(x: 10+CGFloat(i)*(110+10), y: 0, width: 110, height: 150))
            let imgView = UIImageView(frame: CGRect(x: 0, y: 5, width: 110, height: 110))
            let lbl = ZMDTool.getLabel(CGRect(x: 0, y: 120, width: 110, height: 18), text: "", fontSize: 14, textColor: appThemeColor, textAlignment: .Left)
            imgView.sd_setImageWithURL(NSURL(string: kImageAddressMain+product.ImgUrl), placeholderImage: nil)
            lbl.text = product.Price
            view.addSubview(imgView)
            view.addSubview(lbl)
            scrollView.addSubview(view)
            scrollView.contentSize = CGSizeMake(CGFloat(data.Products.count*120), 0)
        }
        return cell!
    }
    func cellForBotCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "botCell"
        var  cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            
            let data = self.enterpriseArray[indexPath.section] as! ZMDEnterprise
            let btn = ZMDTool.getButton(CGRect(x: (kScreenWidth-82)/2, y: zoom(12), width: 82, height: zoom(32)), textForNormal: "进入店铺", fontSize: 15, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                let vc = StoreShowHomeViewController.CreateFromMainStoryboard() as! StoreShowHomeViewController
                vc.storeId = data.SotreId
                self.pushToViewController(vc, animated: true, hideBottom: true)
            })
            cell?.contentView.addSubview(btn)
        }
        return cell!
    }
    
    
    //MARK:- OverrideMethod
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
