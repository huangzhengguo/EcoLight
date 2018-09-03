//
//  EditAutoModeView.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/3.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//  编辑自动模式视图
//

import UIKit

class EditAutoModeView: UIView, UITableViewDelegate, UITableViewDataSource {
    let timePointTableView: UITableView = UITableView()
    let timePointDatePicker: UIDatePicker = UIDatePicker()
    let deleteTimePointBtn: UIButton = UIButton()
    let saveBtn: UIButton = UIButton()
    let cancelBtn: UIButton = UIButton()
    var manualSliderView: ManualSliderView?
    var parameterModel: DeviceParameterModel?
    
    init(frame: CGRect, parameterModel: DeviceParameterModel) {
        super.init(frame: frame)
        
        self.parameterModel = parameterModel
        
        // 时间点列表
//        let timePointTableViewLayouts: [NSLayoutConstraint] = [NSLayoutConstraint(item: self.timePointTableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)]
        
        self.timePointTableView.delegate = self
        self.timePointTableView.dataSource = self
        // self.timePointTableView.frame = CGRect(x: 0, y: 0, width: 50.0, height: self.frame.size.height)
//        self.timePointTableView.addConstraints(timePointTableViewLayouts)
        
        self.addSubview(self.timePointTableView)
        
        // 时间点
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        self.timePointDatePicker.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        
        self.addSubview(self.timePointDatePicker)
        
        // 删除按钮
        self.deleteTimePointBtn.frame = CGRect(x: 0, y: 0, width: 50.0, height: 30.0)
        
        self.addSubview(self.deleteTimePointBtn)
        
        // 滑动条
        self.manualSliderView = ManualSliderView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), colorArray: nil, colorTitleArray: nil, colorPercentArray: nil)
        
        self.addSubview(self.manualSliderView!)
        
        // 保存按钮
        self.saveBtn.frame = CGRect(x: 0, y: 0, width: 50.0, height: 30.0)
        
        self.addSubview(self.saveBtn)
        
        // 取消按钮
        self.cancelBtn.frame = CGRect(x: 0, y: 0, width: 50.0, height: 30.0)
        
        self.addSubview(self.cancelBtn)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.parameterModel?.timePointNum)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = self.parameterModel?.timePointArray[indexPath.row]
        
        return cell!;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
