//
//  ZMDShareSDKTool.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/15.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
//单例
private let shareSDKTool = ZMDShareSDKTool()

class ZMDShareSDKTool: NSObject {
    class func startShare() {
        shareSDKTool
    }
    
    override init() {
        super.init()
        
        ShareSDK.registerApp("c46314899f04",
            activePlatforms: [
                SSDKPlatformType.TypeSinaWeibo.rawValue,
                SSDKPlatformType.TypeWechat.rawValue,
                SSDKPlatformType.TypeQQ.rawValue,
            ],
            onImport: {(platform : SSDKPlatformType) -> Void in
                switch platform{
                    
                case SSDKPlatformType.TypeSinaWeibo:
                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                case SSDKPlatformType.TypeWechat:
                    ShareSDKConnector.connectWeChat(WXApi.classForCoder(), delegate: self)
                case SSDKPlatformType.TypeQQ:
                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                default:
                    break
                }
            },
            onConfiguration: {(platform : SSDKPlatformType,appInfo : NSMutableDictionary!) -> Void in
                switch platform {
                case SSDKPlatformType.TypeSinaWeibo:
                    //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                    appInfo.SSDKSetupSinaWeiboByAppKey("568898243",
                        appSecret : "38a4f8204cc784f81f9f0daaf31e02e3",
                        redirectUri : "http://www.sharesdk.cn",
                        authType : SSDKAuthTypeBoth)
                case SSDKPlatformType.TypeWechat:
                    //设置微信应用信息
                    appInfo.SSDKSetupWeChatByAppId("wxc59280c42692603a", appSecret: "3cfd85fd1dd235f1ec572bb885d8c271")
                case SSDKPlatformType.TypeQQ:
                    //设置QQ应用信息
                    appInfo.SSDKSetupQQByAppId("1105808222",
                        appKey : "VFJy9m4n5zXj4tIF",
                        authType : SSDKAuthTypeBoth)
                default:
                    break
                }
        })
    }
    
    
    
    
    
    
    
    //MARK: - 分享
    //分享菜单 默认形式
    class func shareWithMenu(view : UIView!) {
        //        let shareView = view as! ShareView
        //1.创建分享参数
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText("分享内容",
            images : UIImage(named: "icon_hulubao"),
            url : NSURL(string:"http://mob.com"),
            title : "分享标题",
            type : SSDKContentType.Auto)
        
        //        if let data = shareView.delegate?.qnShareView(shareView) {
        //            let str = data.url.stringByReplacingOccurrencesOfString("http://", withString: "http://www.")
        //            let url = NSURL(string: str)
        //            shareParames.SSDKSetupShareParamsByText(data.title, images: data.image, url: url, title: data.title, type: SSDKContentType.Auto)
        //        }
        //允许客户端分享
        shareParames.SSDKEnableUseClientShare()
        //2.进行分享
        ShareSDK.showShareActionSheet(view, items: nil, shareParams: shareParames) { (state : SSDKResponseState, platformType : SSDKPlatformType, userdata : [NSObject : AnyObject]!, contentEnity : SSDKContentEntity!, error : NSError!, end) -> Void in
            
            switch state{
                
            case SSDKResponseState.Success: print("分享成功")
            let vc = view.getController()! as UIViewController
            vc.commonAlertShow(false, title: "分享", message: "分享成功", preferredStyle: .Alert)
            case SSDKResponseState.Fail:    print("分享失败,错误描述:\(error)")
            ZMDTool.showPromptView("分享失败")
            case SSDKResponseState.Cancel:  print("分享取消")
            ZMDTool.showPromptView("分享取消")
                
            default:
                break
            }
        }
    }
    
    
    class func simpleShare(url:String = "",image:UIImage,title:String,content:String) {
        if url != "" {
            assert(false, "url居然为空!")
            return
        }
        // 1.创建分享参数
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText(content,
            images : image,
            url : NSURL(string:url),
            title : title,
            type : SSDKContentType.Image)
        let shareType = SSDKPlatformType.TypeSinaWeibo
        switch shareType {
        case SSDKPlatformType.TypeSinaWeibo:
            shareParames.SSDKSetupSinaWeiboShareParamsByText(content, title: title, image: image, url: NSURL(string: url), latitude: 0, longitude: 0, objectID: nil, type: .WebPage)
            break
        case .SubTypeWechatSession:
            shareParames.SSDKSetupWeChatParamsByText(content, title: title, url: NSURL(string: url), thumbImage: image, image: image, musicFileURL: nil, extInfo: nil, fileData: nil, emoticonData: nil, type: .Auto, forPlatformSubType: .SubTypeWechatSession)//微信好友子平台
            break
        default:
            break
        }
        //允许客户端分享
        shareParames.SSDKEnableUseClientShare()
        //2.进行分享
        ShareSDK.share(shareType, parameters: shareParames) { (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
            
            switch state{
                
            case SSDKResponseState.Success:
                print("分享成功")
                let alert = UIAlertController(title: "分享提示", message: "分享成功", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Destructive, handler: { (sender) -> Void in
                    
                }))
                //self.delegate.presentViewController...
            case SSDKResponseState.Fail:    print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:  print("分享取消")
                
            default:
                break
            }
        }
    }
    
    
    
    class func shareShowActionSheetWith(title:String,url:String,content:String,view:UIView) {
        let imageView = UIImageView()
        imageView.sd_setImageWithURL(NSURL(string: "")) { (image, error, cacheType, imageUrl) -> Void in
            let shareParams = NSMutableDictionary()
            shareParams.SSDKSetupShareParamsByText(content, images: [image], url: NSURL(string: url), title: title, type: SSDKContentType.Auto)
            
            //分享(可以弹出我们的分享菜单和编辑按钮)
            ShareSDK.showShareActionSheet(view, items: nil /*[SSDKPlatformType.SubTypeWechatTimeline,SSDKPlatformType.SubTypeWechatSession,SSDKPlatformType.SubTypeQQFriend,SSDKPlatformType.SubTypeQZone,SSDKPlatformType.TypeSinaWeibo]*/, shareParams: shareParams, onShareStateChanged: { (state, platformType, userData, contentEntity, error, end) -> Void in
                
                switch state {
                case SSDKResponseState.Success:
                    
                    break
                case SSDKResponseState.Fail:
                    break
                default:
                    break
                }
            })
        }
    }
    
    class func shareShowActionSheet(model:ZMDSupplyProduct,view:UIView) {
        /*let imageView = UIImageView()
        imageView.sd_setImageWithURL(NSURL(string: ""), placeholderImage: UIImage(named: "ksnongte_icon")) { (image, error, cacheType, imageUrl) -> Void in
            let shareParams = NSMutableDictionary()
            shareParams.SSDKSetupShareParamsByText(model.Description, images: [image], url: NSURL(string: "http://ksnongpi.com/Plugins/SmartStore.SupplyDemand/Detail?id="+"\(model.Id.integerValue)"), title: model.Title, type: SSDKContentType.Auto)
            
            //分享(可以弹出我们的分享菜单和编辑按钮)
            let sheet : SSUIShareActionSheetController = ShareSDK.showShareActionSheet(view, items: nil /*[SSDKPlatformType.SubTypeWechatTimeline,SSDKPlatformType.SubTypeWechatSession,SSDKPlatformType.SubTypeQQFriend,SSDKPlatformType.SubTypeQZone,SSDKPlatformType.TypeSinaWeibo]*/, shareParams: shareParams, onShareStateChanged: { (state, platformType, userData, contentEntity, error, end) -> Void in
                
                switch state {
                case SSDKResponseState.Success:
                    break
                case SSDKResponseState.Fail:
                    break
                default:
                    break
                }
            })
            sheet.directSharePlatforms.addObject(SSDKPlatformType.TypeSinaWeibo as! AnyObject)
        }*/
        
        let shareParams = NSMutableDictionary()
        let image : UIImage = UIImage(named: "ksnongte_icon")!
        shareParams.SSDKSetupShareParamsByText(model.Description, images: [image], url: NSURL(string: "http://ksnongpi.com/Plugins/SmartStore.SupplyDemand/Detail?id="+"\(model.Id.integerValue)"), title: model.Title, type: SSDKContentType.Auto)
        
        //分享(可以弹出我们的分享菜单和编辑按钮)
        ShareSDK.showShareActionSheet(view, items: nil /*[SSDKPlatformType.SubTypeWechatTimeline,SSDKPlatformType.SubTypeWechatSession,SSDKPlatformType.SubTypeQQFriend,SSDKPlatformType.SubTypeQZone,SSDKPlatformType.TypeSinaWeibo]*/, shareParams: shareParams, onShareStateChanged: { (state, platformType, userData, contentEntity, error, end) -> Void in
            
            switch state {
            case SSDKResponseState.Success:
                break
            case SSDKResponseState.Fail:
                break
            default:
                break
            }
        })
    }
    
}
