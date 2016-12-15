//
//  SupplyDemandListCell.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/4.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

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
class SupplyDemandListCell : UITableViewCell {
    
    //left
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var goodsImgVLeft: UIImageView!
    @IBOutlet weak var titleLblLeft: UILabel!
    @IBOutlet weak var currentPriceLblLeft: UILabel!   // 当前价
    @IBOutlet weak var originalPriceLblLeft: UILabel!  // 原价
    @IBOutlet weak var countLblLeft: UILabel!
    @IBOutlet weak var isCollectionBtnLeft: UIButton!
    @IBOutlet weak var goodsImgVBotConstraint : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func configSupplyCell(cell:SupplyDemandListCell!,product:ZMDSupplyProduct!,isDemand:Bool=false) {
        cell.titleLblLeft.text = product.Title
        cell.currentPriceLblLeft.text = "¥ \(product.Price.floatValue) /\(product.PriceUnit)"
        cell.currentPriceLblLeft.attributedText = cell.currentPriceLblLeft.text?.AttributeText(["¥","\(product.Price.floatValue)"], colors: [appThemeColorNew,appThemeColorNew], textSizes: [15,18])
        cell.originalPriceLblLeft.text = "供应量: \(product.Quantity)\(product.QuantityUnit)/\(product.MinQuantity ?? 5)\(product.MinQuantityUnit)起订"
        cell.originalPriceLblLeft.attributedText = cell.originalPriceLblLeft.text?.AttributeText(["供应量:","\(product.Quantity)\(product.QuantityUnit)/\(product.MinQuantity ?? 5)\(product.MinQuantityUnit)起订",], colors: [RGB(174,174,174,1.0),defaultTextColor], textSizes: [13,13])
        cell.countLblLeft.text = "截止至: \(product.EndTime.componentsSeparatedByString("T").first!)"
        if let pictures = product.SupplyDemandPictures where pictures.count != 0 {
            let url = kImageAddressMain + pictures[0].PictureUrl
            cell.goodsImgVLeft.sd_setImageWithURL(NSURL(string: url), placeholderImage: nil)
        }else{
            cell.goodsImgVLeft.image = UIImage(named: "product_default")
        }
        if isDemand {
            cell.goodsImgVBotConstraint.constant = 150-12
            cell.originalPriceLblLeft.text = "采购量: \(product.Quantity)\(product.QuantityUnit)"
            cell.currentPriceLblLeft.text = "期望价格: ¥ \(product.Price.floatValue) /\(product.PriceUnit)"
            cell.currentPriceLblLeft.attributedText = cell.currentPriceLblLeft.text?.AttributeText(["¥","\(product.Price.floatValue)"], colors: [appThemeColor,appThemeColor], textSizes: [15,18])
        }
    }
}


class DemandListCell: UITableViewCell {
    
}


