//
//  DeviceParameterModel.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/17.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceParameterModel: NSObject {
    // 设备类型编码
    var typeCode: DeviceTypeCode?
    // UUID
    var uuid: String?
    // 命令帧头
    var commandHeader: String! = ""
    // 命令码
    var commandCode: String! = ""
    // 寄存器地址标记
    var registerAddr: String! = ""
    // 命令数据字节数
    var commandDataByteCount: Int! = 0
    // 通道数量
    var channelNum: Int?
    // 控制器通道数量
    var controllerChannelNum: Int?
    // 运行模式
    var runMode: DeviceRunMode?
    // 开关状态
    var powerState: DeviceState?
    // 动态模式
    var dynamicMode: String?
    // 自动模式数据
    // 时间点个数
    var timePointNum: Int! = 4
    // 时间点数组
    var timePointArray: [String]! = [String]()
    // 自动模式时间点对应值：应该使用数组保存自动模式数据
    var timePointValueArray: [String]! = [String]()
    // 手动模式各路数据
    var manualModeValueArray: [String]! = [String]()
    // 用户自定义数据
    var userDefinedValueArray: [String]! = [String]()
    
    func parameterModelCopy(parameterModel: DeviceParameterModel) -> Void {
        parameterModel.typeCode = self.typeCode
        parameterModel.uuid = self.uuid
        parameterModel.commandHeader = self.commandHeader
        parameterModel.commandCode = self.commandCode
        parameterModel.registerAddr = self.registerAddr
        parameterModel.commandDataByteCount = self.commandDataByteCount
        parameterModel.channelNum = self.channelNum
        parameterModel.controllerChannelNum = self.controllerChannelNum
        parameterModel.runMode = self.runMode
        parameterModel.powerState = self.powerState
        parameterModel.dynamicMode = self.dynamicMode
        parameterModel.timePointNum = self.timePointNum
        
        parameterModel.timePointArray.removeAll()
        for timePoint in self.timePointArray {
            parameterModel.timePointArray.append(timePoint)
        }
        
        parameterModel.timePointValueArray.removeAll()
        for timePointValue in self.timePointValueArray {
            parameterModel.timePointValueArray.append(timePointValue)
        }
        
        parameterModel.manualModeValueArray.removeAll()
        for manualValue in self.manualModeValueArray {
            parameterModel.manualModeValueArray.append(manualValue)
        }
        
        parameterModel.userDefinedValueArray.removeAll()
        for manualValue in self.userDefinedValueArray {
            parameterModel.userDefinedValueArray.append(manualValue)
        }
    }
}
