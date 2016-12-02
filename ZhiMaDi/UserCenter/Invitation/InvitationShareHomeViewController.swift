//
//  InvitationShareHomeViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/14.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 邀请好友注册
class InvitationShareHomeViewController:UIViewController,UITableViewDataSource, UITableViewDelegate,QNShareViewDelegate,ZMDInterceptorProtocol,ZMDInterceptorMoreProtocol {
    enum Celltype {
        case Link
        case Code
        var title : String {
            switch self {
            case Link:
                return "链接邀请"
            case Code:
                return "二维码邀请"
            }
        }
        var detailTitle : String {
            switch self {
            case Link:
                return "好友打开链接下载葫芦堡APP客户端，并注册完成的，双方即可获得10元元门槛优惠券。"
            case Code:
                return "好友扫描或长按识别二维码，下载葫芦堡APP客户端，并注册完成的，双方即可获得10元元门槛优惠券。"
            }
        }
        var img : UIImage {
            switch self {
            case Link:
                return UIImage(named: "user_share_link")!
            case Code:
                return UIImage(named: "user_share_QRcode")!
            }
        }
        
    }
    var currentTableView: UITableView!
    var cellTypes = [Celltype.Link,.Code]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subViewInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: QNShareViewDelegate
    func qnShareView(view: ShareView) -> (image: UIImage, url: String, title: String?, description: String)? {
        return (UIImage(named: "Share_Icon")!, "http://www.baidu.com", self.title ?? "", "成为喜特用户，享有更多服务!")
    }
    func present(alert: UIAlertController) -> Void {
        self.presentViewController(alert, animated: false, completion: nil)
    }
    //MARK:- UITableViewDataSource,UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cellTypes.count
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 134
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 16))
        headView.backgroundColor = UIColor.clearColor()
        return headView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "OtherCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
            cell!.selectionStyle = .None
            
            ZMDTool.configTableViewCellDefault(cell!)
            var tag = 1000
            let titleLbl = ZMDTool.getLabel(CGRect(x: 108, y: 24, width: 100, height:17), text: "", fontSize: 17)
            titleLbl.tag = tag++
            cell?.contentView.addSubview(titleLbl)
            
            let detailTitleLbl = ZMDTool.getLabel(CGRect(x: 108, y: 50, width: kScreenWidth-108-12, height:70), text: "aa", fontSize: 15,textColor: defaultDetailTextColor)
            detailTitleLbl.numberOfLines = 0
            detailTitleLbl.tag = tag++
            cell?.contentView.addSubview(detailTitleLbl)
            
            let imgV = UIImageView(frame: CGRect(x: kScreenWidth-12-10, y: 25, width: 10, height: 16))
            imgV.image = UIImage(named: "common_forward")
            cell?.contentView.addSubview(imgV)
        }
        var tag = 1000
        let titleLbl = cell?.viewWithTag(tag++) as! UILabel
        let detailTitleLbl = cell?.viewWithTag(tag++) as! UILabel

        let type = self.cellTypes[indexPath.section]
        titleLbl.text = type.title
        detailTitleLbl.text = type.detailTitle
        cell?.imageView?.image = type.img
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let type = self.cellTypes[indexPath.section]
        switch type {
        case .Link :
            let shareView = ShareView()
            shareView.delegate = self
            shareView.showShareView()
            break
        case .Code :
            let vc = InvitatinCodeViewController.CreateFromMainStoryboard() as! InvitatinCodeViewController
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
    //MARK: -  PrivateMethod
    private func subViewInit(){
        self.title = "邀请好友注册"
        self.currentTableView = UITableView(frame: self.view.bounds)
        self.currentTableView.backgroundColor = tableViewdefaultBackgroundColor
        self.currentTableView.separatorStyle = .None
        self.currentTableView.dataSource = self
        self.currentTableView.delegate = self
        self.view.addSubview(self.currentTableView)
    }
}
