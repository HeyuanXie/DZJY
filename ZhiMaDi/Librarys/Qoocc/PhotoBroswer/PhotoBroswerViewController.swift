//
//  PhotoBroswerViewController.swift
//  QooccHealth
//
//  Created by haijie on 15/12/10.
//  Copyright (c) 2015年 JuXi. All rights reserved.
//
//使用： 
// Create browser
/*let  browser = PhotoBroswerViewController(delegate: self)
browser.photos = strongSelf.photos.count
browser.setCurrentPhotoIndex(UInt((input as! UIButton).tag - 1))
browser.deleteImages = {(index)-> Void in
    strongSelf.photos.removeObjectAtIndex(index)
    strongSelf.tableView.reloadData()
}
strongSelf.navigationController?.pushViewController(browser, animated: true)
//MARK: - MWPhotoBrowserDelegate
func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(self.photos.count)
}
func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
    if Int(index) < self.photos.count {
        let dict = self.photos[Int(index)] as? NSDictionary
        let urlStr = dict!["ImageUrl"] as! String
        let photo:MWPhoto = MWPhoto(URL: NSURL(string: urlStr))
        return photo
    }
    return nil
}
func photoBrowserDidFinishModalPresentation(photoBrowser:MWPhotoBrowser) {
    self.dismissViewControllerAnimated(true, completion:nil)
}
*/
import UIKit
import ReactiveCocoa
import MWPhotoBrowser

class PhotoBroswerViewController: MWPhotoBrowser{
    var deleteImages: ((index:Int) -> Void)? // 删除图片的回掉
    var isDelete: Bool = false//设置是否显示删除按钮
    var photos = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let button:UIButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        button.setImage(UIImage(named: "btn_delete1")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            if let strongSelf = self {
                let actionSheet = UIActionSheet(title: "要删除这张图片吗?", delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
                actionSheet.addButtonWithTitle("删除")
                actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                    if index as! Int == 0 {
                        return
                    }
                    if strongSelf.deleteImages != nil {
                        let index = Int(strongSelf.currentIndex)
                        strongSelf.deleteImages!(index: index)
                        strongSelf.photos--
                        strongSelf.reloadData()
                        strongSelf.displayActionButton = false
                    }
                    if strongSelf.photos <= 0 {
                        self!.navigationController?.popViewControllerAnimated(true)
                    }
                })
                actionSheet.showInView(strongSelf.view)
            }
            return RACSignal.empty()
            });
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem?.customView?.hidden = isDelete
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()//navigationBackgroundColor
        self.navigationController?.navigationBar.tintColor = defaultTextColor//navigationTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: defaultTextColor, NSFontAttributeName: navigationTextFont]
        self.configBroswer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //MARK:-Private Method 
    func configBroswer() {
        self.displayActionButton = false  //分享按扭
        self.displayNavArrows = false
        self.displaySelectionButtons = false
        self.zoomPhotosToFill = true
        self.alwaysShowControls = false
        self.enableGrid = false
        self.startOnGrid = false
        self.enableSwipeToDismiss = false
    }
}
