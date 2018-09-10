//
//  DeviceCodeInfo.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

// 控制器模型
class ControllerCodeInfo: NSObject {
    var deviceTypeCode: DeviceTypeCode?
    var deviceName: String?
    var pictureName: String?
    var channelNum: Int?
    var firmwaredId: Int?
    var channelColorArray: [UIColor]?
    var channelColorTitleArray: [String]?
    
    // 灯具列表
    var supportLightsArray: [DeviceCodeInfo]?
}

// 灯具信息
class DeviceCodeInfo: NSObject {
    var controllerTypeCode: DeviceTypeCode
    var deviceTypeCode: LightTypeCode
    var deviceName: String
    var pictureName: String
    var channelNum: Int
    var firmwaredId: Int
    var channelColorArray: [UIColor]
    var channelColorTitleArray: [String]
    
    init(controllerTypeCode: DeviceTypeCode, deviceTypeCode: LightTypeCode, deviceName: String, pictureName: String, channelNum: Int, firmwaredId: Int, channelColorArray: [UIColor], channelColorTitleArray: [String]) {
        self.controllerTypeCode = controllerTypeCode
        self.deviceTypeCode = deviceTypeCode
        self.deviceName = deviceName
        self.pictureName = pictureName
        self.channelNum = channelNum
        self.firmwaredId = firmwaredId
        self.channelColorArray = channelColorArray
        self.channelColorTitleArray = channelColorTitleArray
    }
}
