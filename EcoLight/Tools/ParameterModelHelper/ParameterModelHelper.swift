//
//  ParameterModelHelper.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/31.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

extension DeviceParameterModel {   
    /// 解析新协议数据到模型中
    /// - parameter receiveData: 协议数据
    ///
    /// - returns: Void
    func parseDeviceDataFromReceiveStrToModel(receiveData: String) -> Void {
        // 解析参数模型数据
        var index = 0
        
        var commandCharacters: [Character]! = [Character]()
        for c in receiveData {
            commandCharacters.append(c)
        }
        
        // 解析命令帧头
        self.commandHeader.append(commandCharacters[index])
        self.commandHeader.append(commandCharacters[index + 1])
        
        // 解析命令码
        index = index + 2
        self.commandCode.append(commandCharacters[index])
        self.commandCode.append(commandCharacters[index + 1])
        
        // 直接赋值为5
        self.channelNum = 5
        self.controllerChannelNum = 5
        
        // 解析运行模式
        // 解析设备运行模式
        index = index + 2
        var runModeStr: String = ""
        runModeStr.append(commandCharacters[index])
        runModeStr.append(commandCharacters[index + 1])
        
        // 解析寄存器标记，数据开始地址
        index = index + 2
        self.registerAddr.append(commandCharacters[index])
        self.registerAddr.append(commandCharacters[index + 1])
        
        // 解析命令数据字节数
        index = index + 2
        var dataCountStr = ""
        dataCountStr.append(commandCharacters[index])
        dataCountStr.append(commandCharacters[index + 1])
        self.commandDataByteCount = dataCountStr.hexaToDecimal
        
        index = index + 2
        if runModeStr == "00" {
            // 清空数据源
            self.manualModeValueArray.removeAll()
            self.userDefinedValueArray.removeAll()
            
            // 手动模式
            self.runMode = DeviceRunMode.MANUAL_RUN_MODE
            
            // 解析开关状态
            var powerStateStr: String = ""
            powerStateStr.append(commandCharacters[index])
            powerStateStr.append(commandCharacters[index + 1])
            if powerStateStr == "00" {
                self.powerState = DeviceState.POWER_OFF
            } else if powerStateStr == "01" {
                self.powerState = DeviceState.POWER_ON
            } else {
                self.powerState = DeviceState.UNKNOWN_STATE
                return
            }
            
            // 解析手动模式
            index = index + 2
            var colorStr: String?
            for _ in 0..<self.controllerChannelNum! {
                colorStr = ""
                // 由于高位在后，需要先添加高位
                colorStr?.append(commandCharacters[index + 2])
                colorStr?.append(commandCharacters[index + 3])
                colorStr?.append(commandCharacters[index])
                colorStr?.append(commandCharacters[index + 1])
                
                self.manualModeValueArray.append(colorStr!)

                index = index + 4
            }

            // 解析用户自定义数据
            var userDefineColor = ""
            for i in 0..<4 {
                userDefineColor.removeAll()
                for j in 0..<self.controllerChannelNum! {
                    userDefineColor.append(commandCharacters[index + i * self.controllerChannelNum! * 2 + j * 2])
                    userDefineColor.append(commandCharacters[index + i * self.controllerChannelNum! * 2 + j * 2 + 1])
                }
                print("userDefineColor = " + userDefineColor)
                self.userDefinedValueArray.append(userDefineColor)
            }
        } else if runModeStr == "01" {
            // 自动模式
            self.runMode = DeviceRunMode.AUTO_RUN_MODE
            
            // 清空数据源
            self.timePointArray.removeAll()
            self.timePointValueArray.removeAll()
            
            // 解析时间点个数
            var timePointNumStr = ""
            timePointNumStr.append(commandCharacters[index])
            timePointNumStr.append(commandCharacters[index + 1])
            self.timePointNum = timePointNumStr.hexaToDecimal
            
            index = index + 2
            var timePointStr = ""
            var timePointColorStr = ""
            for _ in 0 ..< self.timePointNum! {
                timePointStr = ""
                timePointColorStr = ""
                
                // 解析时间点值
                timePointStr.append(commandCharacters[index])
                timePointStr.append(commandCharacters[index + 1])
                timePointStr.append(commandCharacters[index + 2])
                timePointStr.append(commandCharacters[index + 3])
                
                self.timePointArray.append(timePointStr)
                
                // 解析时间点对应的颜色值
                for j in 0 ..< self.channelNum! * 2 {
                    timePointColorStr.append(commandCharacters[index + 4 + j])
                }
                
                self.timePointValueArray.append(timePointColorStr)
                
                index = index + (self.channelNum! * 2 + 4)
            }
        } else {
            // 解析数据出错
            self.runMode = DeviceRunMode.UNKNOWN_RUN_MODE
            return
        }
    }
    
    /// 根据模型生成设置自动模式命令
    ///
    /// - returns: 设置自动模式的命令
    func generateSetAutoCommand() -> String {
        var commandHeaderStr: String! = CommandHeader.COMMANDHEAD_READ_ONE.rawValue
        var commandStr: String! = "23"
        
        for timePointIndex in 0 ..< self.timePointNum! {
            // 拼接时间点
            commandStr.append(self.timePointArray[timePointIndex])
            commandStr.append(self.timePointArray[timePointIndex + 1])
            
            // 拼接时间点对应的颜色值
            commandStr.append(self.timePointValueArray[timePointIndex])
        }
        
        // 拼接数据个数
        commandHeaderStr = commandHeaderStr.appendingFormat("%02x", self.timePointNum! * (self.timePointNum! + self.channelNum!))
        
        return commandHeaderStr + commandStr
    }
    
    /// 把改变的颜色值保存到模型中对应的颜色信息中
    /// - parameter timeSlotIndex: 时间段索引
    /// - parameter colorIndex: 颜色值索引
    /// - parameter colorValue: 要保存的颜色值
    ///
    /// - returns: Void
    func saveColorValueToModel(timePointIndex: Int!, colorIndex: Int!, colorValue: Float!) -> Void {
        // 1.获取时间点对应的颜色值
        let colorStr = self.timePointValueArray[timePointIndex]
        
        // 2.根据颜色值索引把颜色值保存到模型中
        var cIndex = 0
        var newColorStr = ""
        for c in colorStr {
            if cIndex != 2 * colorIndex && cIndex != (2 * colorIndex + 1) {
                newColorStr.append(c)
            } else if cIndex == 2 * colorIndex {
                newColorStr = newColorStr.appendingFormat("%02x", Int(colorValue / GlobalInfo.maxColorValue * 100))
            }
            
            cIndex = cIndex + 1
        }
        
        self.timePointValueArray[timePointIndex] = newColorStr
    }
    
    /// 把改变的颜色值保存到模型中对应的颜色信息中
    /// - parameter timePointCount: 时间点个数
    /// - parameter timePointIndex: 时间点索引
    /// - parameter colorIndex: 颜色值索引
    /// - parameter colorValue: 要保存的颜色值
    ///
    /// - returns: Void
    func saveColorValueToModel(timePointCount: Int!, timePointIndex: Int!, colorIndex: Int!, colorValue: Float!) -> Void {
        var colorStr = ""
        var key = 0
        // 1.获取时间点对应的颜色值
        if timePointIndex == 0 {
            key = self.timePointValueArray.count - 1
        } else {
            key = timePointIndex - 1
        }
        colorStr = self.timePointValueArray[key]
        
        // 2.根据颜色值索引把颜色值保存到模型中
        var cIndex = 0
        var newColorStr = ""
        for c in colorStr {
            if cIndex != 2 * colorIndex && cIndex != (2 * colorIndex + 1) {
                newColorStr.append(c)
            } else if cIndex == 2 * colorIndex {
                newColorStr = newColorStr.appendingFormat("%02x", Int(colorValue / 1000.0 * 100.0))
            }
            
            cIndex = cIndex + 1
        }
        
        self.timePointValueArray[key] = newColorStr
    }
    
    /// 转换协议数据为所有时间点对应的数组
    ///
    /// - returns: 时间点对应的double型颜色值
    func convertColorValue() -> [[Double]] {
        var colorArray = [[Double]]()
        
        for colorValue in self.timePointValueArray {
            colorArray.append(colorValue.convertColorStrToDoubleValue())
        }
        
        return colorArray
    }
    
    func generateLinePoint() -> [Array<CGPoint>] {
        var data = [Array<CGPoint>]()
        var value: CGPoint?
        var line = [CGPoint]()
        // x坐标
        var xAxis: CGFloat = 0.0
        // y坐标
        var yAxis: CGFloat?
        var yFisrtAxis: CGFloat?
        var yLastAxis: CGFloat?
        var colorStr: String?
        var firstColorStr: String?
        var lastColorStr: String?
        for i in 0 ..< self.channelNum! {
            line.removeAll()
            
            // 添加0点的点
            xAxis = 0
            firstColorStr = timePointValueArray?[0]
            lastColorStr = timePointValueArray?[timePointValueArray!.count - 1]
            yFisrtAxis = CGFloat((firstColorStr! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexToInt16())
            yLastAxis = CGFloat((lastColorStr! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexToInt16())
            
            let firstTimePoint = timePointArray![0]
            let lastTimePoint = timePointArray![(timePointArray?.count)! - 1]
            let dis = CGFloat(String.converTimeStrToMinute(timeStr: firstTimePoint)!) / (CGFloat(String.converTimeStrToMinute(timeStr: firstTimePoint)!) + 1439.0 - CGFloat(String.converTimeStrToMinute(timeStr: lastTimePoint)!)) * (yFisrtAxis! - yLastAxis!)
            
            yFisrtAxis = yFisrtAxis! - dis
            
            value = CGPoint(x: xAxis, y: yFisrtAxis!)
            
            line.append(value!)
            
            for index in 0 ..< timePointArray!.count {
                let timeStr = timePointArray![index]
                xAxis = CGFloat(String.converTimeStrToMinute(timeStr: timeStr)!)
                
                colorStr = timePointValueArray?[index]
                
                yAxis = CGFloat((colorStr! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexToInt16())
                
                value = CGPoint(x: xAxis, y: yAxis!)
                
                line.append(value!)
            }
            
            // 添加24点的点
            xAxis = 1439
            
            value = CGPoint(x: xAxis, y: yFisrtAxis!)
            
            line.append(value!)
            
            data.append(line)
        }
        return data
    }
}






























