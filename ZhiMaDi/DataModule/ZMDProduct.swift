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


//MARK: -*****************供求关系的商品**********************
/*
"Title":"asdsad",
"Quantity":12,
"QuantityUnit":"kg",
"MinQuantityUnit":"kg",
"MinQuantity":2,
"Price":12.2,
"PriceUnit":"/kg",
"CreateOn":"2012-05-10 11:20",
"EndTime":"2012-05-10 11:20",
"AreaCode":"1102152",
"AreaName":"所在区域",
"CustomerId"：1,
"Description":"详细说明",
"CheckStatus":1，
"Type":1,
"QQ":"23123213",
"UserName":"张三",
"Phone":"1354665454545",
"SupplyDemandPictures":[
{"Id":234,
"PictureUrl":"www.ksnongpi.com/media/0323.jpg",
"PictureId":23}
]
*/
class ZMDSupplyProduct : NSObject {
    var Id : NSNumber!
    var Title : String!
    var Quantity : NSNumber!
    var QuantityUnit : String!
    var MinQuantityUnit : String!
    var MinQuantity : NSNumber!
    var Price : NSNumber!
    var PriceUnit : String!
    var CreateOn : String!
    var EndTime : String!
    var CustomerId : NSNumber!
    var Description : String!
    var CheckStatus : NSNumber!
    var Type : NSNumber!
    var AreaName : String!
    var AreaCode : String!
    var QQ : String!
    var UserName : String!
    var Phone : String!
    var SupplyDemandPictures : [ZMDSupplyPicture]!
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["SupplyDemandPictures":ZMDSupplyPicture.classForCoder()]
    }
}

class ZMDSupplyPicture : NSObject {
    var Id : NSNumber!
    var PictureUrl : String!
    var PictureId : NSNumber!
}

