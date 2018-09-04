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
    let addTimePointBtn: UIButton = UIButton()
    let deleteTimePointBtn: UIButton = UIButton()
    let saveBtn: UIButton = UIButton()
    let cancelBtn: UIButton = UIButton()
    var manualSliderView: ManualSliderView?
    var parameterModel: DeviceParameterModel?
    var deviceCodeInfo: DeviceCodeInfo?
    var currentTimePointIndex = 0
    let dateFormatter: DateFormatter = DateFormatter()
    typealias NoneParameterBlock = () -> Void
    var timePointValueChangedBlock: NoneParameterBlock?
    var timePointColorValueChangedBlock: NoneParameterBlock?
    var addTimePointBlock: NoneParameterBlock?
    var deleteTimePointBlock: NoneParameterBlock?
    var cancelSaveBlock: NoneParameterBlock?
    var saveBlock: NoneParameterBlock?
    
    init(frame: CGRect, parameterModel: DeviceParameterModel) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 0.0 / 255.0, green: 149.0 / 189.0, blue: 200.0 / 255.0, alpha: 1.0)
        self.parameterModel = parameterModel
        
        // 时间点列表
        self.timePointTableView.delegate = self
        self.timePointTableView.dataSource = self
        self.timePointTableView.frame = CGRect(x: 20, y: 50, width: self.frame.size.width / 5.0, height: self.frame.size.height - 50)
        self.timePointTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.timePointTableView.backgroundColor = UIColor.clear
        self.timePointTableView.separatorStyle = .none
        
        self.addSubview(self.timePointTableView)
        
        // 增加删除按钮
        self.addTimePointBtn.frame = CGRect(x: self.timePointTableView.frame.size.width / 9.0, y: 0, width: self.timePointTableView.frame.size.width / 3.0, height: 30.0)
        self.addTimePointBtn.tag = 10001;
        self.addTimePointBtn.center = CGPoint(x: self.addTimePointBtn.center.x, y: 25.0)
        self.addTimePointBtn.setTitle("增加", for: .normal)
        self.addTimePointBtn.setTitleColor(UIColor.white, for: .normal)
        self.addTimePointBtn.backgroundColor = UIColor.green
        self.addTimePointBtn.layer.cornerRadius = 5.0
        self.addTimePointBtn.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
        
        self.addSubview(self.addTimePointBtn)
        
        self.deleteTimePointBtn.frame = CGRect(x: self.timePointTableView.frame.size.width * 5.0 / 9.0, y: 0, width: self.timePointTableView.frame.size.width / 3.0, height: 30.0)
        self.deleteTimePointBtn.tag = 10002;
        self.deleteTimePointBtn.center = CGPoint(x: self.deleteTimePointBtn.center.x, y: 25.0)
        self.deleteTimePointBtn.setTitle("删除", for: .normal)
        self.deleteTimePointBtn.setTitleColor(UIColor.white, for: .normal)
        self.deleteTimePointBtn.backgroundColor = UIColor.red
        self.deleteTimePointBtn.layer.cornerRadius = 5.0
        self.deleteTimePointBtn.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
        
        self.addSubview(self.deleteTimePointBtn)
        
        // 时间点
        self.dateFormatter.dateFormat = "HH:mm"
        
        let locale = Locale.init(identifier: "NL")
        
        let xCenter = self.timePointTableView.frame.origin.x + self.timePointTableView.frame.size.width + (self.frame.size.width - self.timePointTableView.frame.origin.x - self.timePointTableView.frame.size.width) / 2.0
        self.timePointDatePicker.frame = CGRect(x: xCenter, y: 0, width: self.frame.size.width - self.timePointTableView.frame.size.width - 20.0, height: 100.0)
        self.timePointDatePicker.center = CGPoint(x: xCenter, y: self.timePointDatePicker.center.y)
        self.timePointDatePicker.datePickerMode = .time
        self.timePointDatePicker.locale = locale
        self.timePointDatePicker.date = dateFormatter.date(from: (self.parameterModel?.timePointArray[0].convertHexTimeToFormatTime())!)!
        self.timePointDatePicker.addTarget(self, action: #selector(dateValueChanged(sender:)), for: .valueChanged)
        
        self.addSubview(self.timePointDatePicker)
        
        // 滑动条
        self.deviceCodeInfo = DeviceTypeData.getDeviceInfoWithTypeCode(deviceTypeCode: (self.parameterModel?.typeCode)!)
        let timeColorValue = self.parameterModel?.convertColorValue()
        self.manualSliderView = ManualSliderView(frame: CGRect(x: self.timePointTableView.frame.origin.x + self.timePointTableView.frame.size.width, y: 100.0, width: self.frame.size.width - self.timePointTableView.frame.origin.x - self.timePointTableView.frame.size.width, height: self.frame.size.height - 150.0), colorArray: self.deviceCodeInfo?.channelColorArray, colorTitleArray: self.deviceCodeInfo?.channelColorTitleArray, colorPercentArray: timeColorValue![currentTimePointIndex])
        
        self.manualSliderView?.passSliderValueCallback = {
            (colorIndex: Int, colorValue: Float) in
            self.parameterModel?.saveColorValueToModel(timePointIndex: self.currentTimePointIndex, colorIndex: colorIndex, colorValue: colorValue)
            
            // 更新模型
            if self.timePointColorValueChangedBlock != nil {
                self.timePointColorValueChangedBlock!()
            }
        }
        
        self.addSubview(self.manualSliderView!)
        
        // 保存按钮
        self.saveBtn.frame = CGRect(x: self.frame.size.width - 110.0, y: self.frame.size.height - 50, width: 50.0, height: 30.0)
        self.saveBtn.tag = 10003;
        self.saveBtn.setTitle("保存", for: .normal)
        self.saveBtn.setTitleColor(UIColor.white, for: .normal)
        self.saveBtn.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
        
        self.addSubview(self.saveBtn)
        
        // 取消按钮
        self.cancelBtn.frame = CGRect(x: self.frame.size.width - 60.0, y: self.frame.size.height - 50, width: 50.0, height: 30.0)
        self.cancelBtn.tag = 10004;
        self.cancelBtn.setTitle("取消", for: .normal)
        self.cancelBtn.setTitleColor(UIColor.white, for: .normal)
        self.cancelBtn.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
        
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
        
        if indexPath.row == self.currentTimePointIndex {
            cell?.backgroundColor = UIColor.red
        } else {
            cell?.backgroundColor = UIColor.clear
        }
        
        cell?.textLabel?.text = self.parameterModel?.timePointArray[indexPath.row].convertHexTimeToFormatTime()
        cell?.textLabel?.textAlignment = .center
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 显示对应时间点的信息
        self.currentTimePointIndex = indexPath.row
        
        tableView.reloadData()
        
        let timePoint = self.parameterModel?.timePointArray[indexPath.row].convertHexTimeToFormatTime()
        let timeColorValue = self.parameterModel?.convertColorValue()
        
        self.updateTimePointInfo(timePoint: timePoint!, colorPercentArray: timeColorValue![self.currentTimePointIndex])
    }
    
    ///
    /// - parameter timePoint: 时间点
    /// - parameter colorPercentArray: 时间点对应的颜色值
    ///
    /// - returns:
    func updateTimePointInfo(timePoint: String, colorPercentArray: [Double]) -> Void {
        self.timePointDatePicker.date = self.dateFormatter.date(from: timePoint)!
        
        self.manualSliderView?.updateManualSliderView(colorPercentArray: colorPercentArray)
    }
    
    @objc func btnAction(sender: UIButton) -> Void {
        let btnIndex = sender.tag - 10000
        if btnIndex == 1 {
            // 增加            
            if self.addTimePointBlock != nil {
                self.addTimePointBlock!()
            }
        } else if sender.tag == 2 {
            // 删除
            if self.deleteTimePointBlock != nil {
                self.deleteTimePointBlock!()
            }
        } else if sender.tag == 3 {
            // 取消
            if self.saveBlock != nil {
                self.saveBlock!()
            }
        } else if sender.tag == 4 {
            // 取消
            if self.cancelSaveBlock != nil {
                self.cancelSaveBlock!()
            }
        }
        
        self.removeFromSuperview()
    }
    
    @objc func dateValueChanged(sender: UIDatePicker) -> Void {
        let timePointStr = dateFormatter.string(from: sender.date).convertFormatTimeToHexTime()
        self.parameterModel?.timePointArray[self.currentTimePointIndex] = timePointStr
        
        let timePointValueStr = self.parameterModel?.timePointValueArray[self.currentTimePointIndex]
        
        // 调整时间点顺序
        while self.currentTimePointIndex > 0 && (String.converTimeStrToMinute(timeStr: timePointStr)! < String.converTimeStrToMinute(timeStr: self.parameterModel?.timePointArray[self.currentTimePointIndex - 1])!) {
            // 向前调整
            self.parameterModel?.timePointArray[self.currentTimePointIndex] = (self.parameterModel?.timePointArray[self.currentTimePointIndex - 1])!
            self.parameterModel?.timePointArray[self.currentTimePointIndex - 1] = timePointStr
            
            self.parameterModel?.timePointValueArray[self.currentTimePointIndex] = (self.parameterModel?.timePointValueArray[self.currentTimePointIndex - 1])!
            
            self.currentTimePointIndex = self.currentTimePointIndex - 1
        }
        
        while self.currentTimePointIndex < (self.parameterModel?.timePointArray.count)! - 1 && (String.converTimeStrToMinute(timeStr: timePointStr)! > String.converTimeStrToMinute(timeStr: self.parameterModel?.timePointArray[self.currentTimePointIndex + 1])!) {
            // 向后调整
            self.parameterModel?.timePointArray[self.currentTimePointIndex] = (self.parameterModel?.timePointArray[self.currentTimePointIndex + 1])!
            self.parameterModel?.timePointArray[self.currentTimePointIndex + 1] = timePointStr
            
            self.parameterModel?.timePointValueArray[self.currentTimePointIndex] = (self.parameterModel?.timePointValueArray[self.currentTimePointIndex + 1])!
            
            self.currentTimePointIndex = self.currentTimePointIndex + 1
        }
        
        self.parameterModel?.timePointValueArray[self.currentTimePointIndex] = timePointValueStr!
        
        self.timePointTableView.reloadData()
        
        if self.timePointValueChangedBlock != nil {
            self.timePointValueChangedBlock!()
        }
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
