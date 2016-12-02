//
//  StringExtension.swift
//  QooccHealth
//
//  Created by 肖小丰 on 15/4/17.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import Foundation

extension String{

    func sizeWithAttributeString(attributedString: NSAttributedString, maxWidth: CGFloat) -> CGSize{
        let rect = attributedString.boundingRectWithSize(CGSizeMake(maxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return rect.size
    }
    func sizeWithFont(font: UIFont, maxWidth: CGFloat) -> CGSize {
        let attributedString = NSAttributedString(string: self, attributes: [NSFontAttributeName : font])
        let rect = attributedString.boundingRectWithSize(CGSizeMake(maxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return rect.size
    }
    
    func sizeWithFont(font: UIFont, maxWidth: CGFloat, lines: Int) -> CGSize {
        var size = self.sizeWithFont(font, maxWidth: maxWidth)
        let simple = "a你".sizeWithAttributes([NSFontAttributeName : font])
        size.height = min(simple.height * CGFloat(lines), size.height)
        return size
    }
    //富文本  
    /**
    * attrStr   文本
    * color     文本颜色
    *
    */
    func AttributedText(attrStr:String,color:UIColor) -> NSAttributedString {
        let attText = NSMutableAttributedString(string: self)
        let rentPriceRange = (self as NSString).rangeOfString(attrStr, options: NSStringCompareOptions())
        attText.setAttributes([NSForegroundColorAttributeName:defaultTextColor], range: NSMakeRange(0, rentPriceRange.location))
        attText.setAttributes([NSForegroundColorAttributeName:RGB(235,61,61,1.0)], range: NSMakeRange(rentPriceRange.location, rentPriceRange.length))
        attText.setAttributes([NSForegroundColorAttributeName:defaultTextColor], range: NSMakeRange(rentPriceRange.location + rentPriceRange.length, self.characters.count - (rentPriceRange.location + rentPriceRange.length)))
        return attText
    }

    func AttributedMutableText(attrStrs:[String],colors:[UIColor]) -> NSAttributedString {
        let attText = NSMutableAttributedString(string: self)
        var i = 0
        for attrStr in attrStrs {
            let rentPriceRange = (self as NSString).rangeOfString(attrStr, options: NSStringCompareOptions())
            attText.addAttribute(NSForegroundColorAttributeName, value: colors[i], range: NSMakeRange(rentPriceRange.location, rentPriceRange.length))
            i++
        }
        return attText
    }
    func AttributeText(attrStrs:[String],textSizes : [CGFloat]) -> NSAttributedString  {
        let attText = NSMutableAttributedString(string: self)
        var i = 0
        for attrStr in attrStrs {
            let rentPriceRange = (self as NSString).rangeOfString(attrStr, options: NSStringCompareOptions())
            attText.addAttribute(NSFontAttributeName, value: defaultSysFontWithSize(textSizes[i]), range: NSMakeRange(rentPriceRange.location, rentPriceRange.length))
            i++
        }
        return attText
    }
    func AttributeText(attrStrs:[String],colors:[UIColor],textSizes : [CGFloat]) -> NSAttributedString {
        let attText = NSMutableAttributedString(string: self)
        var i = 0
        for attrStr in attrStrs {
            let rentPriceRange = (self as NSString).rangeOfString(attrStr, options: NSStringCompareOptions())
            attText.addAttribute(NSForegroundColorAttributeName, value: colors[i], range: NSMakeRange(rentPriceRange.location, rentPriceRange.length))
            attText.addAttribute(NSFontAttributeName, value: defaultSysFontWithSize(textSizes[i]), range: NSMakeRange(rentPriceRange.location, rentPriceRange.length))
            i++
        }
        return attText
    }
    
    func AttributedStringWithImage(image:UIImage,size:CGSize) -> NSAttributedString{
        let attch = NSTextAttachment()
        attch.image = image
        attch.bounds = CGRect(origin: CGPoint.zero, size: size)
        return NSAttributedString(attachment: attch)
    }
    // MARK: 判断手机号码
    func checkStingIsPhone() -> Bool {
        // 手机号码
        let phoneRegex = "^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let phoneIsMatch = phonePred.evaluateWithObject(self)
        // 固定电话大陆
//        let telRegex = "^0\\d{2,3}(\\-)?\\d{7,8}$"
//        let telPred = NSPredicate(format: "SELF MATCHES %@", telRegex)
//        let telIsMatch = telPred.evaluateWithObject(self)
        
        return phoneIsMatch
    }
    //MARK: 判断11位数字（手机号）
     func checkStingIsPhoneNum() -> Bool {
        let phoneRegex = "^([1-9])\\d{10}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let phoneIsMatch = phonePred.evaluateWithObject(self)
        return phoneIsMatch
    }
    //MARK: 判断身份证号
//    func validateIdentityCard()->Bool{
//        if count(self) <= 0 {
//            return false
//        }
//        let regex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
//        let identityCardPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
//        return identityCardPredicate.evaluateWithObject(self)
//    }

}