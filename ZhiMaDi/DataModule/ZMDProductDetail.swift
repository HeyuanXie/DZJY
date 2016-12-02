//
//  ZMDProductDetail.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 产品详情
class ZMDProductDetail: NSObject {
    var Id : NSNumber!
    var Name : String!
    var ShortDescription : String!
    var Sku  : String?                  // 商品货号
    var ShowSku : NSNumber?             //
    var Sold : NSNumber!                  // 已售
    var IsFreeShipping : NSNumber? = 0  // 免邮
    var DeliveryTimeName : String!      //配送时间
    var ProductType : NSNumber?         //如果productType.interger == 15,则有搭配购
    var ProductPrice : ZMDProductPrice?
    var DetailsPictureModel : DetailsPicture?
    var BundledItems : [ZMDProductDetail]? // 搭配购
    var ProductVariantAttributes : [ProductVariantAttribute]?    // 产品属性
    var AttributesBundle : String?
    var Store : ZMDStoreDetail!    //店铺详情信息
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["ProductPrice":ZMDProductPrice.classForCoder(),"DetailsPictureModel":DetailsPicture.classForCoder(),"BundledItems":ZMDProductDetail.classForCoder(),"ProductVariantAttributes":ProductVariantAttribute.classForCoder(),"Store":ZMDStoreDetail.classForCoder()]
    }
}
class DetailsPicture : NSObject {
    var Name : String!
    var DefaultPictureModel : ZMDPictureModel?
    var PictureModels : [ZMDPictureModel]?

    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["DefaultPictureModel":ZMDPictureModel.classForCoder(),"PictureModels":ZMDPictureModel.classForCoder()]
    }
}
// 产品属性
class ProductVariantAttribute : NSObject {
    var Id : String!
    var ProductId: NSNumber!             // 20,
    var BundleItemId: NSNumber!          // 1
    var ProductAttributeId: NSNumber!     // 1
    var Alias: String?                  // Color
    var TextPrompt: String?
    var Values : [ProductVariantAttributeValue]?
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["Values":ProductVariantAttributeValue.classForCoder()]
    }
}

class ProductVariantAttributeValue : NSObject {
    var Name: String?                   //Black"
    var Alias: String?                  //black"
    var IsPreSelected: NSNumber?          //true
    var ImageUrl: String?               //null
    var Id: NSNumber!                     //7
}
