//
//  HomeBuyGoodsSearchUIViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/2/26.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import FMDB
import MJRefresh
// 商品搜索
class HomeBuyGoodsSearchViewController: UIViewController, ZMDInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate,ZMDInterceptorKeyboardProtocol{
    
    @IBOutlet weak var currentTableView: UITableView!
    
    let kServerAddress = "http://www.xjnongte.com"
    
    let goodses  = ["杀虫剂","钾肥","氯化钾","棉花种子","除草剂"]
    let storeses = ["葫芦宝","宝葫芦","江南Style","SONY","APPLE","Mi"]
    var goodsHistory = NSMutableArray()
    var storesHistory = NSMutableArray()
    let goodsData = ["",""]
    
    var storeArray = NSMutableArray(array: ["",""])
    var productArray = NSMutableArray()
    
    var isStore = false     //切换商品和店铺，默认为商品
    var IndexFilter = 0
    var orderby = 16
    var orderBy : Int?
    var indexSkip = 0
    var orderbySaleUp = true    //默认都是升序
    var orderbyPopularUp = true
    
    var textInput : UITextField!
    
    enum TableViewType {
        case GoodWithNoRecommend
        case GoodWithRecommend
        case StoreWithNoRecommend
        case StoreWithRecommend
    }
    var tableViewType = TableViewType.GoodWithNoRecommend
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataInit()
        self.fetchData()
        self.initUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //搜索跳转到另一个页面返回时，将搜索历史更新
        self.dataInit()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isStore {
            return 2
        }else{
            switch self.tableViewType {
            case .GoodWithNoRecommend :
                return 2
            case .GoodWithRecommend :
                return 4
            case .StoreWithNoRecommend :
                return 2
            case .StoreWithRecommend :
                return 4
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.isStore ? self.storesHistory.count + 1 : self.goodsHistory.count + 1
        }else if section == 3 {
            return self.isStore ? self.storeArray.count : self.productArray.count/2 + self.productArray.count%2   //为你推荐
        }else if section == 0 {
            return 0
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0 :
            return 0
        case 1 :
            return 10
        case 2 :
            return 0
        case 3 :
            return 0
        default :
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 10))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            var size = "热搜 ：".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
            var x = 14 + size.width
            var y = 50
            let space = CGFloat(12)
            for goods in goodses {
                let sizeTmp = goods.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                let xTmp = x + space + sizeTmp.width + 20 + 12
                if xTmp > kScreenWidth {
                    y += 38
                    x = 14 + sizeTmp.width + 20
                } else {
                    x = x + space + sizeTmp.width + 20
                }
            }
            
            size = "热搜 ：".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
            x = 14 + size.width
            var y2 = 50
            for store in storeses {
                let sizeTmp = store.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
                let xTmp = x + space + sizeTmp.width + 20 + 12
                if xTmp > kScreenWidth {
                    y2 += 38
                    x = 14 + sizeTmp.width + 20
                }else{
                    x = x + space + sizeTmp.width + 20
                }
            }
            return  self.isStore ? CGFloat(y2) : CGFloat(y)
        } else if indexPath.section == 1 {
            return  55
        } else if indexPath.section == 2 {
                return  80  //为你推荐
        } else if indexPath.section == 3 {
            return (kScreenWidth/2-12*2)*2      //kScreenWidth/2-12*2 为imgView的宽高
        }
    return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.isStore {
            switch indexPath.section {
            case 0 ://热搜
                let cellId = "storesHotCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                //热搜sectioncell：一个“热搜”label 和 其他 气泡button
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let label = UILabel(frame: CGRectMake(14, 18,100, 15))
                    label.text = "热搜 ："
                    label.textColor = UIColor.blackColor()
                    label.font = UIFont.systemFontOfSize(15)
                    cell?.contentView.addSubview(label)
                    
                    let size = "热搜 ：".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
                    //定义一个生成btn的block
                    let getBtn = { (text : String,index : Int) -> UIButton in
                        let btn = UIButton(frame: CGRect.zero)
                        btn.setTitle(text, forState: .Normal)
                        btn.setTitleColor(defaultTextColor, forState: .Normal)
                        btn.titleLabel?.font = UIFont.systemFontOfSize(17)
                        btn.layer.borderColor = UIColor.grayColor().CGColor;
                        btn.layer.borderWidth = 0.5
                        btn.layer.cornerRadius = 10
                        btn.layer.masksToBounds = true
                        btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                            //得到btn上的标题，通过标题进入对应的StoreListViewController更新UI
                            let vc = StoreShowListViewController.CreateFromMainStoryboard() as! StoreShowListViewController
                            vc.titleForFilter = self.storeses[index]
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        return btn
                    }
                    var x = 14 + size.width
                    var y = 12
                    let space = CGFloat(12)
                    var index = 0
                    for store in storeses {
                        let sizeTmp = store.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                        let xTmp = x + space + sizeTmp.width + 20  + 12
                        let btn = getBtn(store,index)
                        btn.tag = index++
                        if xTmp < kScreenWidth {
                            btn.frame = CGRectMake(x + space , CGFloat(y),sizeTmp.width + 20, 26)
                            cell?.contentView.addSubview(btn)
                            x = x + space + sizeTmp.width + 20
                        } else {
                            y += 38
                            x = 14 + sizeTmp.width + 20
                            btn.frame = CGRectMake(14, CGFloat(y),sizeTmp.width + 20, 26)
                            cell?.contentView.addSubview(btn)
                        }
                    }
                }
                return cell!
            case 1 :
                //搜索历史
                //indexPath.row == self.goodsHistory.count,即为最后一个cell：cleanCell
                if indexPath.row == self.storesHistory.count {
                    let cellId = "cleanCell"
                    var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                    if cell == nil {
                        cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                        cell?.accessoryType = UITableViewCellAccessoryType.None
                        cell!.selectionStyle = .None
                        
                        ZMDTool.configTableViewCellDefault(cell!)
                        let title = "清除搜索记录"
                        let size = title.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: kScreenWidth)
                        let label = UILabel(frame: CGRectMake(kScreenWidth/2-size.width/2,0,size.width, 55))
                        label.text = title
                        label.textAlignment = .Center
                        
                        label.textColor = defaultDetailTextColor
                        label.font = UIFont.systemFontOfSize(14)
                        cell?.contentView.addSubview(label)
                        
                        let imgV = UIImageView(frame: CGRect(x: label.frame.origin.x - 29, y: 18, width: 19, height: 19))
                        imgV.image = UIImage(named: "GoodsSearch_Trash")
                        cell?.contentView.addSubview(imgV)
                    }
                    return cell!
                }
                //其他的都是搜索历史Cell：historyCell
                let cellId = "historyCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let btn = UIButton(frame: CGRectMake(kScreenWidth-26, 20, 14, 14))
                    btn.backgroundColor = UIColor.clearColor()
                    btn.setImage(UIImage(named: "GoodsSearch_close"), forState: .Normal)
                    btn.tag = indexPath.row
                    //商品
                    btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                        //点击btn删除当前条搜索历史在dataBase中对应的数据
                        if self.isStore {
                            self.deleteValueFromDB(self.createOrOpenDB(), text: (self.storesHistory)[(sender as!UIButton).tag] as! String)
                        }else{
                            self.deleteValueFromDB(self.createOrOpenDB(), text: (self.goodsHistory[(sender as!UIButton).tag]) as! String)
                        }
                        //删除数据后，更新搜索历史
                        self.dataInit()
                    })
                    
                    cell?.contentView.addSubview(btn)
                    
                    let line = UIImageView(frame: CGRect(x: 0, y: 54, width: kScreenWidth, height: 0.5))
                    line.backgroundColor = defaultLineColor
                    cell?.contentView.addSubview(line)
                }
                
                cell?.textLabel!.text = self.storesHistory[indexPath.row] as? String
                cell?.textLabel?.textColor = defaultDetailTextColor
                cell?.textLabel?.font = UIFont.systemFontOfSize(16)
                return cell!
            case 2 :
                //为你推荐
                let cellId = "doubleHeadCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                }
                return cell!
            case 3 :
                //
                let cellId = "doubleGoodsCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DoubleGoodsTableViewCell
                cell.goodsImgVLeft.image = UIImage(named: "home_banner02")
                cell.selectionStyle = .None
                return cell
            default :
                return UITableViewCell()
            }
        }
        else {
            //商品
            switch indexPath.section {
            case 0 ://热搜
                let cellId = "goodsHotCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                //热搜sectioncell：一个“热搜”label 和 其他 气泡button
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let label = UILabel(frame: CGRectMake(14, 18,100, 15))
                    label.text = "热搜 ："
                    label.textColor = UIColor.blackColor()
                    label.font = UIFont.systemFontOfSize(15)
                    cell?.contentView.addSubview(label)
                    
                    let size = "热搜 ：".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100)
                    let getBtn = { (text : String,index : Int) -> UIButton in
                        let btn = UIButton(frame: CGRect.zero)
                        btn.setTitle(text, forState: .Normal)
                        btn.setTitleColor(defaultTextColor, forState: .Normal)
                        btn.titleLabel?.font = UIFont.systemFontOfSize(17)
                        btn.layer.borderColor = UIColor.grayColor().CGColor;
                        btn.layer.borderWidth = 0.5
                        btn.layer.cornerRadius = 10
                        btn.layer.masksToBounds = true
                        btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                            //得到btn上的标题，通过标题进入对应的HomeBuyListViewController更新UI
                            let goods = self.goodses[index]
                            // save
                            let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                            homeBuyListViewController.titleForFilter = goods
                            homeBuyListViewController.hideSearch = true
                            self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
                        })
                        return btn
                    }
                    var x = 14 + size.width
                    var y = 12
                    let space = CGFloat(12)
                    var index = 0
                    for goods in goodses {
                        let sizeTmp = goods.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
                        let xTmp = x + space + sizeTmp.width + 20  + 12
                        let btn = getBtn(goods,index)
                        btn.tag = index++
                        if xTmp < kScreenWidth {
                            btn.frame = CGRectMake(x + space , CGFloat(y),sizeTmp.width + 20, 26)
                            cell?.contentView.addSubview(btn)
                            x = x + space + sizeTmp.width + 20
                        } else {
                            y += 38
                            x = 14 + sizeTmp.width + 20
                            btn.frame = CGRectMake(14, CGFloat(y),sizeTmp.width + 20, 26)
                            cell?.contentView.addSubview(btn)
                        }
                    }
                }
                return cell!
            case 1 :
                //搜索历史
                //indexPath.row == self.goodsHistory.count,即为最后一个cell：cleanCell
                if indexPath.row == self.goodsHistory.count {
                    let cellId = "cleanCell"
                    var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                    if cell == nil {
                        cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                        cell?.accessoryType = UITableViewCellAccessoryType.None
                        cell!.selectionStyle = .None
                        
                        ZMDTool.configTableViewCellDefault(cell!)
                        let title = "清除搜索记录"
                        let size = title.sizeWithFont(UIFont.systemFontOfSize(14), maxWidth: kScreenWidth)
                        let label = UILabel(frame: CGRectMake(kScreenWidth/2-size.width/2,0,size.width, 55))
                        label.text = title
                        label.textAlignment = .Center
                        
                        label.textColor = defaultDetailTextColor
                        label.font = UIFont.systemFontOfSize(14)
                        cell?.contentView.addSubview(label)
                        
                        let imgV = UIImageView(frame: CGRect(x: label.frame.origin.x - 29, y: 18, width: 19, height: 19))
                        imgV.image = UIImage(named: "GoodsSearch_Trash")
                        cell?.contentView.addSubview(imgV)
                    }
                    return cell!
                }
                //其他的都是搜索历史Cell：historyCell 商品
                let cellId = "historyCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                    
                    let btn = UIButton(frame: CGRectMake(kScreenWidth-26, 20, 14, 14))
                    btn.backgroundColor = UIColor.clearColor()
                    btn.setImage(UIImage(named: "GoodsSearch_close"), forState: .Normal)
                    btn.tag = indexPath.row
                    //商品
                    btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                        //点击btn删除当前条搜索历史在dataBase中对应的数据
                        if self.isStore {
                            self.deleteValueFromDB(self.createOrOpenDB(), text: (self.storesHistory)[(sender as!UIButton).tag] as! String)
                        }else{
                            self.deleteValueFromDB(self.createOrOpenDB(), text: (self.goodsHistory[(sender as!UIButton).tag]) as! String)
                        }
                        //删除数据后，更新搜索历史
                        self.dataInit()
                    })
                    
                    cell?.contentView.addSubview(btn)
                    
                    let line = UIImageView(frame: CGRect(x: 0, y: 54, width: kScreenWidth, height: 0.5))
                    line.backgroundColor = defaultLineColor
                    cell?.contentView.addSubview(line)
                }
                cell?.textLabel!.text = self.goodsHistory[indexPath.row] as? String
                cell?.textLabel?.textColor = defaultDetailTextColor
                cell?.textLabel?.font = UIFont.systemFontOfSize(16)
                return cell!
            case 2 :
                //为你推荐
                let cellId = "doubleHeadCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    cell!.selectionStyle = .None
                    
                    ZMDTool.configTableViewCellDefault(cell!)
                }
                return cell!
            case 3 :
                //
                if !self.isStore {
                    let cellId = "doubleGoodsCell"
                    let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as! DoubleGoodsTableViewCell
                    let productL = self.productArray[indexPath.row*2] as!ZMDProduct
                    let productR = self.productArray[indexPath.row*2+1] as!ZMDProduct
                    DoubleGoodsTableViewCell.configCell(cell, product: productL, productR: productR)
                    cell.selectionStyle = .None
                    
                    return cell
                }
                let cellId = "storeCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
                    var tag = 1000
                    let imgView = UIImageView(frame: CGRect(x: 12, y: 12, width: 60, height: 60))
                    ZMDTool.configViewLayerRound(imgView)
                    imgView.tag = tag++
                    let nameLbl = UILabel(frame: CGRect(x: 12+60+12, y: 12, width: kScreenWidth-(12+60+12)*2, height: 20))
                    nameLbl.textAlignment = .Left
                    nameLbl.tag = tag++
                    let mainLbl = UILabel(frame: CGRect(x: 12+60+12, y: 12+20+12, width: kScreenWidth-(12+60+12)*2, height: 20))
                    mainLbl.textAlignment = .Left
                    mainLbl.tag = tag++
                    let btn = UIButton(frame: CGRect(x: kScreenWidth-12-60, y: (cell!.bounds.height-40)/2, width: 60, height: 40))
                    ZMDTool.configViewLayerFrameWithColor(btn, color: defaultLineColor)
                    btn.backgroundColor = UIColor.clearColor()
                    btn.setTitle("进入店铺", forState: .Normal)
                    btn.setTitleColor(defaultDetailTextColor, forState: .Normal)
                    btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
                        print("进入店铺")
                        return RACSignal.empty()
                    })
                    btn.tag = tag++
                    cell?.contentView.addSubview(imgView)
                    cell?.contentView.addSubview(nameLbl)
                    cell?.contentView.addSubview(mainLbl)
                    cell?.contentView.addSubview(btn)
                }
                let store = self.storeArray[indexPath.row] as!ZMDStoreDetail
                var tag =  1000
                (cell?.contentView.viewWithTag(tag++) as!UIImageView).sd_setImageWithURL(NSURL(string: kServerAddress + store.PictureUrl), placeholderImage: nil)   //image = UIImage(named: "")
                (cell?.contentView.viewWithTag(tag++) as!UILabel).text = store.Name // "葫芦堡"
                (cell?.contentView.viewWithTag(tag++) as!UILabel).text = store.Host //"主营:..."
                return cell!
                
            default :
                return UITableViewCell()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.isStore {
            switch indexPath.section {
            case 0:
                return
            case 1:
                if indexPath.row == self.storesHistory.count {
                    let dataBase = self.createOrOpenDB()
                    dataBase.executeUpdate("DELETE FROM StoresHistory", withArgumentsInArray: nil)
                    self.dataInit()
                }else{
                    let text = self.storesHistory[indexPath.row] as! String
                    let searchView = self.navigationItem.titleView
                    let textInput = searchView?.viewWithTag(100) as!UITextField
                    textInput.text = text
                    let vc = StoreShowListViewController.CreateFromMainStoryboard() as! StoreShowListViewController
                    vc.titleForFilter = textInput.text!
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                return
            case 2:
                return
            case 3:
                return
            default :
                return
            }
        }else{
            switch indexPath.section {
            case 0 : //热搜
                return  //无操作
            case 1 :
                //点击"清除搜索记录"cell，删除所有记录
                if indexPath.row == self.goodsHistory.count {
                    let dataBase = self.createOrOpenDB()
                    dataBase.executeUpdate("DELETE FROM GoodsHistory", withArgumentsInArray: nil)
                    self.dataInit()
                }else{
                    //点击其他cell，将cell.label.text返回给searchBar.text
                    let text = self.goodsHistory[indexPath.row] as! String
                    let searchView = self.navigationItem.titleView
                    let textInput = searchView?.viewWithTag(100) as! UITextField
                    textInput.text = text
                    let homeBuyListViewController = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
                    homeBuyListViewController.titleForFilter = text
                    homeBuyListViewController.hideSearch = true
                    homeBuyListViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(homeBuyListViewController, animated: true)
                }
                return
            case 2 :
                return  //无操作
            case 3 :
                //进入商品详情页
                return
            default:
                break
            }
        }
    }
    
    
    //MARK: - UITextFiledDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text != "" {
            
            self.view.viewWithTag(100)?.removeFromSuperview()
            insertValueToDB(createOrOpenDB(), text: textField.text!)
            self.dataInit()
            
            if self.isStore {
                let vc = StoreShowListViewController.CreateFromMainStoryboard() as! StoreShowListViewController
                vc.titleForFilter = textField.text!
                self.navigationController?.pushViewController(vc, animated: false)
            }else{
                let vc = HomeBuyListViewController.CreateFromMainStoryboard() as!HomeBuyListViewController
                vc.titleForFilter = textField.text!
//                vc.isStore = true
                vc.hideSearch = true
                vc.storeId = 0
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        btn.tag = 100
        self.view.addSubview(btn)
        btn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //移除灰色背景btn
            btn.removeFromSuperview()
            textField.resignFirstResponder()
            return RACSignal.empty()
        })
    }
    
    //MARK: -  PrivateMethod
    func setupNewNavigation() {

        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth-120, height: 44))
        self.textInput = UITextField(frame: CGRect(x: 60, y: 4, width: kScreenWidth - 120 - 60, height: 36))
        self.textInput.tag = 100
        textInput.placeholder = "  商品关键字"
        textInput.backgroundColor = defaultBackgroundColor
        
        let leftViewBtn = UIButton(frame: CGRect(x: 0, y: 4, width: 60, height: 36))
        leftViewBtn.backgroundColor = UIColor.lightGrayColor()
        leftViewBtn.setImage(UIImage(named: "storeList_down"), forState: .Normal)
        leftViewBtn.setTitle("商品", forState: .Normal)
        leftViewBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        leftViewBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 36, bottom: 0, right: -36)
        leftViewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 12)
        leftViewBtn.alpha = 0.4
        searchView.addSubview(leftViewBtn)
        
        leftViewBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as!UIButton).selected = !(sender as!UIButton).selected
            self.view.endEditing(true)
            //点击切换商品与店铺时，更新搜索历史数组中的数据
            self.dataInit()
            //移除灰色背景
            if let view = self.view.viewWithTag(100) {
                view.removeFromSuperview()
            }
            self.textInput.resignFirstResponder()
            self.isStore = (sender as!UIButton).selected == true ? true : false
            let title = self.isStore ? "店铺" : "商品"
            self.textInput.placeholder = self.isStore ? "  店铺关键字" : "  商品关键字"
            leftViewBtn.setTitle(title, forState: .Normal)
//            self.tableViewType = self.isStore ? .StoreWithNoRecommend : .GoodWithRecommend
            self.dataInit()
            return RACSignal.empty()
        })
        
        textInput.delegate = self
        searchView.addSubview(textInput)
        self.navigationItem.titleView = searchView

        let rightItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        rightItem.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            self.navigationController?.popViewControllerAnimated(true)
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func dataInit() {
        self.queryValueToDB(self.createOrOpenDB())
    }
    
    func initUI() {
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.setupNewNavigation()
    }
    
    func createOrOpenDB() -> FMDatabase {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("Zmd.sqlite")
        let database = FMDatabase(path: fileURL.path)
        if !database.open() {
            print("Unable to open database")
            return database
        }
        do {
            let tableName = self.isStore ? "StoresHistory" : "GoodsHistory"
            let title = self.isStore ? "storesTitle" : "goodsTitle"
            try database.executeUpdate("create table if not exists \(tableName)(id integer PRIMARY KEY AUTOINCREMENT,\(title) text)", values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        return database
    }
    func insertValueToDB(database:FMDatabase,text:String) {
        if self.isStore {
            for tmp in self.storesHistory {
                if tmp as? String == text {
                    return
                }
            }
            do {
                try database.executeUpdate("insert into StoresHistory (storesTitle) values (?)", values: [text])
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }

        }else{
            for tmp in self.goodsHistory {
                if tmp as? String == text {
                    return
                }
            }
            do {
                try database.executeUpdate("insert into GoodsHistory (goodsTitle) values (?)", values: [text])
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
        }
        database.close()
    }
    func deleteValueFromDB(database:FMDatabase,text:String) {
        let tableName = self.isStore ? "StoresHistory" : "GoodsHistory"
        let title = self.isStore ? "storesTitle" : "goodsTitle"
        do {
            try database.executeUpdate("delete from \(tableName) where (\(title)) = (?)",values: [text])
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    //从dataBase中请求数据
    func queryValueToDB(database:FMDatabase) {
        if self.isStore {
            do {
                let rs = try database.executeQuery("select storesTitle from StoresHistory", values: nil)
                self.storesHistory.removeAllObjects()
                while rs.next() {
                    let storesTitle = rs.stringForColumn("storesTitle")
                    self.storesHistory.addObject(storesTitle)
                }
                self.currentTableView.reloadData()
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
        }else{
            do {
                let rs = try database.executeQuery("select goodsTitle from GoodsHistory", values: nil)
                self.goodsHistory.removeAllObjects()
                while rs.next() {
                    let goodsTitle = rs.stringForColumn("goodsTitle")
                    self.goodsHistory.addObject(goodsTitle)
                }
                self.currentTableView.reloadData()
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
        }
        database.close()
    }
    
    //MARK: updateData
//    func updateData(orderBy:Int?) {
//        
//    }
    
    //MARK: fetchData
    func fetchData() {
        self.productArray.removeAllObjects()
        self.storeArray.removeAllObjects()
        QNNetworkTool.products("床", pagenumber: "\(3)", orderby: 0, Cid: nil) { (products, error, dictionary) -> Void in
            if let productArr = products {
//                for var i=0;i<4;i++ {
//                    self.productArray.addObject(productArr[i])
//                }
                self.productArray.addObjectsFromArray(productArr as [AnyObject])
            }
            if self.isStore {
                self.tableViewType = self.storeArray.count == 0 ? TableViewType.StoreWithNoRecommend : .StoreWithRecommend
            }else{
                self.tableViewType = self.productArray.count == 0 ? TableViewType.GoodWithNoRecommend : .GoodWithRecommend
            }
            self.currentTableView.reloadData()
        }

        /*
        QNNetworkTool.fetchStoreList(12, pageNumber: 3, orderBy: 0, Q: "宝") { (storeArray, error, dictionary) -> Void in
            if let storeArr = storeArray {
                for var i=0;i<4;i++ {
                    self.storeArray.addObject(storeArr[i])
                }
            }
            if self.isStore {
                self.tableViewType = self.storeArray.count == 0 ? TableViewType.StoreWithNoRecommend : .StoreWithRecommend
            }else{
                self.tableViewType = self.productArray.count == 0 ? TableViewType.GoodWithNoRecommend : .GoodWithRecommend
            }
        }*/
        
    }
    
    
    //MARK:PrivateMethod
    func createFilterMenu() -> UIView{
        let filterTitles = ["默认","销量","人气"]
        let countForBtn = CGFloat(filterTitles.count)
        //52+16，与tableView的delegate中设置的第0个section的heightForHeader一致
        let view = UIView(frame: CGRectMake(0 , 0, kScreenWidth, 52 + 16))
        view.backgroundColor = UIColor.clearColor()
        for var i=0;i<filterTitles.count;i++ {
            let index = i%filterTitles.count
            let btn = UIButton(frame:  CGRectMake(CGFloat(index) * kScreenWidth/countForBtn , 0, kScreenWidth/countForBtn, 52))
            btn.backgroundColor = UIColor.whiteColor()
            btn.titleLabel?.font = defaultSysFontWithSize(17)
            btn.selected = i == self.IndexFilter ? true : false
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.setTitleColor(RGB(235,61,61,1.0), forState: .Selected)
            
            btn.setTitle(filterTitles[i], forState: .Normal)
            btn.setTitle(filterTitles[i], forState: .Selected)
            if filterTitles[i] == "销量" || filterTitles[i] == "人气" {
                let width = (kScreenWidth)/countForBtn
                btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: (width-50)/2 + 20, bottom: 0, right: 0)
                btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (width-50)/2 + 10)
                
                if self.IndexFilter == i {
                    btn.setImage(UIImage(named: "list_price_down"), forState: .Normal)
                    btn.setImage(UIImage(named: "list_price_up"), forState: .Selected)
                    btn.setTitleColor(RGB(235,61,61,1.0), forState: .Normal)
                    let upArr = [self.orderbySaleUp,self.orderbyPopularUp]
                    btn.selected = upArr[i-1]
                } else {
                    btn.setImage(UIImage(named: "list_price_normal"), forState: .Normal)
                }
            }
            
            btn.titleLabel?.font = UIFont.systemFontOfSize(13)
            btn.tag = 1000 + i
            view.addSubview(btn)
            //btn间的分割线
            let line = ZMDTool.getLine(CGRect(x: btn.frame.size.width-1, y: 19, width: 1, height: 15))
            btn.addSubview(line)
            
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.IndexFilter = sender.tag - 1000
                if filterTitles[sender.tag - 1000] == "销量" || filterTitles[sender.tag - 1000] == "人气"{
                    (sender as! UIButton).selected = !(sender as! UIButton).selected
                }
                let orderbys = [(0,0),(17,18),(19,20),(15,16)]
                let title = filterTitles[sender.tag - 1000]
                let orderby = orderbys[sender.tag - 1000]
                switch title {
                case "默认" :
                    self.orderBy = nil
                    break
                case "销量" :
                    self.orderbySaleUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbySaleUp ? orderby.0 : orderby.1
                    break
                case "人气" :
                    self.orderbyPopularUp = (sender as! UIButton).selected
                    self.orderBy = self.orderbyPopularUp ? orderby.0 : orderby.1
                case "最新" :
                    self.orderBy = orderby.1
                    break
                default :
                    break
                }
                self.indexSkip = 0
//                self.updateData(self.orderBy)
            })
        }
        return view
    }
}


//MARK: StoreShowListGoodCell
class StoreListGoodCell: UITableViewCell {
    @IBOutlet weak var firstView:UIView!
    @IBOutlet weak var secondView:UIView!
    @IBOutlet weak var thirdView:UIView!
    @IBOutlet weak var fourthView:UIView!
    
    override func awakeFromNib() {
        //        self.firstView.center =
    }
    
    func configCellWith(data:NSArray){
        let lbl = self.fourthView.viewWithTag(102) as! UILabel
        lbl.text = "¥111.00"
    }
}