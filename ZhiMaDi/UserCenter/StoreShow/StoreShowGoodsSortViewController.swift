//
//  StoreShowGoodsSortViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/20.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 商品分类
class StoreShowGoodsSortViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    var currentTableView: UITableView!
    
//    let dataArray = [["全部商品"],["租赁商品"],["床上用品","家具","日用品"]]
//    let dataArray = [["所有商品"],["农药","化肥","种子"]]
//    let dataArray2 = ["所有商品","农药","化肥","种子"]
//    let itemes = [["杀虫剂","杀虫剂","杀虫剂","杀虫剂","杀虫剂","杀虫剂杀虫剂"],["尿素","尿素","尿素","尿素","氯化铵","氯化钾"],["小麦种子","小麦种子","小麦种子","小麦种子","小麦种子","小麦种子"]]
    var categories = NSArray()          //从店铺页面传递过来的所有的分类
    var dataArray1 = NSMutableArray()  //大分类的数组
    var dataArray2 = NSMutableArray()  //小分类的二维数组
    var dataArray3 = NSMutableArray()   //大分类的Id
    
    var storeId : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.subViewInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else {
            return 2
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataArray1.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 16
        } else {
            return 1
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 56
        } else if indexPath.row == 0 {
            return 50
        } else {
            var x = CGFloat(12)
            var y = 40
            //item为[String]()
            let titles = self.dataArray2[indexPath.section - 1] as! [String]
            for item in titles {
                let sizeTmp = item.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                let xTmp = x + sizeTmp.width + 20
                if xTmp > kScreenWidth {
                    y += 40
                    x = 12 + sizeTmp.width + 20
                } else {
                    x = x + sizeTmp.width + 20
                }
            }
            return  CGFloat(y)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cellId = "allCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell?.selectionStyle = .None
                ZMDTool.configTableViewCellDefault(cell!)
            }
            cell?.textLabel?.text = "所有商品"
            return cell!
        } else {
            if indexPath.row == 0 {
                let cellId = "headCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    cell?.selectionStyle = .None

                    let btnTitle = self.dataArray1[indexPath.section] as? String
                    let size = btnTitle?.sizeWithFont(defaultTextSize, maxWidth: 200, lines: 1)
                    let leftBtn = UIButton(frame: CGRect(x: MarginLeft, y: 10, width: Int(size!.width)+20, height: 30))
                    leftBtn.backgroundColor = UIColor(red: 62/255, green: 182/255, blue: 35/255, alpha: 1.0)
                    leftBtn.setTitle(btnTitle, forState: .Normal)
                    leftBtn.titleLabel?.font = defaultTextSize
                    ZMDTool.configViewLayerWithSize(leftBtn, size: 15)
                    let rightBtn = UIButton(frame: CGRect(x: CGFloat(kScreenWidth) - 70, y: 10, width: 40, height: 30))
                    rightBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                        //点击 “农产品、农用物资”等通过 Cid 更新UI
                        let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                        vc.titleForFilter = self.dataArray1[indexPath.section] as! String
                        vc.As = "true"
                        vc.isStore = true
                        vc.storeId = self.storeId
                        vc.Cid = self.dataArray3[indexPath.section] as! String
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        return RACSignal.empty()
                    })
                    rightBtn.backgroundColor = UIColor.clearColor()
                    rightBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    rightBtn.setTitle("全部", forState: .Normal)
                    cell?.contentView.addSubview(leftBtn)
                    cell?.contentView.addSubview(rightBtn)
                }
                return cell!
            }
            
            let cellId = "btnsCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                cell?.selectionStyle = .None
                
                let getBtn = { (text : String,index : Int) -> UIButton in
                    let btn = UIButton(frame: CGRect.zero)
                    btn.setTitle(text, forState: .Normal)
                    btn.setTitleColor(defaultTextColor, forState: .Normal)
                    btn.titleLabel?.font = UIFont.systemFontOfSize(15)
                    btn.backgroundColor = UIColor.clearColor()
                    
                    btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                        //得到btn上的标题，通过标题进入对应的HomeBuyListViewController更新UI
                        let title = self.self.dataArray2[indexPath.section-1][index]//index = sender.tag
                        let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                        homeBuyListViewController.isStore = true
                        homeBuyListViewController.titleForFilter = title as! String
                        homeBuyListViewController.storeId = self.storeId
                        print(title)
                        self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
                    })
                    return btn
                }
                var x = CGFloat(12)
                var y = 7
                var index = 0
                //items为[String]()
                let titles = self.dataArray2[indexPath.section-1] as! [String]
                for item in titles {
                    let sizeTmp = item.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                    //xTmp用于判断当前btn是否跑出屏幕外
                    let xTmp = x + sizeTmp.width + 20   //sizeTmp.width为btn.width
                    let btn = getBtn(item,index)
                    btn.tag = index++
                    if xTmp < kScreenWidth {
                        btn.frame = CGRectMake(x, CGFloat(y),sizeTmp.width + 20, 26)
                        cell?.contentView.addSubview(btn)
                        x = x + sizeTmp.width + 20
                    } else {
                        y += 30
                        x = 12 + sizeTmp.width + 20
                        btn.frame = CGRectMake(12, CGFloat(y),sizeTmp.width + 20, 26)
                        cell?.contentView.addSubview(btn)
                    }
                    //当btn加到cell.contentView上后，根据btn来加上分割线
                    let lineLbl = UILabel(frame: CGRect(x: btn.frame.width-1, y: (btn.frame.height-15)/2, width: 1, height: 15))
                    lineLbl.backgroundColor = defaultLineColor
                    btn.addSubview(lineLbl)
                }
            }
            //分割线
//            let line = ZMDTool.getLine(CGRect(x: 0, y: cell!.frame.height-1, width: kScreenWidth, height: 1), backgroundColor: defaultLineColor)
//            cell?.contentView.addSubview(line)
            return cell!
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
            homeBuyListViewController.isStore = true
            homeBuyListViewController.titleForFilter = ""
            homeBuyListViewController.storeId = self.storeId
            self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
        }
    }
    
    //MARK: dataINit()
    func dataInit() {
        var text = ""
        for item in self.categories {
            let storeCategory = item as! ZMDStoreCategory
            let array = storeCategory.Text.componentsSeparatedByString(" >")
            if text != array[0]{
                self.dataArray1.addObject(array[0])
                self.dataArray3.addObject(storeCategory.Value)
                self.dataArray2.addObject(NSMutableArray())
                text = array[0]
            }
        }
        for item in self.categories {
            let category = item as! ZMDStoreCategory
            let array = category.Text.componentsSeparatedByString(" >")
            var count = 0
            for str in self.dataArray1 {
                if str as! String == array[0] && array.count != 0 {
                    (self.dataArray2[count] as! NSMutableArray).addObject(array.last!)
                    break
                }
                count++
            }
        }
        self.dataArray2.removeObjectAtIndex(0)
    }
    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.title = "商品分类"
        self.currentTableView = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-64), style: .Plain)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
    
    //MARK: gotoMore
    override func gotoMore() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
