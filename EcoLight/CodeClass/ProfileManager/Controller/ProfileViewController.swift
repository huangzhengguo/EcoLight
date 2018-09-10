//
//  ProfileViewController.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/8.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var datasource: [DeviceParameterModel]?
    var parameterModel: DeviceParameterModel?
    var currentProfileIndex = 0
    var confirmBlock: ((DeviceParameterModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.datasource = ArchiveHelper.unarchiveProfile(documentPath: ArchiveHelper.getUserDocumentPath(profile: ArchiveHelper.profileName), modelKey: (self.parameterModel?.modelKey)!)
        
        // Do any additional setup after loading the view.
        self.setViews()
    }
    
    override func setViews() -> Void {
        super.setViews()
        
        self.view.backgroundColor = UIColor.white
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        // 布局三个按钮:移除，取消，加载
        let bottomViewFrame = CGRect(x: 0, y: (self.view.frame.size.height) - 50, width: self.view.frame.size.width, height: 70)
        let bottomView = LayoutToolsView(viewNum: 3, viewWidth: 70, viewHeight: 40, viewInterval: 10, viewTitleArray: [self.languageManager.getTextForKey(key: "remove"), self.languageManager.getTextForKey(key: "cancel"), self.languageManager.getTextForKey(key: "confirm")], frame: bottomViewFrame)
        
        bottomView.buttonActionCallback = {
            (button, index) -> Void in
            switch index {
            case 0:
                // 移除选择的配置
                let alertController = UIAlertController.init(title: "title", message: "message", preferredStyle: .alert)
                
                self.present(alertController, animated: true, completion: nil)
            case 1:
                // 取消
                self.dismiss(animated: true, completion: nil)
            case 2:
                // 加载配置
                if self.confirmBlock != nil {
                    let model = self.datasource![self.currentProfileIndex]
                    self.confirmBlock!(model)
                }
                
                self.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
        
        self.view.addSubview(bottomView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        
        cell.selectionStyle = .none
        if indexPath.row == self.currentProfileIndex {
            cell.selectBtn.isSelected = true
        } else {
            cell.selectBtn.isSelected = false
        }
        
        let model = self.datasource![indexPath.row]
        
        cell.nameLabel.text = model.fileName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentProfileIndex = indexPath.row
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
