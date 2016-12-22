//
//  Product.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/16.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 商品
class ZMDProduct: NSObject {
    var Id : NSNumber!
    var ProductTypeId : NSNumber!
    var Name : String!
    var ShortDescription : String!
    var Sku  : String?                  // 商品货号
    var ShowSku : NSNumber?             //
    var Sold : String!                  // 已售
    var DeliveryTimeName : String!      //配送时间
    var IsFreeShipping : NSNumber? = 0  // 免邮
    var ProductPrice : ZMDProductPrice?
    var DefaultPictureModel : ZMDPictureModel?

    var Store : ZMDStoreDetail!

    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["ProductPrice":ZMDProductPrice.classForCoder(),"DefaultPictureModel":ZMDPictureModel.classForCoder()]
    }
}
class ZMDProductPrice : NSObject {
    var Price : String! = ""
    var OldPrice : String?         // 原价
    var Rent : String? = ""
}
class ZMDPictureModel : NSObject {
    var PictureId : String! = ""
    var ImageUrl : String? = ""         
    var FullSizeImageUrl : String? = ""
}
class ZMDProductForOrderDetail: NSObject {
    var ProductId : NSNumber!
    var ProductTypeId : NSNumber!
    var ProductName : String!
    var AttributeInfo : String!
    var Sku  : String?                  // 商品货号
    var PictureUrl : String?
    var UnitPrice : String!
    var SubTotal : String!
    var Quantity : NSNumber!
}


//首页交易动态商品
/*
"Sku": null,
"ProductId": 639,
"ProductName": " （预售）老科曼石榴原汁 100%纯石榴汁",
"ProductSeName": "-100-3",
"ProductUrl": null,
"PictureUrl": null,
"ProductType": 5,
"UnitPrice": null,
"SubTotal": null,
"Quantity": 1,
"QuantityUnit": "",
"AttributeInfo": "",
"BundlePerItemPricing": false,
"BundlePerItemShoppingCart": false,
"BundleItems": [],
"Id": 251,
"CustomProperties": {}
*/
class ZMDTradeProduct : NSObject {
    var ProductId : NSNumber!
    var ProductName : String!
    var Quantity : NSNumber!
    var QuantityUnit : String!
}



