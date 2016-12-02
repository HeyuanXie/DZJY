
//
//  LeaseContractView.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
private let leasePackageV = NSBundle.mainBundle().loadNibNamed("LeasePackageView", owner: nil, options: nil).first as! LeasePackageView

protocol LeasePackageViewDelegate :NSObjectProtocol {
    func removeBackgroundBtn()
}

class LeasePackageView: UIView,UITableViewDataSource,UITableViewDelegate {
    enum GoodsCellType{
        case HomeContentTypeImgV                        /* 广告显示页 */
        case HomeContentTypePackage                     /* 套餐栏目 */
        case HomeContentTypeTerm                        /* 租期栏目 */
        case HomeContentTypeCount                       /* 数量  */
        case HomeContentTypeDetail                      /* 详细 */
        case HomeContentTypeConfirm                     /* 租赁 */
        init(){
            self = HomeContentTypeImgV
        }
    }
    //MARK:回调block，传递租赁套餐详情
    var finished : ((package:String, term:String, count:Int)->Void)!
    
    var pageageBtnSelect : UIButton!
    var termBtnSelected : UIButton!
    var countForBounghtLbl : UIButton!
    
    var cellTypes: [GoodsCellType]!
    var countForBounght = 0                         // 购买数量
    
    var delegate :LeasePackageViewDelegate!
    //xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataInit()
    }
    override func drawRect(rect: CGRect) {
        UpdateUI()
    }
    class func leasePackageView() -> LeasePackageView{
        return leasePackageV
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellTypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeImgV :
            return 120
        case .HomeContentTypePackage :
            return 137
        case .HomeContentTypeTerm :
            return 137
        case .HomeContentTypeCount :
            return 92
        case .HomeContentTypeDetail :
            return 120
        case .HomeContentTypeConfirm :
            return 120
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = self.cellTypes[indexPath.section]
        switch cellType {
        case .HomeContentTypeImgV :
            return cellForImgV(tableView, indexPath: indexPath)
        case .HomeContentTypePackage :
            return cellForPackage(tableView, indexPath: indexPath)
        case .HomeContentTypeTerm :
            return cellForTerm(tableView, indexPath: indexPath)
        case .HomeContentTypeCount :
            return cellForCount(tableView, indexPath: indexPath)
        case .HomeContentTypeDetail :
            return cellForDetail(tableView, indexPath: indexPath)
        case .HomeContentTypeConfirm :
            return cellForConfirm(tableView, indexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    //MARK: -  PrivateMethod
    //MARK: 广告 cell
    func cellForImgV(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ImgVCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
        }
        let imgV = UIImageView(frame: CGRect(x: 14, y: 28, width: 80, height: 80))
        imgV.image = UIImage(named: "product_pic")
        cell?.contentView.addSubview(imgV)
        return cell!
    }
    func cellForPackage(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "PackageCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let titleLbl = ZMDTool.getLabel(CGRect(x: 0, y: 28, width: 80, height: 35), text: "套餐", fontSize: 15, textColor: defaultTextColor)
            titleLbl.textAlignment = .Center
            cell?.contentView.addSubview(titleLbl)
            
            let filetTitle = ["套餐A","套餐B","套餐C"]
            var i = 0
            for title in filetTitle {
                let width : CGFloat = 65,height : CGFloat = 35
                let Tmp = i%2 , Tmp2 = i/2
                let x = 86 + CGFloat(Tmp) * width + CGFloat(Tmp) * 20
                let y = 28 + CGFloat(Tmp2) * (height + 18)
                
                let btn = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
                btn.tag = 1000 + NSInteger(i)
                btn.titleLabel!.font = defaultSysFontWithSize(15)
                btn.setTitle(title, forState: .Normal)
                btn.setTitle(title, forState: .Selected)
                btn.setTitleColor(defaultTextColor, forState: .Normal)
                btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
                ZMDTool.configViewLayer(btn)
                ZMDTool.configViewLayerFrame(btn)
                cell?.contentView.addSubview(btn)
                
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    self.pageageBtnSelect.selected = false
                    ZMDTool.configViewLayerFrameWithColor(self.pageageBtnSelect, color: defaultTextColor)
                    self.pageageBtnSelect = sender as! UIButton
                    self.pageageBtnSelect.selected = true
                    ZMDTool.configViewLayerFrameWithColor(self.pageageBtnSelect, color:RGB(235,61,61,1.0))
                })
                if i == 0 {
                    btn.selected = true
                    self.pageageBtnSelect = btn
                    ZMDTool.configViewLayerFrameWithColor(btn, color:RGB(235,61,61,1.0))
                }
                i++
            }
        }
        
        return cell!
    }
    func cellForTerm(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "TermCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let titleLbl = ZMDTool.getLabel(CGRect(x: 0, y: 28, width: 80, height: 35), text: "租期", fontSize: 15, textColor: defaultTextColor)
            titleLbl.textAlignment = .Center
            cell?.contentView.addSubview(titleLbl)
            
            let filetTitle = ["半年","一年","一年半","两年"]
            var i = 0
            for title in filetTitle {
                let width : CGFloat = 65,height : CGFloat = 35
                let Tmp = i%2 , Tmp2 = i/2
                let x = 86 + CGFloat(Tmp) * width + CGFloat(Tmp) * 20
                let y = 28 + CGFloat(Tmp2) * (height + 18)
                
                let btn = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
                btn.tag = 1000 + NSInteger(i)
                btn.titleLabel!.font = defaultSysFontWithSize(15)
                btn.setTitle(title, forState: .Normal)
                btn.setTitle(title, forState: .Selected)
                btn.setTitleColor(defaultTextColor, forState: .Normal)
                btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
                ZMDTool.configViewLayer(btn)
                ZMDTool.configViewLayerFrame(btn)
                cell?.contentView.addSubview(btn)
                
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    self.termBtnSelected.selected = false
                    ZMDTool.configViewLayerFrameWithColor(self.termBtnSelected, color: defaultTextColor)
                    self.termBtnSelected = sender as! UIButton
                    self.termBtnSelected.selected = true
                    ZMDTool.configViewLayerFrameWithColor(self.termBtnSelected, color:RGB(235,61,61,1.0))
                })
                if i == 0 {
                    btn.selected = true
                    self.termBtnSelected = btn
                    ZMDTool.configViewLayerFrameWithColor(btn, color:RGB(235,61,61,1.0))
                }
                i++
            }
        }
        return cell!
    }
    func cellForCount(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "CountCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let titleLbl = UILabel(frame: CGRect(x: 18, y: 22, width: 120, height: 16))
            titleLbl.text = "购买数量："
            titleLbl.textColor = defaultTextColor
            titleLbl.font = defaultSysFontWithSize(16)
            cell?.contentView.addSubview(titleLbl)
            let countLbl = ZMDTool.getLabel(CGRect(x: 18, y: 22 + 16 + 8, width: 120, height: 15), text: "(库存量: 15)", fontSize: 15,textColor:defaultDetailTextColor)
            cell?.contentView.addSubview(countLbl)
            
            let viewBg = UIView(frame: CGRect(x: self.bounds.size.width - 12 - 120, y: 22, width: 120, height: 40))
            ZMDTool.configViewLayerFrame(viewBg)
            cell?.contentView.addSubview(viewBg)
            var titles = ["-","0","+"],i=0
            for title in titles {
                let btn = UIButton(frame: CGRect(x: 40*i, y: 0, width: 40, height: 40))
                if title == "0" {
                    self.countForBounghtLbl = btn
                }
                btn.titleLabel?.font = defaultSysFontWithSize(15)
                btn.setTitle(title, forState: .Normal)
                btn.setTitleColor(defaultTextColor, forState: .Normal)
                btn.tag = 1000+i
                viewBg.addSubview(btn)
                btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                    if (btn.tag - 1000) == 0 && self.countForBounght != 0 {
                        self.countForBounght--
                    } else if (btn.tag - 1000) == 2 {
                        self.countForBounght++
                    }
                    self.countForBounghtLbl.setTitle("\(self.countForBounght)", forState: .Normal)
                })
                i++
            }
        }
       
        return cell!
    }
    func cellForDetail(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "DetailCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let rentPriceText = "￥218"
            let rentText = "租金:\(rentPriceText)"
            let rentLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12, width: 120, height: 15), text: "", fontSize: 15,textColor:defaultTextColor)
            rentLbl.attributedText = rentText.AttributedText(rentPriceText, color: RGB(235,61,61,1.0))
            cell?.contentView.addSubview(rentLbl)
            
            let depositLbl = ZMDTool.getLabel(CGRect(x: self.bounds.width/2, y: 12, width: self.bounds.width/2 - 12, height: 15), text: "", fontSize: 15,textColor:defaultTextColor)
            let depositLblPriceText = "￥100"
            let depositLblText = "押金:\(depositLblPriceText)"
            depositLbl.attributedText = depositLblText.AttributedText(depositLblPriceText, color: RGB(235,61,61,1.0))
            cell?.contentView.addSubview(depositLbl)

            let shuomingLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12 + 15 + 10, width: self.bounds.width - 24, height: 12), text: "(可添加费用计算说明)", fontSize: 12,textColor:defaultDetailTextColor)
            cell?.contentView.addSubview(shuomingLbl)
            
            let lastLbl = ZMDTool.getLabel(CGRect(x: 12, y: 12 + 15 + 10 + 20, width: self.bounds.width - 24, height: 15), text: "", fontSize: 15,textColor:defaultTextColor)
            let freightLblPriceText = "(含运费:￥0.0)"  //运费
            let totalPriceText = "￥318.0"
            let lastText = "\(freightLblPriceText)合计费用:\(totalPriceText)"
            lastLbl.attributedText = freightLblPriceText.AttributeText([freightLblPriceText], textSizes: [13])
            lastLbl.attributedText = lastText.AttributedMutableText([freightLblPriceText,"合计费用:",totalPriceText], colors: [defaultDetailTextColor,defaultTextColor,RGB(235,61,61,1.0)])
            //label的size根据label.text来自适应
            let sizetmp = lastText.sizeWithFont(defaultSysFontWithSize(15), maxWidth: 300)
            lastLbl.frame = CGRect(x: 12, y: 12 + 15 + 10 + 20, width: sizetmp.width, height: 15)
            cell?.contentView.addSubview(lastLbl)
        }
        
        return cell!
    }
    
    func cellForConfirm(tableView: UITableView,indexPath: NSIndexPath)-> UITableViewCell {
        let cellId = "ConfirmCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell!.selectionStyle = .None
            cell!.contentView.backgroundColor = UIColor.whiteColor()
            
            let btn = ZMDTool.getButton(CGRect(x: self.bounds.width/2 - 55, y: 12, width: 110, height: 65 - 24), textForNormal: "确定"/*"立即租赁"*/, fontSize: 15, backgroundColor:  RGB(235,61,61,1.0),blockForCli : {(sender) -> Void in
                self.finished(package: (self.pageageBtnSelect.titleLabel?.text)!,term: (self.termBtnSelected.titleLabel?.text)!,count: self.countForBounght)
                self.removeFromSuperview()
                self.delegate.removeBackgroundBtn()
            })
            ZMDTool.configViewLayerWithSize(btn, size: 15)
            cell?.contentView.addSubview(btn)
        }
        //UIButton(frame: CGRect(x: 0, y: 0, width: 110, height: 65 - 24))
//        btn.backgroundColor = RGB(235,61,61,1.0)
//        btn.setTitle("立即租赁", forState: .Normal)
//        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        btn.titleLabel!.font = defaultSysFontWithSize(15)
//        btn.rac_signalForControlEvents(.TouchCancel).subscribeNext { (sender) -> Void in
//            
//        }
        
        return cell!
    }
    
    func UpdateUI() {
        
    }
    private func dataInit(){
        self.cellTypes = [.HomeContentTypeImgV,.HomeContentTypePackage,.HomeContentTypeTerm,.HomeContentTypeCount,.HomeContentTypeDetail, .HomeContentTypeConfirm]
    }
}
