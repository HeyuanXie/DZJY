//
//  ZMDProductAttrView.swift
//  ZhiMaDi
//
//  Created by haijie on 16/6/2.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

//选择产品属性View，(颜色、尺寸)
class ZMDProductAttrView: UIView {
    var productDetail:ZMDProductDetail!
    var attrSelects = NSMutableArray()
    var refreshArr = NSMutableArray()
    var attrSet = NSMutableArray()
    var kTagAttrView = 10000
    var SciId = 0
    
    var isAllSelected = false
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(frame: CGRect,productDetail:ZMDProductDetail) {
        super.init(frame: frame)
        self.productDetail = productDetail
        for var i = 0;i<productDetail.ProductVariantAttributes!.count;i++ {
            self.attrSelects.addObject(";")
            self.attrSet.addObject(";")
        }
        self.updateUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateUI() {
        self.backgroundColor = UIColor.whiteColor()
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        // attr
        var index = -1
        for attr in productDetail.ProductVariantAttributes! {
            index = index + 1
            let size = attr.TextPrompt!.sizeWithFont(defaultSysFontWithSize(16), maxWidth: 100)
            let label = ZMDTool.getLabel(CGRectMake(0, 60 * CGFloat(index),size.width + 16, 60), text: attr.TextPrompt!, fontSize: 16,textAlignment:.Center)
            self.addSubview(label)
            
            let valueNames = NSMutableArray()
            for value in attr.Values! {
                valueNames.addObject(value.Name!)
            }
            let menuTitle = valueNames as! [String]
            let menuIndexTrue = NSMutableArray()
            var menuIndex = -1
            for _ in menuTitle {
                menuIndex = menuIndex + 1
//                let attrSelectsTmp = self.attrSelects
                let tmpForPost = "\(attr.Id):\(attr.Values![menuIndex].Id)"
                // 判断，如果self.refreshArr有值，进入对比，如果mode在self.refreshArr里面，显示正常颜色，若不在，灰色且不可选择。
                if self.refreshArr.count == 0 {
                    var result = true
                    for tmp in self.attrSet {
                        if tmp as! String != ";" {
                            result = false
                            break
                        }
                    }
                    if result {
                        menuIndexTrue.addObject(menuIndex)
                    }
                } else {
                    for tmp in self.refreshArr {
                        if tmp as! String == tmpForPost {
                            menuIndexTrue.addObject(menuIndex)
                        }
                    }
                }
            }
            let multiselectView = ZMDAttrView(frame:CGRect(x: CGRectGetMaxX(label.frame), y: 60 * CGFloat(index), width: kScreenWidth - CGRectGetMaxX(label.frame), height: 60),titles: menuTitle,menuIndexTrue:menuIndexTrue,attrSet:attrSet,attr:attr)
            multiselectView.tag = index + kTagAttrView
            multiselectView.finished = { (finishIndex,isAdd) ->Void in
                let tmpForPost = "\(attr.Id):\(attr.Values![finishIndex].Id)"
                self.attrSelects.replaceObjectAtIndex(multiselectView.tag - self.kTagAttrView, withObject: tmpForPost)
                if isAdd {
                    self.attrSet.replaceObjectAtIndex(multiselectView.tag - self.kTagAttrView, withObject: tmpForPost)
                } else {
                    self.attrSet.replaceObjectAtIndex(multiselectView.tag - self.kTagAttrView, withObject: ";")
                }
                self.func1()
                self.updateUI()
            }
            self.addSubview(multiselectView)
        }
    }
    // 选择某个属性后
    func func1() {
        var result = true
        for tmp in self.attrSet {
            if tmp as! String != ";" {
                result = false
                break
            }
        }
        if result {
            refreshArr.removeAllObjects()
            return
        }
        do {
            let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(productDetail.AttributesBundle!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers)
            let attrBundle = jsonObject as! NSDictionary
            for key in attrBundle.allKeys {     //限制
                var result = true
                for tmp in self.attrSet {       //属性已选
                    if (key as! NSString).rangeOfString(tmp as! String).location == NSNotFound {
                        result = false   // 如果限制里面没有这个属性，则跳出
                        continue
                    }
                }
                if result {
                    let arr = (key as! NSString).componentsSeparatedByString(";")
                    for a in arr {
                        refreshArr.addObject(a)  //添加可以选的属性
                    }
                }
            }
        }
        catch {
        }
    }
    
    func getPostData(quantity:Int,IsEdit:Bool = true) -> NSDictionary? {
        let dic = NSMutableDictionary()
        if productDetail.ProductVariantAttributes!.count != 0 {
            let attr = productDetail.ProductVariantAttributes![0]
            for tmp in self.attrSelects {
                let tmps = (tmp as! NSString).componentsSeparatedByString(":")
                if tmps.count == 2 {
                    let tmpForPost = "product_attribute_\(attr.ProductId)_\(attr.BundleItemId)_\(attr.ProductAttributeId)_\(tmps[0])"
                    dic.setValue(NSString(string: tmps[1]).integerValue, forKey:tmpForPost)
                }
            }
        }
        if dic.count < self.productDetail.ProductVariantAttributes!.count {
//            ZMDTool.showPromptView("商品还有没选定的属性!")
            self.isAllSelected = false
            return nil
        }else{
            self.isAllSelected = true
        }
        if IsEdit {
            dic.setValue(SciId, forKey: "SciId")
        }
        //如果没登录，g_customerId = nil, 而下面g_customer是 ! 修饰，会crash，必须判断
        if g_isLogin! {
            dic.setValue(g_customerId!, forKey: "CustomerId")
        }
        dic.setValue(quantity, forKey: "Quantity")
        return dic
    }
    
    func getHeight() -> CGFloat {
        return  CGFloat(productDetail.ProductVariantAttributes!.count * 60)
    }
    class func getHeight(productDetail:ZMDProductDetail) -> CGFloat {
        return  CGFloat(productDetail.ProductVariantAttributes!.count * 60)
    }

}
