//
//  ShareView.swift
//  QooccHealth
//
//  Created by 肖小丰 on 15/5/8.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit

/**
*  // MARK: - 分享页面的数据回调
*/
protocol QNShareViewDelegate : NSObjectProtocol {
    // MARK: 分享的数据回调
    func qnShareView(view: ShareView) -> (image: UIImage, url: String, title: String?, description: String)?
    //分享成功显示alertView
    func present(alert: UIAlertController) -> Void
}


/**
*  @author 肖小丰, 15-05-08
*
*  // MARK: - 分享的View
*/
class ShareView: UIView ,UICollectionViewDelegate, UICollectionViewDataSource{
    
    weak var delegate: QNShareViewDelegate?

    enum shareType {
        
    }
    
    private  var shareViewHeight:CGFloat = 280.0
    private  var shareCollectionViewHeight:CGFloat = 180.0
    private  let itemHeight:CGFloat = 80.0
    private  let itemWidth:CGFloat = 60.0
    private  let cellIdentifier = "shareCellIdentifier"

    private(set) var  bgView:UIView?
    private(set) var  shareCollectionView:UICollectionView?

    private  var titileArray = [String]()
    private  var pictureArray = [String]()
    private  var shareTypeArray = [Int]()

    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, kScreenWidth ,kScreenHeight))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.28)
        
        let shareAdd = { (title: String, imageName: String, type: Int) -> Void in
            self.titileArray.append(title)
            self.pictureArray.append(imageName)
            self.shareTypeArray.append(type)
        }
        self.titileArray.removeAll(keepCapacity: false)
        self.pictureArray.removeAll(keepCapacity: false)
        self.shareTypeArray.removeAll(keepCapacity: false)
        
    //判断是否安装客户端再是否显示shareItem
//        if WXApi.isWXAppInstalled() {
//            shareAdd("朋友圈", "Share_WXFriends", 23)
//            shareAdd("微信好友", "Share_WX", 22)
//        }
//        
//        if TencentOAuth.iphoneQQInstalled() {
//            shareAdd("QQ好友", "Share_QQ", 24)
//            shareAdd("QQ空间", "Share_QQSpace", 6)
//        }
//
//        if WeiboSDK.isWeiboAppInstalled() {
//            shareAdd("新浪微博", "Share_Sina", 1)
//            shareAdd("腾讯微博", "Share_TXWeibo", 2)
//        }
        
        shareAdd("朋友圈","Share_WXFriends",23)
        shareAdd("微信好友","Share_WX",22)
        
        shareAdd("QQ好友","Share_QQ",24)
        shareAdd("QQ空间","Share_QQSpace",6)
        
        shareAdd("新浪微博", "Share_Sina", 1)
        shareAdd("腾讯微博", "Share_TXWeibo", 2)
        
        shareAdd("邮件", "Share_Email", 18)
        shareAdd("短信", "Share_SMS", 19)
        shareAdd("复制链接","common_share_link",1000)
        //如果在iphone6以上一行最多5个
        if (self.frame.size.width > 320 && self.titileArray.count <= 5) || (self.frame.size.width <= 320 && self.titileArray.count <= 4){
            // 一行
            self.shareViewHeight = 190.0
            self.shareCollectionViewHeight = 90.0
        }
        
        self.bgView = UIView(frame: CGRectMake(0, frame.size.height, frame.size.width, shareViewHeight))
        self.bgView!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.bgView!)
        
        let leftLine = UIView(frame: CGRectMake(10, 30, 100 , 1))
        leftLine.backgroundColor = defaultLineColor
        self.bgView?.addSubview(leftLine)
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 100, 60))
        titleLabel.center = CGPointMake(self.frame.size.width/2, 30)
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.textColor = UIColor(white: 21.0/255.0, alpha: 1)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "分享到"
        self.bgView?.addSubview(titleLabel)
        
        let rightLine = UIView(frame: CGRectMake(kScreenWidth - 110, 30, 100 , 1))
        rightLine.backgroundColor = defaultLineColor
        self.bgView?.addSubview(rightLine)
        
        // 内容展示
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        let shareCollectionView = UICollectionView(frame: CGRectMake(0, 50, self.frame.size.width, self.shareCollectionViewHeight), collectionViewLayout: flowLayout)
        shareCollectionView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , .FlexibleHeight]
        shareCollectionView.backgroundColor = UIColor.clearColor()
        shareCollectionView.registerClass(UICollectionViewCell().classForCoder, forCellWithReuseIdentifier: cellIdentifier)
        shareCollectionView.delegate = self
        shareCollectionView.dataSource = self
        self.shareCollectionView = shareCollectionView
        self.bgView?.addSubview(self.shareCollectionView!)
        
        let  cancelButton = UIButton(frame: CGRectMake(0, self.bgView!.frame.size.height - 40, self.bgView!.frame.size.width, 40))
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = defaultLineColor.CGColor
        cancelButton.setTitle("取消", forState: UIControlState.Normal)
        cancelButton.setTitleColor(appThemeColor, forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "disMissShareView", forControlEvents: UIControlEvents.TouchUpInside)
        self.bgView?.addSubview(cancelButton)
        
    }
    
    //MARK: Touch Event
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = (touches as NSSet).anyObject() as? UITouch {
            let point = touch.locationInView(self)
            //点击shareView外边区域，dismissShareView
            if !CGRectContainsPoint(self.bgView!.frame, point) { //判断点的位置，好用
                self.disMissShareView()
            }
        }
    }

    //MARK: UICollectionViewDelegate or DataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titileArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.shareCollectionView!.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
        let itemButton = UIButton(frame: CGRectMake(0, 0, 60, 60))
        itemButton.userInteractionEnabled = false
        itemButton.setImage(UIImage(named: self.pictureArray[indexPath.row]), forState: UIControlState.Normal)
        itemButton.contentMode = UIViewContentMode.ScaleAspectFit
        
        let titleLabel = UILabel(frame: CGRectMake(0, cell.bounds.size.height - 20, cell.bounds.size.width, 20))
        titleLabel.userInteractionEnabled = true
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor(white: 21.0/255.0, alpha: 1)
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.text = self.titileArray[indexPath.row]
        cell.addSubview(titleLabel)
        cell.addSubview(itemButton)
        
        let selectBg = UIView()
        selectBg.backgroundColor = UIColor(white: 240.0/255.0, alpha: 1)
        cell.selectedBackgroundView = selectBg

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 10, 5, 10)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.shareCollectionView!.deselectItemAtIndexPath(indexPath, animated: true)
        self.share(indexPath.row)
    }
    
    //MARK: 显示
    func showShareView() {
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.window?.addSubview(self)
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.bgView?.frame
            frame!.origin.y = kScreenHeight - self.shareViewHeight
            self.bgView?.frame = frame!
        })
    }
    
    //MARK: 隐藏
    func disMissShareView() {
        UIView.animateWithDuration(0.38, animations: { () -> Void in
            var frame = self.bgView?.frame
            frame!.origin.y = kScreenHeight
            self.bgView?.frame = frame!
            self.alpha = 0
            }) { (finish) -> Void in
                self.removeFromSuperview()
        }
    }
    
    //MARK: 分享
    // 调用此方法前，一定要保证 index 的正确性
    private func share(index: Int) {
        if let data = self.delegate?.qnShareView(self) {
            let image = data.image
            let url = data.url
            let title = data.title!
            let description = data.description
            
            //设置分享参数
            let shareParames = NSMutableDictionary()
            shareParames.SSDKSetupShareParamsByText("葫芦堡",
                images : image,
                url : NSURL(string: url),
                title : title,
                type : SSDKContentType.Auto)

            //复制链接
            if self.shareTypeArray.count == index+1 {
                let tmp = UIPasteboard()
                tmp.string = url
            } else if url != "" {
                let shareType = self.shareTypeArray[index]
                self.disMissShareView()
                if (shareType == 4/*ShareTypeSinaWeibo*/) && ShareSDK.hasAuthorized(SSDKPlatformType.TypeSinaWeibo) { // 新浪微博需要UI提示
                    ZMDTool.showActivityView("正在分享...", inView: nil, 3)
                }
                
                shareParames.SSDKEnableUseClientShare()     //允许通过客户端分享
                
                //开始分享
                var sharePlatformType: SSDKPlatformType!
                switch index {
                case 0:
                    sharePlatformType = SSDKPlatformType.TypeWechat
                    break
                case 1:
                    sharePlatformType = SSDKPlatformType.SubTypeWechatSession
                    shareParames.SSDKSetupWeChatParamsByText(description, title: title, url: NSURL(string: url), thumbImage: image, image: image, musicFileURL: nil, extInfo: nil, fileData: nil, emoticonData: nil, type: .Auto, forPlatformSubType: .SubTypeWechatSession)
                    break
                case 2:
                    sharePlatformType = SSDKPlatformType.TypeQQ
                    break
                case 3:
                    sharePlatformType = SSDKPlatformType.SubTypeQZone
                    break
                case 4:
                    sharePlatformType = SSDKPlatformType.TypeSinaWeibo
                    shareParames.SSDKSetupSinaWeiboShareParamsByText(description, title: title, image: image, url: NSURL(string: url), latitude: 0, longitude: 0, objectID: nil, type: .Auto)
                    break
                case 5:
                    sharePlatformType = SSDKPlatformType.TypeTencentWeibo
                    break
                case 6:
                    sharePlatformType = SSDKPlatformType.TypeMail
                    break
                case 7:
                    sharePlatformType = SSDKPlatformType.TypeSMS
                    break
                case 8:
                    sharePlatformType = SSDKPlatformType.TypeCopy
                    break
                default: 
                    break
                }

                ShareSDK.share(sharePlatformType, parameters: shareParames) { (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
                
                    switch state{
                        
                    case SSDKResponseState.Success:
                        print("分享成功")
                    let alert = UIAlertController(title: "分享成功", message: "分享成功", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.delegate?.present(alert)
                    case SSDKResponseState.Fail:    print("分享失败,错误描述:\(error)")
                    case SSDKResponseState.Cancel:  print("分享取消")
                        
                    default:
                        break
                    }
                }
                
            }
            
        }
    }
}
