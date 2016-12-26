//
//  ZMDEnterprise.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/22.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//企业model
/*
"Id": 2,
"Name": "木什乡土鸡蛋",
"EnterpriseName": "木什土鸡蛋",
"AreaName": null,
"Adress": null,
"ManagementModel": 0,
"Description": null,
"OwnedIndustry": null,
"StorePictureId": 0,
"StorePicture": "",
"EnterprisePictureId": 0,
"EnterprisePicture": "/Media/Thumbs/0002/0002514-150.jpg",
"SotreId": 0,
"CustomProperties": {}
*/
class ZMDEnterprise: NSObject {
    var Id : NSNumber!
    var Name : String!
    var EnterprisePicture : String!
    var AreaName : String!
    var Description : String!
    var Products : [ZMDEnterpriseProduct]!
    var SotreId : NSNumber!
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["Products":ZMDEnterpriseProduct.classForCoder()]
    }
}

class ZMDEnterpriseProduct: NSObject {
    /*
    "ProductName": "新鲜绿葡萄",
    "SeName": "746",
    "ProudctId": 746,
    "ProductUrl": null,
    "ImgUrl": "/Media/Thumbs/0002/0002486-150.jpg",
    "Price": "0.01",
    "Id": 0,
    "CustomProperties": {}
    */
    var ProductName : String!
    var SeName : String!
    var ProductId : NSNumber!
    var ProductUrl : String!
    var ImgUrl : String!
    var Price : String!
    var Id : NSNumber!
}
