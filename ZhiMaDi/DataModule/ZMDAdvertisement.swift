//
//  ZMDAdvertisement.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/26.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 广告位
class ZMDAdvertisement: NSObject {
    var Id: NSNumber!                                   //6
    var Title:String?                                   //"新品推荐",
    var Type:NSNumber?                                  //1,
    var Available:String?                               //true,
    var Resources:String?                             //"/Media/Advertisement/new.png",
    var ResourcesCDNPath:String?                        //"/Advertisement/new.png",
    var StartTime:String?                               //"2016-05-26T00:00:00",
    var EndTime:String?                                 //"2016-07-22T00:00:00",
    var StartTimeSpan:String?                           //null,
    var EndTimeSpan:String?                             //null,
    var AdvertisementId:NSNumber?                       //11,
    var ResourceId:NSNumber?                            //21,
    var LinkUrl:String?                                 //"11",
    var Other1:String?                                  //"b1",
    var Other2:String?                                  //"b2",
    var Other3:String?                                  //"b3"
}
class ZMDAdvertisementAll : NSObject {
    var top : [ZMDAdvertisement]?
    var icon: [ZMDAdvertisement]?
    var offer: [ZMDAdvertisement]?
    var guess: [ZMDAdvertisement]?
    var topic: [ZMDAdvertisement]?
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["top":ZMDAdvertisement.classForCoder(),"icon":ZMDAdvertisement.classForCoder(),"offer":ZMDAdvertisement.classForCoder(),"guess":ZMDAdvertisement.classForCoder(),"topic":ZMDAdvertisement.classForCoder()]
    }
}
