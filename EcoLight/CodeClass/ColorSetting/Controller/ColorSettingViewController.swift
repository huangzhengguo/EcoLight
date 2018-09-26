//
//  ColorSettingViewController.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/17.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import HGCircularSlider

class ColorSettingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var parameterModel: DeviceParameterModel?
    // 用来保存修改过的模型
    var editParameterModel: DeviceParameterModel?
    var manualAutoSwitchView: ManualAutoSwitchView?
    var manualModeView: UIView?
    var singleCircleSlider: CircularSlider?
    let stepper = UIStepper.init()
    let currentColorPercentLable = UILabel.init()
    var manualPowerButton: UIButton?
    var manualAutoViewFrame: CGRect?
    var deviceInfo: DeviceCodeInfo?
    var isShowSaveSuccessful: Bool! = true
    var quickPreviewTimer: Timer?
    var previewCount: Int! = 0
    var autoModeView: UIView?
    var plotView: PlotView?
    var timeCountArray: [Int]! = [Int]()
    var timeCountIntervalArray: [Int]! = [Int]()
    var previewButton: UIButton?
    var devcieName: String?
    let polotHeightRatio: CGFloat = 0.4
    var colorSegment = UISegmentedControl()
    // 时间点列表
    var timePointTableView: UITableView = UITableView()
    var isReceiveRespon = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /**
         * 布局划分
         * 1.手动和自动模式切换按钮
         * 2.手动界面
         * 3.自动界面
         */
        
        prepareData()
        setViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.cancelPreview()
    }
    
    override func prepareData() {
        super.prepareData()
        
        deviceInfo = DeviceTypeData.getLightInfoWithTypeCode(deviceTypeCode: (parameterModel?.typeCode)!, lightTypeCode: (parameterModel?.lightCode)!)
        
        self.blueToothManager.completeReceiveDataCallback = {
            (receivedDataStr, commandType) in
            // 收到完整数据后重新解析数据
            self.parameterModel?.parseDeviceDataFromReceiveStrToModel(receiveData: receivedDataStr!)
            self.parameterModel?.parameterModelCopy(parameterModel: self.editParameterModel!)
            
            if commandType == CommandType.SETTINGUSERDEFINED_COMMAND {
                // 把当前设置保存到设备
                self.showMessageWithTitle(title: self.languageManager.getTextForKey(key: "saveUserDefinedSuccessful"), time: 1.5, isShow: true)
            } else if commandType == CommandType.SETTINGAUTOMODE_COMMAND {
                // 设置自动模式数据
                self.showMessageWithTitle(title: self.languageManager.getTextForKey(key: "runSuccessful"), time: 1.5, isShow: true)
            } else if commandType == CommandType.SENDUSERDEFINED_COMMAND {
                // 把用户保存的设置发送到设备上
                self.showMessageWithTitle(title: self.languageManager.getTextForKey(key: "runSuccessful"), time: 1.5, isShow: true)
                
                // 更新圆盘
                self.updateCircleSlider(colorIndex: self.colorSegment.selectedSegmentIndex)
                
                // 更新中间百分比
                self.currentColorPercentLable.text = String.init(format: "%.2f%%", (self.singleCircleSlider?.endPointValue)! / CGFloat(GlobalInfo.maxColorValue) * 100.0)
                
                // 更新微调器值
                self.stepper.value = Double((self.singleCircleSlider?.endPointValue)!)
            } else if commandType == CommandType.MANUALSETTING_COMMAND {
                print("手动设置")
                self.isReceiveRespon = true
                
                // 更新颜色百分比
                let manualPercentArray = self.getManualColorPercentArray(parameterModel: self.parameterModel)
                let currentColorPercentStr = String.init(format: "%.2f%%", manualPercentArray[self.colorSegment.selectedSegmentIndex])
                
                self.currentColorPercentLable.text = currentColorPercentStr
            }
            
            // 更新界面
            self.setManualAutoViews()
        }
    }
    
    override func setViews() {
        super.setViews()
        self.title = self.devcieName!
        // 1.查找和重命名
        let findButton = UIButton(frame: CGRect(x: 0, y: 2, width: 40, height: 40))
        findButton.setImage(UIImage.init(named: "findDevice"), for: .normal)
        findButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        findButton.addTarget(self, action: #selector(findDeviceAction(sender:)), for: .touchUpInside)
        let findItem = UIBarButtonItem.init(customView: findButton)
        
        let renameButton = UIButton(frame: CGRect(x: 0, y: 2, width: 40, height: 40))
        renameButton.setImage(UIImage.init(named: "rename"), for: .normal)
        renameButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        renameButton.addTarget(self, action: #selector(renameDeviceAction(sender:)), for: .touchUpInside)
        let renameItem = UIBarButtonItem.init(customView: renameButton)
        
        self.navigationItem.rightBarButtonItems = [findItem,renameItem];
        
        // 2.手动自动切换按钮
        let manualAutoSwitchViewFrame = CGRect(x: 0, y: 72, width: 100, height: 50)
        manualAutoSwitchView = ManualAutoSwitchView(frame: manualAutoSwitchViewFrame, manualTitle: self.languageManager.getTextForKey(key: "manualMode"), autoTitle: self.languageManager.getTextForKey(key: "autoMode"))
        
        manualAutoSwitchView?.center = CGPoint(x: SystemInfoTools.screenWidth / 2, y: (manualAutoSwitchView?.center.y)!)
        
        manualAutoSwitchView?.manualModeAction = {
            self.cancelPreview()
            self.blueToothManager.sendManualModeCommand(uuid: (self.parameterModel?.uuid)!)
        }
        
        manualAutoSwitchView?.autoModeAction = {
            self.cancelPreview()
            self.blueToothManager.sendAutoModeCommand(uuid: (self.parameterModel?.uuid)!)
        }
        
        manualAutoViewFrame = CGRect(x: 0, y: (manualAutoSwitchView?.frame.origin.y)! + (manualAutoSwitchView?.frame.size.height)! + 8, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight - (manualAutoSwitchView?.frame.origin.y)! - (manualAutoSwitchView?.frame.size.height)! - 8)
        
        self.view.addSubview(manualAutoSwitchView!)
        
        setManualAutoViews()
    }
    
    @objc func findDeviceAction(sender: UIButton) -> Void {
        self.cancelPreview()
        self.blueToothManager.sendFindDeviceCommand(uuid: (self.parameterModel?.uuid)!)
    }
    
    @objc func renameDeviceAction(sender: UIButton) -> Void {
        self.cancelPreview()
//        let renameDeviceAlert = LGAlertView.init(textFieldsAndTitle: self.languageManager.getTextForKey(key: "rename"), message: "", numberOfTextFields: 1, textFieldsSetupHandler: nil, buttonTitles: [self.languageManager.getTextForKey(key: "cancel"), self.languageManager.getTextForKey(key: "confirm")], cancelButtonTitle: "", destructiveButtonTitle: "")
//
//        let nameTextField = renameDeviceAlert?.textFieldsArray[0] as! UITextField
//        nameTextField.textAlignment = .center
//        nameTextField.text = self.devcieName!
//
//        renameDeviceAlert?.actionHandler = {
//            (alertView, title, index) in
//            switch index {
//            case 0:
//                return
//            case 1:
//                let textField = alertView?.textFieldsArray[0] as! UITextField
//                // 1.同步到数据库
//                DeviceDataCoreManager.setDataWithFromTableWithCol(tableName: DeviceDataCoreManager.deviceTableName, colConditionName: DeviceDataCoreManager.deviceTableUuidName, colConditionVal: (self.parameterModel?.uuid)!, colName: DeviceDataCoreManager.deviceTableNameName, newColVal: textField.text!)
//
//                // 2.同步到设备
//                self.blueToothManager.setDeviceName(uuid: (self.parameterModel?.uuid)!, name: textField.text)
//
//                // 3.更改标题
//                self.title = textField.text
//                return
//            default:
//                return
//            }
//        }
//
//        renameDeviceAlert?.show(animated: true, completionHandler: nil)
    }
    
    func setManualAutoViews() -> Void {
        // 初始化临时模型
        if self.editParameterModel == nil {
            self.editParameterModel = DeviceParameterModel()
        }
        
        self.parameterModel?.parameterModelCopy(parameterModel: self.editParameterModel!)
        
        if parameterModel?.runMode == DeviceRunMode.MANUAL_RUN_MODE {
            print("当前运行模式手动！")
            manualAutoSwitchView?.updateManualAutoSwitchView(index: 0)
            setManualModeViews()
        } else {
            print("当前运行模式自动！")
            manualAutoSwitchView?.updateManualAutoSwitchView(index: 1)
            setAutoModeViews()
        }
    }
    
    func setManualModeViews() -> Void {
        if self.autoModeView != nil {
            // 隐藏自动模式界面
            self.autoModeView?.isHidden = true
        }

        if manualModeView == nil {
            // 创建手动模式视图
            manualModeView = UIView(frame: manualAutoViewFrame!)
            manualModeView?.backgroundColor = UIColor.clear
            
            // 1.圆形调光视图
            let manualColorViewFrame = CGRect(x: 0, y: 0, width: SystemInfoTools.screenWidth - 20, height: SystemInfoTools.screenWidth - 20)
            
            singleCircleSlider = CircularSlider.init(frame: manualColorViewFrame)
            
            manualModeView?.addSubview(singleCircleSlider!)
            
            singleCircleSlider?.center = CGPoint(x: (manualModeView?.center.x)!, y: (singleCircleSlider?.center.y)!)
            singleCircleSlider?.backgroundColor = UIColor.clear
            singleCircleSlider?.minimumValue = 0
            singleCircleSlider?.maximumValue = CGFloat(GlobalInfo.maxColorValue)
            singleCircleSlider?.lineWidth = 30.0
            self.updateCircleSlider(colorIndex: 0)
            
            singleCircleSlider?.addTarget(self, action: #selector(colorValueChanged(view:)), for: UIControlEvents.valueChanged)
            
            let centerLable = UILabel.init(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            
            centerLable.center = (singleCircleSlider?.center)!
            centerLable.isUserInteractionEnabled = true
            centerLable.backgroundColor = UIColor.lightGray
            centerLable.layer.cornerRadius = centerLable.frame.size.height / 2.0
            centerLable.layer.masksToBounds = true
            
            manualModeView?.addSubview(centerLable)
            
            // 圆环中间添加一个微调器
            self.stepper.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            self.stepper.tintColor = UIColor.white
            self.stepper.center = (singleCircleSlider?.center)!
            self.stepper.layer.zPosition = 10000
            self.stepper.maximumValue = Double((singleCircleSlider?.maximumValue)!)
            self.stepper.minimumValue = Double((singleCircleSlider?.minimumValue)!)
            self.stepper.value = Double((singleCircleSlider?.endPointValue)!)
            
            manualModeView?.addSubview(self.stepper)
            
            self.stepper.addTarget(self, action: #selector(stepperValueChanged(sender:)), for: .valueChanged)
            
            // 中间显示当前颜色百分比
            self.currentColorPercentLable.frame = CGRect(x: 0, y: 0, width: (centerLable.frame.size.height - self.stepper.frame.size.height) / 2.0, height: (centerLable.frame.size.height - self.stepper.frame.size.height) / 2.0)
            self.currentColorPercentLable.font = UIFont.systemFont(ofSize: 13)
            self.currentColorPercentLable.center = CGPoint(x: self.stepper.center.x, y: centerLable.center.y - self.currentColorPercentLable.frame.size.height / 2.0)
            self.currentColorPercentLable.layer.cornerRadius = self.currentColorPercentLable.frame.size.height / 2.0
            self.currentColorPercentLable.layer.masksToBounds = true
            self.currentColorPercentLable.backgroundColor = UIColor.lightGray
            self.currentColorPercentLable.textColor = UIColor.white
            self.currentColorPercentLable.textAlignment = .center
            self.currentColorPercentLable.text = String.init(format: "%.2f%%", (singleCircleSlider?.endPointValue)! / CGFloat(GlobalInfo.maxColorValue) * 100)
            
            manualModeView?.addSubview(self.currentColorPercentLable)
            
            // 2.用户自定义按钮
            let userDefineViewFrame = CGRect(x: 0, y: (manualAutoViewFrame?.height)! - 50, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight)
            let userDefineView = LayoutToolsView(viewNum: 3, viewWidth: 80, viewHeight: 40, viewInterval: 8, viewTitleArray: ["M1", "M2", "M3"], frame: userDefineViewFrame)
            userDefineView.buttonActionCallback = {
                (button, index) in
                var commandStr = CommandHeader.COMMANDHEAD_SIX.rawValue.appendingFormat("%02x", 0x02).appendingFormat("%02x", (self.parameterModel?.controllerChannelNum)! * 2)
                
                let userDefineStr:NSString = (self.parameterModel?.userDefinedValueArray[index])! as NSString
                for i in 0..<(self.parameterModel?.controllerChannelNum)! {
                    commandStr = commandStr.appending(String.invertColorValueToHexStr(colorValue: userDefineStr.substring(with: NSRange.init(location: i * 2, length: 2)).hexaToDecimal))
                }
                
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: .SENDUSERDEFINED_COMMAND, isXORCommand: true)
            }
            
            userDefineView.buttonLongPressCallback = {
                (index) in
                var commandStr = CommandHeader.COMMANDHEAD_SIX.rawValue.appendingFormat("%02x", 0x07 + index * (self.parameterModel?.controllerChannelNum)!).appendingFormat("%02x", (self.parameterModel?.controllerChannelNum)!)
                
                for i in 0..<(self.parameterModel?.controllerChannelNum)! {
                    commandStr = commandStr.appending((self.parameterModel?.manualModeValueArray[i])!)
                }
                
                self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.SETTINGUSERDEFINED_COMMAND, isXORCommand: true)
            }
            
            manualModeView?.addSubview(userDefineView)
            
            // 3.开关按钮
            let manualPowerButtonCenterY = (userDefineViewFrame.origin.y - manualColorViewFrame.origin.y - manualColorViewFrame.size.height) / 2.0
            manualPowerButton = UIButton(frame: CGRect(x: 0, y: manualColorViewFrame.origin.y + manualColorViewFrame.size.height + 8, width: 50, height: 50))
            manualPowerButton?.center = CGPoint(x: SystemInfoTools.screenWidth / 2.0, y: ((userDefineView.frame.origin.y) - manualPowerButtonCenterY))
            manualPowerButton?.setBackgroundImage(UIImage.init(named: "powerOff"), for: .normal)
            manualPowerButton?.setBackgroundImage(UIImage.init(named: "powerOn"), for: .selected)
            manualPowerButton?.addTarget(self, action: #selector(powerAction(sender:)), for: UIControlEvents.touchUpInside)
            if parameterModel?.powerState == DeviceState.POWER_ON {
                manualPowerButton?.isSelected = true
            } else {
                manualPowerButton?.isSelected = false
            }
            
            manualModeView?.addSubview(manualPowerButton!)
            
            // 4.颜色选择
            colorSegment.frame = CGRect(x: 0, y: (manualPowerButton?.frame.origin.y)! - 50, width: (manualModeView?.frame.size.width)! * 2.3 / 3.0, height: 30)
            colorSegment.center = CGPoint(x: (manualPowerButton?.center.x)!, y: colorSegment.center.y)
            colorSegment.layer.masksToBounds = true
            colorSegment.layer.cornerRadius = 5.0
            colorSegment.tintColor = UIColor.gray.withAlphaComponent(0.8)
            colorSegment.setTitleTextAttributes([kCTBackgroundColorAttributeName: UIColor.black], for: .normal)
            colorSegment.addTarget(self, action: #selector(colorSelectedAction(sender:)), for: .valueChanged)
            
            let manualPercentArray = getManualColorPercentArray(parameterModel: self.parameterModel)
            for i in 0..<(self.parameterModel?.channelNum)! {
                colorSegment.insertSegment(withTitle: String.init(format: "%.2f%%", manualPercentArray[i]), at: i, animated: false)
                
                colorSegment.subviews[i].backgroundColor = self.deviceInfo?.channelColorArray[i]
            }
        
            colorSegment.selectedSegmentIndex = 0
            
            self.manualModeView?.addSubview(colorSegment)

            self.view.addSubview(manualModeView!)
        } else {
            // 更新视图
            manualModeView?.isHidden = false
            // 更新百分比
            let manualPercentArray = getManualColorPercentArray(parameterModel: self.parameterModel)
            for i in 0..<manualPercentArray.count {
                colorSegment.setTitle(String.init(format: "%.2f%%", manualPercentArray[i]), forSegmentAt: i)
            }
        }
    }
    
    /// 从参数模型中获取用户百分比
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    func getManualColorPercentArray(parameterModel: DeviceParameterModel!) -> [Float] {
        var manualPercentArray = [Float]()
        
        for colorValue in (parameterModel?.manualModeValueArray)! {
            manualPercentArray.append(Float(colorValue.hexaToDecimal) / GlobalInfo.maxColorValue * 100.0)
        }
        
        return manualPercentArray
    }
    
    /// 开关方法
    /// - parameter sender: 触发点击的按钮
    ///
    /// - returns: Void
    @objc func powerAction(sender: UIButton) -> Void {
        sender.isSelected = !sender.isSelected
        if parameterModel?.powerState == DeviceState.POWER_ON {
            self.blueToothManager.sendPowerOffCommand(uuid: (parameterModel?.uuid)!)
            parameterModel?.powerState = DeviceState.POWER_OFF
        } else {
            self.blueToothManager.sendPowerOnCommand(uuid: (parameterModel?.uuid)!)
            parameterModel?.powerState = DeviceState.POWER_ON
        }
    }
    
    /// 颜色选择
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    @objc func colorSelectedAction(sender: UISegmentedControl) -> Void {
        print("选择了\(sender.selectedSegmentIndex)")
        
        // 更新圆盘
        self.updateCircleSlider(colorIndex: sender.selectedSegmentIndex)
        
        let manualPercentArray = getManualColorPercentArray(parameterModel: self.parameterModel)
        
        let currentColorPercentStr = String.init(format: "%.2f%%", manualPercentArray[sender.selectedSegmentIndex])
        
        self.currentColorPercentLable.text = currentColorPercentStr
        
        // 设置微调当前值
        self.stepper.value = Double(manualPercentArray[sender.selectedSegmentIndex]) * Double(GlobalInfo.maxColorValue) / 100.0
    }
    
    /// 圆环滑动
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    @objc func colorValueChanged(view: UIView) -> Void {
        let progressView: CircularSlider! = view as? CircularSlider

        self.sendColorValueToDevice(colorIndex: self.self.colorSegment.selectedSegmentIndex, colorValue: Int(progressView.endPointValue))
        
        self.stepper.value = Double(progressView.endPointValue)
    }
    
    @objc func stepperValueChanged(sender: UIStepper) -> Void {
        // 更改当前颜色值
        self.sendColorValueToDevice(colorIndex: self.self.colorSegment.selectedSegmentIndex, colorValue: Int(sender.value))
        
        self.singleCircleSlider?.endPointValue = CGFloat(sender.value)
    }
    
    func sendColorValueToDevice(colorIndex: Int, colorValue: Int) -> Void {
        if self.isReceiveRespon == false {
            return
        }
        
        self.isReceiveRespon = false
    
        let commandStr = CommandHeader.COMMANDHEAD_SIX.rawValue.appendingFormat("%02x", 0x02 + colorIndex * 2).appending("02").appending(String.invertColorValueToHexStr(colorValue: colorValue))
        
        self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.MANUALSETTING_COMMAND, isXORCommand: true)
    }
    
    func updateCircleSlider(colorIndex: Int) -> Void {
        let currentColor = (self.deviceInfo?.channelColorArray[colorIndex])!
        
        self.singleCircleSlider?.trackFillColor = UIColor.clear
        self.singleCircleSlider?.trackColor = UIColor.white
        self.singleCircleSlider?.diskColor = currentColor.withAlphaComponent(0.5)
        self.singleCircleSlider?.diskFillColor = currentColor
        self.singleCircleSlider?.trackShadowColor = currentColor.withAlphaComponent(0.5)
        self.singleCircleSlider?.endThumbStrokeColor = currentColor
        self.singleCircleSlider?.endThumbTintColor = UIColor.white
        
        let manualPercentArray = getManualColorPercentArray(parameterModel: self.parameterModel)
        
        self.singleCircleSlider?.endPointValue = CGFloat(manualPercentArray[colorIndex]) * CGFloat(GlobalInfo.maxColorValue) / 100.0 + 3.0
        self.singleCircleSlider?.endPointValue = CGFloat(manualPercentArray[colorIndex]) * CGFloat(GlobalInfo.maxColorValue) / 100.0
    }
    
    func setAutoModeViews() -> Void {
        if self.manualModeView != nil {
            self.manualModeView?.isHidden = true
        }
        
        if autoModeView == nil {
            // 创建自动模式视图
            autoModeView = UIView(frame: manualAutoViewFrame!)
            autoModeView?.backgroundColor = UIColor.clear
            
            // 1.自动模式曲线图
            let autoColorChartViewFrame = CGRect(x: 0, y: 0, width: (autoModeView?.frame.size.width)!, height: (autoModeView?.frame.size.height)! * self.polotHeightRatio)
            
            plotView = PlotView(frame: autoColorChartViewFrame)
            
            autoModeView?.addSubview(plotView!)
            
            plotView?.backgroundColor = UIColor.clear
            plotView?.lineColorArray = (deviceInfo?.channelColorArray)!
            plotView?.lineColorTitleArray = (deviceInfo?.channelColorTitleArray)!
            plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
            plotView?.yMaxValue = 1.0
            plotView?.yInterval = 0.25
            plotView?.drawPlotView()
            
            // 添加时间点列表
            self.timePointTableView.frame = CGRect(x: 0, y: (plotView?.frame.size.height)! + 5.0, width: (autoModeView?.frame.size.width)!, height: (autoModeView?.frame.size.height)! - 70 - (plotView?.frame.size.height)!)
            
            self.timePointTableView.delegate = self
            self.timePointTableView.dataSource = self
            self.timePointTableView.backgroundColor = UIColor.clear
            self.timePointTableView.isScrollEnabled = false
            self.timePointTableView.layer.borderWidth = 1.0
            self.timePointTableView.layer.borderColor = UIColor.lightGray.cgColor
            
            autoModeView?.addSubview(self.timePointTableView)
            
            // 2.底部按钮 预览 运行（发送设置的配置到设备）编辑
            let bottomViewFrame = CGRect(x: 0, y: (autoModeView?.frame.size.height)! - 50, width: SystemInfoTools.screenWidth, height: 70)
            let bottomView = LayoutToolsView(viewNum: 4, viewWidth: 70, viewHeight: 40, viewInterval: 10, viewTitleArray: [self.languageManager.getTextForKey(key: "import"), self.languageManager.getTextForKey(key: "export"), self.languageManager.getTextForKey(key: "preview"), self.languageManager.getTextForKey(key: "edit")], frame: bottomViewFrame)
            
            // 添加观察者
            previewButton = bottomView.viewWithTag(1003) as? UIButton
            
            bottomView.buttonActionCallback = {
                (button, index) -> Void in
                    if (index == 0) {
                        // 导入
                        let profileViewController = ProfileViewController.init(nibName: "ProfileViewController", bundle: nil)
                        
                        profileViewController.parameterModel = self.parameterModel
                        profileViewController.confirmBlock = {
                            (deviceModel) in
                            
                            self.settingAutoMode(deviceModel: deviceModel)
                        }
                        
                        self.present(profileViewController, animated: true, completion: nil)
                    } else if (index == 1) {
                        // 导出:保存模型到文件中
                        let alertController = UIAlertController.init(title: "导出文件", message: "导出到", preferredStyle: .alert)
                        
                        alertController.addTextField(configurationHandler: { (textField) in
                            
                        })
                        
                        let cancelAction = UIAlertAction.init(title: "取消", style: .default, handler: nil)
                        let confirmAction = UIAlertAction.init(title: "确认", style: .default, handler: { (alertAction) in
                            let fileName = alertController.textFields![0].text
                            
                            self.parameterModel?.fileName = fileName!
                            if ArchiveHelper.archiveProfile(model: self.parameterModel,profile: ArchiveHelper.profileName, modelKey:(self.parameterModel?.modelKey)!) == ArchiveHelper.SaveProfileErrorCode.SUCCESS_ERROR {
                                print("保存成功！")
                            } else {
                                print("保存失败！")
                            }
                        })
                        
                        alertController.addAction(cancelAction)
                        alertController.addAction(confirmAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else if (index == 2) {
                        // 1.预览功能
                        if button.titleLabel?.text == self.languageManager.getTextForKey(key: "preview") {
                            button.setTitle(self.languageManager.getTextForKey(key: "stop"), for: .normal)
                            self.beginPreview()
                        } else {
                            button.setTitle(self.languageManager.getTextForKey(key: "preview"), for: .normal)
                            self.cancelPreview()
                        }
                    } else if (index == 3) {
                        // 3.弹出编辑界面
                        let editAutoModeView = EditAutoModeView(frame: CGRect(x: 0, y: (self.autoModeView?.frame.size.height)!, width: (self.autoModeView?.frame.size.width)!, height: (self.autoModeView?.frame.size.height)! * (1.0 - self.polotHeightRatio)), parameterModel: self.editParameterModel!)
                        self.autoModeView?.addSubview(editAutoModeView)
                        
                        editAutoModeView.timePointValueChangedBlock = {
                            () in
                            self.plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
                            self.plotView?.refreshPlot()
                        }
                        
                        editAutoModeView.timePointColorValueChangedBlock = {
                            () in
                            self.plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
                            self.plotView?.refreshPlot()
                        }
                        
                        editAutoModeView.addTimePointBlock = {
                            () in
                            if (self.editParameterModel?.timePointNum)! >= 10 {
                                // 提示时间点已达上限
                                let maxTimePointAlertController = UIAlertController.init(title: self.languageManager.getTextForKey(key: "warning"), message: self.languageManager.getTextForKey(key: "maxTimePointNumWarn"), preferredStyle: .alert)
                                
                                let confirmAction = UIAlertAction.init(title: self.languageManager.getTextForKey(key: "confirm"), style: .default, handler: nil)
                                
                                maxTimePointAlertController.addAction(confirmAction)
                                
                                self.present(maxTimePointAlertController, animated: true, completion: nil)
                                
                                return
                            }
                            
                            let datePickerView = DateTimePickerView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                            
                            datePickerView.confirmBlock = {
                                (timeStr: String) in
                                // 找到指定位置插入时间点，并插入默认颜色值
                                let timeIndex = String.converTimeStrToMinute(timeStr: String.convertFormatTimeToHexTime(timeStr: timeStr))
                                var positionIndex = 0
                                for timePointStr in (self.editParameterModel?.timePointArray)! {
                                    if timeIndex! > String.converTimeStrToMinute(timeStr: timePointStr)! {
                                        positionIndex = positionIndex + 1
                                        continue
                                    }
                                }
                                
                                self.editParameterModel?.timePointNum = (self.editParameterModel?.timePointNum)! + 1
                                self.editParameterModel?.timePointArray.insert(String.convertFormatTimeToHexTime(timeStr: timeStr), at: positionIndex)
                                var defaultColorStr = ""
                                for _ in 0..<(self.editParameterModel?.channelNum)! {
                                    defaultColorStr.append("00")
                                }
                                
                                self.editParameterModel?.timePointValueArray.insert(defaultColorStr, at: positionIndex)
                                
                                // 刷新曲线图
                                self.plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
                                self.plotView?.refreshPlot()
                                
                                // 刷新时间点列表
                                editAutoModeView.currentTimePointIndex = positionIndex
                                editAutoModeView.timePointTableView.reloadData()
                            }
                            
                            self.view.addSubview(datePickerView)
                        }
                        
                        editAutoModeView.deleteTimePointBlock = {
                            (timePointIndex: Int) in
                            if (self.editParameterModel?.timePointNum)! <= 4 {
                                // 提示时间点已达下限
                                let maxTimePointAlertController = UIAlertController.init(title: self.languageManager.getTextForKey(key: "warning"), message: self.languageManager.getTextForKey(key: "minTimePointNumWarn"), preferredStyle: .alert)
                                
                                let confirmAction = UIAlertAction.init(title: self.languageManager.getTextForKey(key: "confirm"), style: .default, handler: nil)
                                
                                maxTimePointAlertController.addAction(confirmAction)
                                
                                self.present(maxTimePointAlertController, animated: true, completion: nil)
                                
                                return
                            }
                            
                            // 确认删除
                            let confirmDeleteTimePointAlertController = UIAlertController.init(title: self.languageManager.getTextForKey(key: "deleteTimePointTitle"), message: String.init(format: "%@: %@?", self.languageManager.getTextForKey(key: "confirmdeleteTimePointMessage"), String.convertHexTimeToFormatTime(hexTimeStr: (self.editParameterModel?.timePointArray[timePointIndex])!)), preferredStyle: .alert)
                            
                            let cancelDeleteAction = UIAlertAction.init(title: self.languageManager.getTextForKey(key: "cancel"), style: .default, handler: nil)
                            
                            let confirmDeleteAction = UIAlertAction.init(title: self.languageManager.getTextForKey(key: "confirm"), style: .default, handler: { (action) in
                                if timePointIndex == ((self.editParameterModel?.timePointNum)! - 1) {
                                    editAutoModeView.currentTimePointIndex = timePointIndex - 1
                                }
                                
                                self.editParameterModel?.timePointNum = (self.editParameterModel?.timePointNum)! - 1
                                self.editParameterModel?.timePointArray.remove(at: timePointIndex)
                                self.editParameterModel?.timePointValueArray.remove(at: timePointIndex)
                                
                                // 刷新曲线图
                                self.plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
                                self.plotView?.refreshPlot()
                                
                                // 刷新时间点列表
                                editAutoModeView.timePointTableView.reloadData()
                            })
                            
                            confirmDeleteTimePointAlertController.addAction(cancelDeleteAction)
                            confirmDeleteTimePointAlertController.addAction(confirmDeleteAction)
                            
                            self.present(confirmDeleteTimePointAlertController, animated: true, completion: nil)
                        }
                        
                        editAutoModeView.cancelSaveBlock = {
                            () in
                            
                            self.parameterModel?.parameterModelCopy(parameterModel: self.editParameterModel!)
                            self.plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
                            self.plotView?.refreshPlot()
                        }
                        
                        editAutoModeView.saveBlock = {
                            () in
                            
                            self.settingAutoMode(deviceModel: self.editParameterModel!)
                        }
                        
                        UIView.beginAnimations(nil, context: nil)
                        UIView.setAnimationDuration(1.0)
                        editAutoModeView.frame = CGRect(x: 0, y: (self.autoModeView?.frame.size.height)! * self.polotHeightRatio, width: editAutoModeView.frame.size.width, height: editAutoModeView.frame.size.height)
                        UIView.commitAnimations()
                    }
            }
            
            autoModeView?.addSubview(bottomView)
            
            self.view.addSubview(autoModeView!)
        } else {
            // 更新自动模式视图
            autoModeView?.isHidden = false
            self.plotView?.dataPointArray = (self.editParameterModel?.generateLinePoint())!
            self.plotView?.refreshPlot()
            self.timePointTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.editParameterModel?.timePointNum)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 10.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.textColor = UIColor.white
        cell?.selectionStyle = .none
        
        // 显示时间点及百分比
        cell?.textLabel?.text = String.init(format: "%ld   %@", indexPath.row + 1, String.convertHexTimeToFormatTime(hexTimeStr: (self.editParameterModel?.timePointArray[indexPath.row])!))
        for i in 0..<(self.editParameterModel?.channelNum)! {
            let percent = Float(((self.editParameterModel?.timePointValueArray[indexPath.row])! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexaToDecimal)
            cell?.textLabel?.text = String.init(format: "%10@ %5.0f%%", (cell?.textLabel?.text)!, percent)
        }
        
        return cell!
    }
    
    func settingAutoMode(deviceModel: DeviceParameterModel) -> Void {
        // 发送设置自动模式数据
        var commandStr = CommandHeader.COMMANDHEAD_SIX.rawValue.appending("20").appendingFormat("%02x", ((deviceModel.controllerChannelNum)! + 2) * (deviceModel.timePointNum)!).appendingFormat("%02x", (deviceModel.timePointNum)!);
        for i in 0..<(deviceModel.timePointNum)! {
            commandStr = commandStr.appending((deviceModel.timePointArray[i]))
            commandStr = commandStr.appending((deviceModel.timePointValueArray[i]))
        }
        
        self.blueToothManager.sendCommandToDevice(uuid: (deviceModel.uuid)!, commandStr: commandStr, commandType: CommandType.SETTINGAUTOMODE_COMMAND, isXORCommand: true, commandInterval: 2.0)
    }
    
    /// 开始预览功能
    ///
    /// - returns: Void
    func beginPreview() -> Void {
        previewCount = 0
        
        timeCountArray.removeAll()
        timeCountIntervalArray.removeAll()
        for (index, value) in (self.editParameterModel?.timePointArray.enumerated())! {
            timeCountArray.append(String.converTimeStrToMinute(timeStr: value)!)
            
            if index ==  ((self.editParameterModel?.timePointArray)!.count - 1) {
                timeCountIntervalArray.append(timeCountArray[index] - timeCountArray[index - 1])
                timeCountIntervalArray.append(timeCountArray[0] + 1440 - timeCountArray[index])
            } else if index > 0 {
                timeCountIntervalArray.append(timeCountArray[index] - timeCountArray[index - 1])
            }
        }
        
        quickPreviewTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(sendQuickPreviewCommand(timer:)), userInfo: nil, repeats: true)
    }
    
    /// 取消预览功能
    ///
    /// - returns: Void
    func cancelPreview() -> Void {
        self.plotView?.indicatorLabel.isHidden = true
        if quickPreviewTimer != nil {
            quickPreviewTimer?.invalidate()
            quickPreviewTimer = nil
            
            self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: CommandHeader.COMMANDHEAD_FIVE.rawValue, commandType: CommandType.ENDPREVIEW_COMMAND, isXORCommand: true)
        }

        // 设置按钮文本
        previewButton?.setTitle(self.languageManager.getTextForKey(key: "preview"), for: .normal)
    }
    
    /// 快速预览发送命令方法
    /// - parameter timer: 定时器
    ///
    /// - returns: Void
    @objc func sendQuickPreviewCommand(timer: Timer) -> Void {
        var commandStr = String(CommandHeader.COMMANDHEAD_FOUR.rawValue)
        
        // 更改指示器位置
        self.plotView?.changeIndicatorLabelPositionWithIndex(xIndex: previewCount)
        
        // 根据 previewCount 计算发送的数值
        commandStr.append((calculateColorValue(previewCount: previewCount)))
        self.blueToothManager.sendCommandToDevice(uuid: (self.parameterModel?.uuid)!, commandStr: commandStr, commandType: CommandType.UNKNOWN_COMMAND, isXORCommand: true)
        
        if Double(previewCount) >= 1439.0 {
            cancelPreview()
        }
        
        previewCount = previewCount + 2
    }
    
    /// 根据数值计算当前的颜色值
    /// - parameter previewCount: 当前点数
    ///
    /// - returns: 命令字符串
    func calculateColorValue(previewCount: Int!) -> String {
        var colorValueStr: String! = ""
        var previewColorValueStr: String! = ""
        var nextColorValueStr: String! = ""
        
        var index = 0
        var isInFirst = true
        var isInLast = true
        for i in 0 ..< timeCountArray.count {
            if previewCount <= timeCountArray[i] {
                if i == 0 {
                    previewColorValueStr = self.editParameterModel?.timePointValueArray[timeCountArray.count - 1]
                    nextColorValueStr = self.editParameterModel?.timePointValueArray[0]
                    index = i
                    isInFirst = true
                    isInLast = false
                    break
                } else if i <= (timeCountArray.count - 1) {
                    previewColorValueStr = self.editParameterModel?.timePointValueArray[i - 1]
                    nextColorValueStr = self.editParameterModel?.timePointValueArray[i]
                    index = i - 1
                    isInFirst = false
                    isInLast = false
                    break
                }
            } else if previewCount >= timeCountArray[timeCountArray.count - 1] && previewCount <= 1440 {
                previewColorValueStr = self.editParameterModel?.timePointValueArray[timeCountArray.count - 1]
                nextColorValueStr = self.editParameterModel?.timePointValueArray[0]
                index = timeCountArray.count - 1
                isInFirst = false
                isInLast = true
                break
            }
        }
        
        // 计算值
        var previewColorDoubleArray = previewColorValueStr.convertColorPercentStrToDoubleValue()
        var nextColorDoubleArray = nextColorValueStr.convertColorPercentStrToDoubleValue()
        for j in 0 ..< (self.editParameterModel?.channelNum)! {
            var percent = 0.0
            if isInFirst == true {
                percent = 1.0 + Double((previewCount - timeCountArray[index])) / Double(timeCountIntervalArray[timeCountIntervalArray.count - 1])
            } else if isInLast == true {
                percent = Double((previewCount - timeCountArray[index])) / Double(timeCountIntervalArray[timeCountIntervalArray.count - 1])
            } else {
                percent = Double((previewCount - timeCountArray[index])) / Double(timeCountIntervalArray[index])
            }
            
            let colorValue = previewColorDoubleArray[j] - ((previewColorDoubleArray[j] - nextColorDoubleArray[j])) * percent

            colorValueStr = colorValueStr.appending(String.invertColorValueToHexStr(colorValue: Int(colorValue)))
        }
        
        return colorValueStr
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
