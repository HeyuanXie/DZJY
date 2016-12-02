//
//  DoubleGoodsTableViewCell.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/23.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
import ReactiveCocoa
// 商品双层形式cell
class DoubleGoodsTableViewCell: UITableViewCell {

    //left
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var goodsImgVLeft: UIImageView!
    @IBOutlet weak var titleLblLeft: UILabel!
    @IBOutlet weak var currentPriceLblLeft: UILabel!   // 当前价 
    @IBOutlet weak var originalPriceLblLeft: UILabel!  // 原价
    @IBOutlet weak var countLblLeft: UILabel!
    @IBOutlet weak var isCollectionBtnLeft: UIButton!
    //right
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var goodsImgVRight: UIImageView!
    @IBOutlet weak var titleLblRight: UILabel!
    @IBOutlet weak var currentPriceLblRight: UILabel!
    @IBOutlet weak var originalPriceLblRight: UILabel!
    @IBOutlet weak var countLblRight: UILabel!
    @IBOutlet weak var isCollectionRight: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    class func configCell(cell:DoubleGoodsTableViewCell!,product : ZMDProduct!,productR : ZMDProduct?) {
        
        cell.titleLblLeft.text = product.Name.componentsSeparatedByString("】").last
        cell.countLblLeft.text = "已售\(product.Sold)件"
        if let productPrice = product.ProductPrice {
            cell.currentPriceLblLeft.text = "\(productPrice.Price)"
            let oldPrice = productPrice.OldPrice==nil ? productPrice.Price : productPrice.OldPrice
            cell.originalPriceLblLeft.text = "原价: \(oldPrice)"
        }
        if let pictureModel = product.DefaultPictureModel {
            
            let imgUrl = kImageAddressMain + (pictureModel.ImageUrl ?? "")
            cell.goodsImgVLeft.sd_setImageWithURL(NSURL(string: imgUrl), placeholderImage: UIImage(named: "product_default"))
        }
        
        // 右边 item
        guard let productR = productR else {
            if cell.rightView != nil {
                cell.rightView.hidden = true
            }
            return
        }
        cell.rightView.hidden = false
        cell.titleLblRight.text = productR.Name.componentsSeparatedByString("】").last
        if let productPrice = productR.ProductPrice {
            cell.currentPriceLblRight.text = "\(productPrice.Price)"
            let oldPrice = productPrice.OldPrice == nil ? productPrice.Price : productPrice.OldPrice
            cell.originalPriceLblRight.text = "原价: \(oldPrice)"
        }
        if let pictureModel = productR.DefaultPictureModel {
            let imgUrl = kImageAddressMain + (pictureModel.ImageUrl ?? "")
            cell.goodsImgVRight.sd_setImageWithURL(NSURL(string: imgUrl), placeholderImage: UIImage(named: "product_default"))
        }
        cell.countLblRight.text = "已售\(productR.Sold)件"
        
        //DoubleGoodsCell收藏响应
        cell.isCollectionBtnLeft.setImage(UIImage(named: "list_collect_normal.png"), forState: UIControlState.Normal)
        cell.isCollectionBtnLeft.setImage(UIImage(named: "list_collect_selected.png"), forState: UIControlState.Selected)
        cell.isCollectionBtnLeft.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            
            cell.isCollectionBtnLeft.selected = !cell.isCollectionBtnLeft.selected
            if cell.isCollectionBtnLeft.selected {
                    //从服务器添加收藏
                    let dic = NSMutableDictionary()
                    dic.setValue(g_customerId!, forKey: "CustomerId")
                    dic.setValue(1, forKey: "Quantity")
                    dic.setValue(product.Id, forKey: "Id")
                    dic.setValue(1, forKey: "carttype")
                    QNNetworkTool.addProductToCart(dic, completion: { (succeed, dictionary, error) -> Void in
                        if succeed! {
                            ZMDTool.showPromptView("收藏成功")
                        }else{
                            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "收藏失败")
                        }
                    })
                }else{
                    ZMDTool.showPromptView("已取消收藏")
                    //从服务器删除收藏
                    //......
                }
            return RACSignal.empty()
        })

        cell.isCollectionRight.setImage(UIImage(named: "list_collect_normal.png"), forState: UIControlState.Normal)
        cell.isCollectionRight.setImage(UIImage(named: "list_collect_selected.png"), forState: UIControlState.Selected)
        cell.isCollectionRight.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            
            cell.isCollectionRight.selected = !cell.isCollectionRight.selected
            if cell.isCollectionRight.selected {
                    //从服务器添加收藏
                    let dic = NSMutableDictionary()
                    dic.setValue(g_customerId!, forKey: "CustomerId")
                    dic.setValue(1, forKey: "Quantity")
                    dic.setValue(productR.Id, forKey: "Id")
                    dic.setValue(1, forKey: "carttype")
                    QNNetworkTool.addProductToCart(dic, completion: { (succeed, dictionary, error) -> Void in
                        if succeed! {
                            ZMDTool.showPromptView("收藏成功")
                        }else{
                            ZMDTool.showErrorPromptView(dictionary, error: error, errorMsg: "收藏失败")
                        }
                    })
                }else{
                    ZMDTool.showPromptView("已取消收藏")
                    //从服务器删除收藏
                    //......
                }
            return RACSignal.empty()
        })
        
    }
}
