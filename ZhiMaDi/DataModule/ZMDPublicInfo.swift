//
//  ZMDPublicInfo.swift
//  ZhiMaDi
//
//  Created by haijie on 16/6/3.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//
/*{
"Types": "纸质发票",
"Categorys": "个人,企业",
"Bodys": "床上用品,家具,日用品,植物,装饰品",
"DefaultInvoice": null,
"CustomProperties": {}
}*/
import UIKit
// 发票信息
class ZMDPublicInfo: NSObject {
    var Types:String!               //纸质发票",
    var Categorys:String!           //个人,企业",
    var Bodys:String!               //床上用品,家具,日用品,植物,装饰品"
    func getTypes() -> [String] {
        var types = self.Types.componentsSeparatedByString(",")
        types.insert("不开发票", atIndex: 0)
        return types
    }
    func getCategorys() -> [String]{
        var categorys = self.Categorys.componentsSeparatedByString(",")
        return categorys
    }
    func getBodys() -> [String]{
        let bodys = self.Bodys.componentsSeparatedByString(",")
        return bodys
    }
}
