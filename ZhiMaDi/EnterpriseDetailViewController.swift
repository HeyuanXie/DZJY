//
//  EnterpriseDetailViewController
//  ZhiMaDi
//
//  Created by admin on 16/12/14.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class EnterpriseDetailViewController: UIViewController,ZMDInterceptorProtocol,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var currentTableView : UITableView!
    
    var enterpriseId : NSInteger!
    var detailCellHeight : CGFloat = 270
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - PrivateMethod
    func initUI() {
        self.title = "企业详情"
        
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section >= 2 ? 1 : 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return zoom(12)
        }else if section == 2 {
            return !g_isLogin ? 34*kScreenWidth/375 : zoom(12)
        }else{
            return 0
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 && !g_isLogin {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 34*kScreenWidth/375))
            view.backgroundColor = RGB(253,246,216,1.0)
            let label = ZMDTool.getLabel(view.bounds, text: "点击登录,查看详细联系方式", fontSize: 14)
            label.textAlignment = .Center
            label.attributedText = label.text?.AttributedText("点击登录", color: appThemeColorNew)
            let btn = ZMDTool.getButton(view.bounds, textForNormal: "", fontSize: 0, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                let vc = LoginViewController.CreateFromLoginStoryboard() as! LoginViewController
                //                self.presentViewController(vc, animated: true, completion: nil)
                self.pushToViewController(vc, animated: true, hideBottom: true)
                //                ZMDTool.enterLoginViewController()
            })
            view.addSubview(label)
            view.addSubview(btn)
            return view
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(12)))
        view.backgroundColor = tableViewdefaultBackgroundColor
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return indexPath.row == 0 ? self.detailCellHeight : 48
        case 1:
            return indexPath.row == 0 ? 240 : 56
        default:
            return 52
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return indexPath.row == 0 ? self.cellForDetailCell(tableView,indexPath:indexPath) : self.cellForCertificate(tableView,indexPath:indexPath)
        case 1:
            return indexPath.row == 0 ? self.cellForImageCell(tableView, indexPath: indexPath) : self.cellForBotCell(tableView, indexPath: indexPath)
        default:
            return self.cellForDefaultCell(tableView, indexPath: indexPath)
        }
    }
    
    //MARK: - TableViewCell
    func cellForDetailCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "detailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        cell?.addLine()
        let imgView = cell?.contentView.viewWithTag(10000) as! UIImageView
        let nameLbl = cell?.contentView.viewWithTag(10001) as! UILabel
        let addressLbl = cell?.contentView.viewWithTag(10002) as! UILabel
        let detailLbl = cell?.contentView.viewWithTag(10003) as! UILabel
        let moreBtn = cell?.contentView.viewWithTag(10004) as! UIButton
        let moreLbl = cell?.contentView.viewWithTag(10005) as! UILabel
        cell?.contentView.bringSubviewToFront(moreLbl)
        cell?.contentView.bringSubviewToFront(moreBtn)
        let size = "阿斯顿发沙发沙发沙发沙发都是发放是短发是双方阿斯顿发沙发沙发沙发沙发都是发放是短发是短发是双斯顿发沙发阿斯顿发方阿斯顿发是双斯顿是双斯顿发沙发阿沙发沙发沙发都是发放是短发是短发是双斯顿发沙发阿斯顿发方阿斯顿发是双斯顿是双斯顿发沙发阿斯顿发顿发是双斯顿是双斯顿发沙发阿斯沙发沙发都是发放是短发是短发是双斯顿发沙发阿斯顿发方阿斯顿发是双斯顿是双斯顿发沙发阿沙发沙发沙发都是发放是短发是短发是双斯顿发沙发阿斯顿发方阿斯顿发是双斯顿是双斯顿发沙发阿斯顿发顿发是顿发方阿斯顿发顿发是双斯顿是双斯顿发沙发阿斯顿发方阿斯顿方阿斯顿发沙发发沙发阿斯顿发方阿斯顿发沙发沙发沙沙发沙发沙发沙发都是发放是短发是双方沙发沙发沙发都是发放是短发是双方".sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: kScreenWidth-16)
        if size.height <= 126 {
            moreBtn.hidden = true
            moreLbl.hidden = true
        }else{
            moreBtn.hidden = false
            moreLbl.hidden = false
        }
        moreBtn.setImage(UIImage(named: "btn_Arrow_TurnUp1"), forState: .Selected)
        moreBtn.setImage(UIImage(named: "btn_Arrow_TurnDown1"), forState: .Normal)
        moreBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            (sender as! UIButton).selected = !(sender as! UIButton).selected
            moreLbl.hidden = (sender as! UIButton).selected
            self.detailCellHeight = (sender as! UIButton).selected ? 270 + size.height - 125 : 270
            self.currentTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            return RACSignal.empty()
        })
        //更新UI
        
        
        return cell!
    }
    func cellForCertificate(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "certificateCell"
        var  cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            
            let btn = ZMDTool.getButton(CGRect(x: 0, y: 0, width: kScreenWidth, height: 48), textForNormal: "查看资质证书", fontSize: 13, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                //...
            })
            btn.setTitleColor(defaultDetailTextColor, forState: .Normal)
            cell?.contentView.addSubview(btn)
        }
        return cell!
    }
    func cellForImageCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "imageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        cell?.addLine()
        
        return cell!
    }
    func cellForBotCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "botCell"
        var  cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            
            let btn = ZMDTool.getButton(CGRect(x: (kScreenWidth-82)/2, y: 12, width: 82, height: 32), textForNormal: "进入店铺", fontSize: 15, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
                self.pushToViewController(vc, animated: true, hideBottom: true)
            })
            cell?.contentView.addSubview(btn)
        }
        return cell!
    }
    func cellForDefaultCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "defaultCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell?.addLine()
            ZMDTool.configTableViewCellDefault(cell!)
            
            let lbl = ZMDTool.getLabel(CGRect(x: 65, y: 0, width: kScreenWidth-65, height: 52), text: "", fontSize: 15, textColor: defaultTextColor, textAlignment: .Left)
            lbl.tag = 10000
            cell?.contentView.addSubview(lbl)
        }
        var titles = [("联系人","张三"),("手机号","15377679415"),("QQ号","11135353"),("微信号","就不告诉你")]
        cell?.textLabel?.text = titles[indexPath.section-2].0
        cell?.textLabel?.font = UIFont.systemFontOfSize(15)
        cell?.textLabel?.textColor = defaultDetailTextColor
        
        let lbl = cell?.contentView.viewWithTag(10000) as! UILabel
        lbl.text = titles[indexPath.section-2].1
        return cell!
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
