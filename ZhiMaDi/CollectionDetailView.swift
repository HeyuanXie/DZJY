//
//  CollectionDetailView.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/12.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class CollectionDetailView: UIView {

    @IBOutlet weak var imgView1 : UIImageView!
    @IBOutlet weak var imgView2 : UIImageView!
    @IBOutlet weak var imgView3 : UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var quantityLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var endLbl : UILabel!
    @IBOutlet weak var endLblBotLayout: NSLayoutConstraint!
    @IBOutlet weak var titleLblBotLayout: NSLayoutConstraint!
    
    override func drawRect(rect: CGRect) {
        self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(234))
    }
    
    override func awakeFromNib() {
        self.endLblBotLayout.constant = zoom(10)
        self.titleLblBotLayout.constant = zoom(16)
    }
    
    class func configDetailView(view:CollectionDetailView,data:ZMDSupplyProduct) {
        if let pictures = data.SupplyDemandPictures {
            for i in 0..<pictures.count {
                let imgView = view.viewWithTag(1000+i) as! UIImageView
                let picture = pictures[i]
                imgView.sd_setImageWithURL(NSURL(string: kImageAddressMain+picture.PictureUrl), placeholderImage: nil)
            }
            for i in pictures.count..<3 {
                let imgView = view.viewWithTag(1000+i)
//                imgView?.removeFromSuperview()
            }
        }
//        view.titleLbl.text = ""
//        view.quantityLbl.text = ""
//        view.priceLbl.text = ""
//        view.endLbl.text = ""
    }
}
