//
//  EnterpirseListViewController.swift
//  ZhiMaDi
//
//  Created by admin on 16/12/14.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class EnterpirseListViewController: UIViewController,ZMDInterceptorProtocol,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var currentTableView : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        // Do any additional setup after loading the view.
    }

    
    //MARK: - PrivateMethod
    func initUI() {
        self.title = "交易企业"
        
        self.viewForSelect()
    }
    func viewForSelect() {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 46))
        let width = zoom(144)
        let btnWidth = zoom(36)
        let left = zoom(10)
        for i in 0..<2 {
            let label = ZMDTool.getLabel(CGRect(x: left, y: 0, width: width, height: 44), text: "行业: 不限", fontSize: 15, textColor: defaultDetailTextColor, textAlignment: .Center)
        }
    }
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return zoom(12)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: zoom(12)))
        view.backgroundColor = tableViewdefaultBackgroundColor
        return view
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? 240 : 56
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.cellForImageCell(tableView,indexPath:indexPath)
        }else{
            return self.cellForBotCell(tableView,indexPath:indexPath)
        }
    }
    
    //MARK: - TableViewCell
    func cellForImageCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "imageCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        let titleLbl = cell?.contentView.viewWithTag(10000) as! UILabel
        let mainLbl = cell?.contentView.viewWithTag(10001) as! UILabel
        let countLbl1 = cell?.contentView.viewWithTag(10002) as! UILabel
        let countLbl2 = cell?.contentView.viewWithTag(10003) as! UILabel
        let detailBtn = cell?.contentView.viewWithTag(10004) as! UIButton
        let scrollView = cell?.contentView.viewWithTag(10005) as! UIScrollView

        detailBtn.rac_command = RACCommand(signalBlock: { (sender) -> RACSignal! in
            let vc = EnterpriseDetailViewController.CreateFromMainStoryboard() as! EnterpriseDetailViewController
            self.pushToViewController(vc, animated: true, hideBottom: true)
            return RACSignal.empty()
        })
        return cell!
    }
    func cellForBotCell(tableView:UITableView, indexPath:NSIndexPath) -> UITableViewCell {
        let cellId = "botCell"
        var  cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
            ZMDTool.configTableViewCellDefault(cell!)
            
            let btn = ZMDTool.getButton(CGRect(x: (kScreenWidth-82)/2, y: 12, width: 82, height: 32), textForNormal: "进入店铺", fontSize: 15, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                //...
            })
            cell?.contentView.addSubview(btn)
        }
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
