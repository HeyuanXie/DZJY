//
//  ZMDSupplyProduct.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/13.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

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
    var Description : String?
    var CheckStatus : NSNumber!
    var Type : NSNumber!
    var AreaName : String!
    var AreaCode : String?
    var QQ : String!
    var UserName : String!
    var Phone : String!
    var SupplyDemandPictures : [ZMDSupplyPicture]!
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["SupplyDemandPictures":ZMDSupplyPicture.classForCoder()]
    }
    
    override init() {
        self.Id = 0
        self.Title = ""
        self.Quantity = 0
        self.QuantityUnit = "吨"
        self.MinQuantityUnit = "吨"
        self.MinQuantity = 0
        self.Price = 0
        self.PriceUnit = "吨"
        self.CreateOn = ""
        self.EndTime = ""
        self.CustomerId = 0
        self.Description = ""
        self.CheckStatus = 0
        self.Type = 0
        self.AreaName = ""
        self.AreaCode = ""
        self.QQ = ""
        self.UserName = ""
        self.Phone = ""
    }
}

class ZMDSupplyPicture : NSObject {
    var Id : NSNumber!
    var PictureUrl : String!
    var PictureId : NSNumber!
}


