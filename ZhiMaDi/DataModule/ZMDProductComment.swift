//
//  ZMDProductComment.swift
//  ZhiMaDi
//
//  Created by admin on 16/11/21.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class ZMDProductComment: NSObject {
    var CustomerId : NSNumber!
    var CustomerName : String!
    var ReviewText : String!
    var Rating : NSNumber!
    var ParenetId : NSNumber!
    var IsAnonymous : Bool!
    var OrderItemId : NSNumber!
    var ProductId : NSNumber!
    var OrderId : NSNumber!
    var OrderItemModel : ZMDCommentItem!    //商品评价中的商品Item//评价评价对象中商品的信息
    var Id : NSNumber!
    class ZMDCommentItem : NSObject {
        var Sku : String!
        var ProductId : NSNumber!
        var ProductName : String!
        var ProductSeName : String!
        var ProductUrl : String!
        var PictureUrl : String!
        var ProductType : NSNumber!
        var UnitPrice : String!
        var SubTotal : String!
        var Quantity : NSNumber!
        var QuantityUnit : String!
        var AttributeInfo : String!
        var BundlePerItemPricing : Bool!
        var BundlePerItemShoppingCart : Bool!
        var Id : NSNumber!
        //    var BundleItems : NSArray!
        
    }
    
    //    var ProductReviewPictures:NSArray!
    //    var AnswerText : String!
    //    var AdditionalReview:String!
    //    var Id : NSNumber!
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["OrderItemModel":ZMDCommentItem.classForCoder()]
    }
    
}

//评价评价对象中商品的信息
class ZMDCommentItem : NSObject {
    var Sku : String!
    var ProductId : NSNumber!
    var ProductName : String!
    var ProductSeName : String!
    var ProductUrl : String!
    var PictureUrl : String!
    var ProductType : NSNumber!
    var UnitPrice : String!
    var SubTotal : String!
    var Quantity : NSNumber!
    var QuantityUnit : String!
    var AttributeInfo : String!
    var BundlePerItemPricing : Bool!
    var BundlePerItemShoppingCart : Bool!
    var Id : NSNumber!
    //    var BundleItems : NSArray!
    
}
