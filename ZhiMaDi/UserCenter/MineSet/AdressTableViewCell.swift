//
//  AdressTableViewCell.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/2.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 管理收货地址 -> cell(快递上门的cell)
class AdressTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var editBtnWidthConstraint: NSLayoutConstraint!
    
    var defaultLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.defaultLabel = UILabel(frame:CGRect(x: 12, y: 0, width: 40, height: self.title.frame.height))
        self.defaultLabel.center.y = self.address.center.y
        defaultLabel.backgroundColor = UIColor.redColor()
        defaultLabel.textColor = UIColor.whiteColor()
        defaultLabel.textAlignment = .Center
        self.contentView.addSubview(self.defaultLabel)
        self.defaultLabel.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    class func configCell(cell:AdressTableViewCell,address:ZMDAddress) {
        cell.title.text = "收件人: "+address.FirstName+" \(address.PhoneNumber)"
        if address.IsDefault == true{
            cell.title.text = "收件人: "+address.FirstName+" \(address.PhoneNumber)"+" (默认)"
            cell.title.font = UIFont.systemFontOfSize(15)
            let attributeString = cell.title.text?.AttributedMutableText(["收件人: ",address.FirstName," \(address.PhoneNumber)"," (默认)"], colors: [UIColor.blackColor(),UIColor.blackColor(),UIColor.blackColor(),UIColor.redColor()])
            cell.title.attributedText = attributeString
        } else {
            cell.title.text = "收件人: "+address.FirstName+" \(address.PhoneNumber)"
            cell.title.font = UIFont.systemFontOfSize(15)
        }
        cell.address.text = "收件地址: "+(address.Address1 ?? "") + (address.Address2 ?? "")
        if address.IsDefault == true {
            //当默认时，让self.address往右移defaultLabel的宽度
//            cell.defaultLabel.hidden = false
//            cell.address.center.x += 45
        }
    }
    
    class func configDaiShouCell(cell:AdressTableViewCell,address:ZMDAddress) {
        cell.title.text = "网点名称: "+address.FirstName+" \(address.PhoneNumber)"
        if address.IsDefault == true{
            cell.title.text = "网点名称: "+address.FirstName+" \(address.PhoneNumber)"+" (默认)"
            cell.title.font = UIFont.systemFontOfSize(15)
            let attributeString = cell.title.text?.AttributedMutableText(["收件人: ",address.FirstName," \(address.PhoneNumber)"," (默认)"], colors: [UIColor.blackColor(),UIColor.blackColor(),UIColor.blackColor(),UIColor.redColor()])
            cell.title.attributedText = attributeString
        } else {
            cell.title.text = "网点名称: "+address.FirstName+" \(address.PhoneNumber)"
            cell.title.font = UIFont.systemFontOfSize(15)
        }
        cell.address.text = "收货地址: "+(address.Address1 ?? "") + (address.Address2 ?? "")
        if address.IsDefault == true {
            //当默认时，让self.address往右移defaultLabel的宽度
            //            cell.defaultLabel.hidden = false
            //            cell.address.center.x += 45
        }
    }
}

class AdressTableViewDaiShouCell :UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var editBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var personLabel: UILabel!
    
    var defaultLabel : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.defaultLabel = UILabel(frame:CGRect(x: 12, y: 0, width: 40, height: self.title.frame.height))
        self.defaultLabel.center.y = self.address.center.y
        defaultLabel.backgroundColor = UIColor.redColor()
        defaultLabel.textColor = UIColor.whiteColor()
        defaultLabel.textAlignment = .Center
        self.contentView.addSubview(self.defaultLabel)
        self.defaultLabel.hidden = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    class func configCell(cell:AdressTableViewDaiShouCell,address:ZMDAddress) {
        cell.title.text = "收件人: "+address.FirstName+" \(address.PhoneNumber)"
        if address.IsDefault == true{
            cell.title.text = "收件人: "+address.FirstName+" \(address.PhoneNumber)"+" (默认)"
            cell.title.font = UIFont.systemFontOfSize(15)
            let attributeString = cell.title.text?.AttributedMutableText(["收件人: ",address.FirstName," \(address.PhoneNumber)"," (默认)"], colors: [UIColor.blackColor(),UIColor.blackColor(),UIColor.blackColor(),UIColor.redColor()])
            cell.title.attributedText = attributeString
        } else {
            cell.title.text = "收件人: "+address.FirstName+" \(address.PhoneNumber)"
            cell.title.font = UIFont.systemFontOfSize(15)
        }
        cell.address.text = "收件地址: "+(address.Address1 ?? "") + (address.Address2 ?? "")
        if address.IsDefault == true {
            //当默认时，让self.address往右移defaultLabel的宽度
            //            cell.defaultLabel.hidden = false
            //            cell.address.center.x += 45
        }
    }
}
