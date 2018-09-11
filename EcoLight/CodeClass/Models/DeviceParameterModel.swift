//
//  DeviceParameterModel.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/17.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceParameterModel: NSObject, NSCoding {
    // 设备类型编码
    var typeCode: DeviceTypeCode?
    // 灯具类型编码
    var lightCode: LightTypeCode?
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
    // 用户保存的名称
    var fileName = ""
    // 时间点数组
    var timePointArray: [String]! = [String]()
    // 自动模式时间点对应值：应该使用数组保存自动模式数据
    var timePointValueArray: [String]! = [String]()
    // 手动模式各路数据
    var manualModeValueArray: [String]! = [String]()
    // 用户自定义数据
    var userDefinedValueArray: [String]! = [String]()
    var modelKey: String {
        get {
            return typeCode!.rawValue + lightCode!.rawValue
        }
    }
    
    override init() {
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(typeCode?.rawValue, forKey: "typeCode")
        aCoder.encode(lightCode?.rawValue, forKey: "lightCode")
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(commandHeader, forKey: "commandHeader")
        aCoder.encode(commandCode, forKey: "commandCode")
        aCoder.encode(registerAddr, forKey: "registerAddr")
        aCoder.encode(commandDataByteCount, forKey: "commandDataByteCount")
        aCoder.encode(channelNum, forKey: "channelNum")
        aCoder.encode(controllerChannelNum, forKey: "controllerChannelNum")
        aCoder.encode(runMode?.hashValue, forKey: "runMode")
        aCoder.encode(powerState?.hashValue, forKey: "powerState")
        aCoder.encode(dynamicMode, forKey: "dynamicMode")
        aCoder.encode(timePointNum, forKey: "timePointNum")
        aCoder.encode(fileName, forKey: "fileName")
        aCoder.encode(timePointArray, forKey: "timePointArray")
        aCoder.encode(timePointValueArray, forKey: "timePointValueArray")
        aCoder.encode(manualModeValueArray, forKey: "manualModeValueArray")
        aCoder.encode(userDefinedValueArray, forKey: "userDefinedValueArray")
    }
    
    required init(coder aDecoder:NSCoder) {
        self.typeCode = aDecoder.decodeObject(forKey: "typeCode") as? DeviceTypeCode
        self.lightCode = aDecoder.decodeObject(forKey: "lightCode") as? LightTypeCode
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        self.commandHeader = aDecoder.decodeObject(forKey: "commandHeader") as? String
        self.commandCode = aDecoder.decodeObject(forKey: "commandCode") as? String
        self.registerAddr = aDecoder.decodeObject(forKey: "registerAddr") as? String
        self.commandDataByteCount = aDecoder.decodeObject(forKey: "commandDataByteCount") as! Int
        self.channelNum = aDecoder.decodeObject(forKey: "channelNum") as? Int
        self.controllerChannelNum = aDecoder.decodeObject(forKey: "controllerChannelNum") as? Int
        self.runMode = aDecoder.decodeObject(forKey: "runMode") as? DeviceRunMode
        self.powerState = aDecoder.decodeObject(forKey: "powerState") as? DeviceState
        self.dynamicMode = aDecoder.decodeObject(forKey: "dynamicMode") as? String
        self.timePointNum = aDecoder.decodeObject(forKey: "timePointNum") as! Int
        self.fileName = aDecoder.decodeObject(forKey: "fileName") as! String
        self.timePointArray = aDecoder.decodeObject(forKey: "timePointArray") as? [String]
        self.timePointValueArray = aDecoder.decodeObject(forKey: "timePointValueArray") as? [String]
        self.manualModeValueArray = aDecoder.decodeObject(forKey: "manualModeValueArray") as? [String]
        self.userDefinedValueArray = aDecoder.decodeObject(forKey: "userDefinedValueArray") as? [String]
    }

    func parameterModelCopy(parameterModel: DeviceParameterModel) -> Void {
        parameterModel.typeCode = self.typeCode
        parameterModel.lightCode = self.lightCode
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
        parameterModel.fileName = self.fileName
        
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
