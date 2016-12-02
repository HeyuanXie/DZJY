//
//  SortViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/2/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa

//CollectionView
class SortViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorNavigationBarShowProtocol,UISearchBarDelegate{
    
    var collectView : UICollectionView!
    var searchBar :UISearchBar!
    
    var dataArray = NSMutableArray()
    let titles :NSMutableArray = ["床上用品","儿童家具","购物卡","热销","热门","儿童床"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestData()
        
        self.updateUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.title = "分类"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UISearchBarDelegate
    //点击屏幕影藏键盘
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let bgBtn = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(searchBar.frame), width: kScreenWidth, height: kScreenHeight-searchBar.frame.height))
        bgBtn.tag = 100
        self.presentPopupView(bgBtn, config: .None)
        bgBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            bgBtn.removeFromSuperview()
            self.searchBar.resignFirstResponder()
            return RACSignal.empty()
        })
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        let bgBtn = self.view.viewWithTag(100) as!UIButton
        bgBtn.removeFromSuperview()
        let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        vc.titleForFilter = searchBar.text ?? ""
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    // MARK:- UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->  UICollectionViewCell{
        let cellId = "Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = nil
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height))
        let leftLine = ZMDTool.getLine(CGRect(x: 0, y: 0, width: 0.25, height: cell.bounds.height), backgroundColor: UIColor.grayColor())
        let rightLine = ZMDTool.getLine(CGRect(x: cell.bounds.width-0.25, y: 0, width: 0.25, height: cell.bounds.height), backgroundColor: UIColor.grayColor())
        let bottomLine = ZMDTool.getLine(CGRect(x: 0, y: cell.bounds.height-0.5, width: cell.bounds.width, height: 0.5), backgroundColor: UIColor.grayColor())
        
        cell.contentView.addSubview(imgView)
        cell.contentView.addSubview(bottomLine)
        if indexPath.section % 2 == 0 {
            cell.contentView.addSubview(rightLine)
        }else{
            cell.contentView.addSubview(leftLine)
        }
        
        imgView.image = UIImage(named: "home_banner0\(indexPath.row%3+3)")
        
        //self.dataArray有数据时更新
        if self.dataArray.count != 0 {
            let category = self.dataArray[indexPath.row%self.dataArray.count] as! ZMDXHYCategory
            if let urlStr = category.PictureModel.ImageUrl,url = NSURL(string: kImageAddressMain+urlStr) {
                imgView.sd_setImageWithURL(url, placeholderImage: nil)
            }
        }
        return cell
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = self.view.bounds.height
        return CGSizeMake(kScreenWidth/2, height/4)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.row)-\(indexPath.section)")
        //点击cell进入列表
        let vc = HomeBuyListViewController.CreateFromMainStoryboard() as! HomeBuyListViewController
        vc.titleForFilter = self.titles[indexPath.row % 6] as! String  //临时
        vc.As = "true"
        // 分类接口有数据后采用
        if self.dataArray.count != 0{
            vc.titleForFilter = (self.dataArray[indexPath.row%self.dataArray.count] as!ZMDXHYCategory).Name
            vc.Cid = "\((self.dataArray[indexPath.row%self.dataArray.count] as!ZMDXHYCategory).Id)"
        }
        vc.storeId = 0
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
    //MARK: -  PrivateMethod
    func requestData() {
        QNNetworkTool.sortCategories { (categories, error, dictionary) -> Void in
            if let array = categories {
                self.dataArray.removeAllObjects()
                self.dataArray.addObjectsFromArray(array as [AnyObject])
                self.collectView.reloadData()
            }else {
                ZMDTool.showErrorPromptView(nil, error: error)
            }
        }
    }
    
    func updateUI() {
        let item = UIBarButtonItem(image: UIImage(named: "home_search"), style: UIBarButtonItemStyle.Done, target: nil, action: nil)
        item.customView?.tintColor = UIColor.blackColor()
        item.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = HomeBuyGoodsSearchViewController.CreateFromMainStoryboard() as! HomeBuyGoodsSearchViewController
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return RACSignal.empty()
        })
        self.navigationItem.rightBarButtonItem = item
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        self.collectView = UICollectionView(frame: CGRectMake(0, 0,self.view.frame.size.width,self.view.bounds.height), collectionViewLayout: flowLayout)
        self.collectView.backgroundColor = tableViewdefaultBackgroundColor
        self.collectView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectView.delegate = self
        self.collectView.dataSource = self
        self.view.addSubview(collectView)
        
        self.searchBar = UISearchBar(frame: CGRectMake(12, 14, kScreenWidth - 24, 38))
        searchBar.backgroundImage = UIImage.imageWithColor(UIColor.clearColor(), size: searchBar.bounds.size)
        searchBar.placeholder = "商品搜索"
        searchBar.layer.borderColor = UIColor.grayColor().CGColor;
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.cornerRadius = 6
        searchBar.layer.masksToBounds = true
        searchBar.delegate = self
    }
    

    
    
}
