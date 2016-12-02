//
//  OrderGoodsTableViewCell.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 购物车  商品Cell
class OrderGoodsTableViewCell: UITableViewCell {

    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var goodsImgV: UIImageView!
    @IBOutlet weak var goodsNameLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    var editFinish : ((productDetail:ZMDProductDetail,item:ZMDShoppingItem)->Void)!
    var selectFinish : ((Sci:ZMDShoppingItem,isAdd:Bool)->Void)!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //订单详情
    func configCellForOrderDetail(product:ZMDProductForOrderDetail) {
        if let imgUrl = product.PictureUrl {
            let url = kImageAddressMain+imgUrl
            goodsImgV.sd_setImageWithURL(NSURL(string: url))
        }
        goodsNameLbl.text = product.ProductName
        detailLbl.text = (product.AttributeInfo as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
        priceLbl.text = product.SubTotal
        quantityLbl.text = "x\(product.Quantity)"
    }
    //确认订单
    func configCellForConfig(item:ZMDShoppingItem) {
        if let imgUrl = item.Picture?.ImageUrl {
            goodsImgV.sd_setImageWithURL(NSURL(string: kImageAddressMain+imgUrl))
        }
        goodsNameLbl.text = item.ProductName.componentsSeparatedByString("】").last
        detailLbl.text = (item.AttributeInfo as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
        priceLbl.text = item.UnitPrice
        priceLbl.textColor = defaultSelectColor
        quantityLbl.text = "x\(item.Quantity)"
    }
    // 我的订单
    func configCellWithDic(dic:NSDictionary) {
        if let product = dic["Product"] as? NSDictionary,let productPictures = product["ProductPictures"] as? NSArray,let pictureId = (productPictures[0] as! NSDictionary)["PictureId"],let name = product["Name"] {
            goodsImgV.sd_setImageWithURL(NSURL(string: kImageAddressMain + "/picture/index/\(pictureId)"))
            goodsNameLbl.text = "\(name)"
        }
        if let attributeDescription = dic["AttributeDescription"] as? String {
            detailLbl.text = (attributeDescription as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
        }
        if let UnitPriceInclTax = dic["UnitPriceInclTax"] as? String {
            priceLbl.text = UnitPriceInclTax
        }
        if let Quantity = dic["Quantity"] {
            quantityLbl.text = "x\(Quantity)"
        }
    }
    
    /*func configCellForMyOrder(orderItem:ZMDOrderDetailOrderItems) {
        if orderItem.Product.ProductPictures?.count != 0 {
            let pictureId = orderItem.Product.ProductPictures![0].PictureId
            goodsImgV.sd_setImageWithURL(NSURL(string:kImageAddressMain+"/picture/index/\(pictureId)"))

        }
        goodsNameLbl.text = orderItem.Product.Name
        if let attributeDescription = orderItem.AttributeDescription {
            detailLbl.text = (attributeDescription as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
        }
        if let UnitPriceInclTax = orderItem.UnitPriceInclTax {
            priceLbl.text = "¥\(String(format:"%.1f",(UnitPriceInclTax as NSString).doubleValue))"
        }
        if let Quantity = orderItem.Quantity {
            quantityLbl.text = "x\(Quantity)"
        }
    }*/
    func configCellForMyOrder(orderItem:ZMDOrderItem) {
        goodsImgV.sd_setImageWithURL(NSURL(string: kImageAddressMain + orderItem.PictureUrl), placeholderImage: nil)
        goodsNameLbl.text = orderItem.ProductName
        if let attributeInfo = orderItem.AttributeInfo {
            detailLbl.text = (attributeInfo as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
        }
        if let price = orderItem.UnitPrice {
            priceLbl.text = price
        }
        if let Quantity = orderItem.Quantity {
            quantityLbl.text = "x\(Quantity.integerValue)"
        }
    }
    
    //config购物车中的cell
    func configCellInShoppingCar(item:ZMDShoppingItem,scis:NSArray) {
        if let imgUrl = item.Picture?.ImageUrl {
            goodsImgV.sd_setImageWithURL(NSURL(string: kImageAddressMain+imgUrl))
        }
        goodsNameLbl.text = item.ProductName.componentsSeparatedByString("】").last
        //产品详情，颜色和尺码
        detailLbl.text = (item.AttributeInfo as NSString).stringByReplacingOccurrencesOfString("<br />", withString: " ")
        priceLbl.text = item.UnitPrice
        quantityLbl.text = "x\(item.Quantity)"
        //点击编辑按钮，通过self.editFinish这个block传递productDetail和item
        editBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            //多线程处理
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                QNNetworkTool.fetchProductDetail(item.ProductId.integerValue) { (productDetail, error, dictionary) -> Void in
                    if productDetail != nil
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.editFinish(productDetail: productDetail!,item: item)
                        })
                    }else{
                        ZMDTool.showErrorPromptView(nil, error: error)
                    }
                }
            })

            return RACSignal.empty()
        })
        //选中某个商品,通过selectFinish回调
        selectBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as! UIButton).selected = !(sender as! UIButton).selected
            self.selectFinish(Sci: item,isAdd: (sender as! UIButton).selected)
            return RACSignal.empty()
        })
        //先让所有的selectBtn的selected为false
        selectBtn.selected = false
        //scis为选中商品的数组
        for tmp in scis {
            //遍历选中购物单中的item判断cell是否选中，然后在改变cell的selectedBtn
            if (tmp as! ZMDShoppingItem).Id == item.Id {
                selectBtn.selected = true
            }
        }
    }
}
