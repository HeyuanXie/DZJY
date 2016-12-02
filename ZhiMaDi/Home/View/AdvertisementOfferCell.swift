//
//  AdvertisementOfferCellTableViewCell.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/26.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 首页 广告位  offer
class AdvertisementOfferCell: UITableViewCell {

    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightTopBtn: UIButton!
    @IBOutlet weak var rightBotBtn: UIButton!
    @IBOutlet weak var testBtn: UIButton!
    
    @IBOutlet weak var rightTopImgV: UIImageView!
    @IBOutlet weak var rightBotImgv: UIImageView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var botTitleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    class func configCell(cell:AdvertisementOfferCell,advertisementAll:[ZMDAdvertisement]?) {
        if let advertisement = advertisementAll?[0] {
            let url = kImageAddressNew + (advertisement.ResourcesCDNPath ?? "")
            cell.leftBtn.sd_setImageWithURL(NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!), forState: UIControlState.Normal)
        }
        if let advertisement = advertisementAll?[1] {
            let url = kImageAddressNew + (advertisement.ResourcesCDNPath ?? "")
            cell.rightTopBtn.sd_setImageWithURL(NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!), forState: UIControlState.Normal)
        }
        if let advertisement = advertisementAll?[2] {
            let url = kImageAddressNew + (advertisement.ResourcesCDNPath ?? "")
            cell.rightBotBtn.sd_setImageWithURL(NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!), forState: UIControlState.Normal)
//            cell.testBtn.sd_setImageWithURL(NSURL(string: url), forState: UIControlState.Normal)
        }
    }
}
