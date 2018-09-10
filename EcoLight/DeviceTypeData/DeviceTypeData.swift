//
//  DeviceTypeData.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceTypeData {    
    // 通用颜色及标题数组
    static let oneColorArray: [UIColor]! = [UIColor.red]
    static let oneColorTitleArray: [String]! = ["Channel1"]
    static let twoColorArray: [UIColor]! = [UIColor.red, UIColor.green]
    static let twoColorTitleArray: [String]! = ["Channel1", "Channel2"]
    static let threeColorArray: [UIColor]! = [UIColor.red, UIColor.green, UIColor.blue]
    static let threeColorTitleArray: [String]! = ["Channel1", "Channel2", "Channel3"]
    static let fourColorArray: [UIColor]! = [UIColor.red, UIColor.green, UIColor.blue, UIColor.white]
    static let fourColorTitleArray: [String]! = ["Channel1", "Channel2", "Channel3", "Channel4"]
    static let fiveColorArray: [UIColor]! = [UIColor.red, UIColor.green, UIColor.blue, UIColor.white, UIColor.cyan]
    static let fiveColorTitleArray: [String]! = ["Channel1", "Channel2", "Channel3", "Channel4", "Channel5"]
    static let sixColorArray: [UIColor]! = [UIColor.red, UIColor.green, UIColor.blue, UIColor.white, UIColor.red, UIColor.red]
    static let sixColorTitleArray: [String]! = ["Channel1", "Channel2", "Channel3", "Channel4", "Channel5", "Channel6"]
    
    // 对应灯具颜色及颜色标题数组
    static let stripIIIColorArray: [UIColor]! = [UIColor.red,UIColor.green,UIColor.blue,UIColor.white]
    static let stripIIIColorTitleArray: [String]! = ["Red","Green","Blue","White"]
    
    ///  根据设备类型编码获取设备信息
    /// - parameter deviceTypeCode: 设备类型编码
    ///
    /// - returns: 设备相关信息
    static func getDeviceInfoWithTypeCode(deviceTypeCode: DeviceTypeCode) -> ControllerCodeInfo {
        let controllerCodeInfo: ControllerCodeInfo = ControllerCodeInfo()
        
        switch deviceTypeCode {
        case .ONECHANNEL_CONTROLLER:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "One channel light"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 1
            controllerCodeInfo.channelColorArray = oneColorArray
            controllerCodeInfo.channelColorTitleArray = oneColorTitleArray
        case .TWOCHANNEL_CONTROLLER:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "Two channel light"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 2
            controllerCodeInfo.channelColorArray = twoColorArray
            controllerCodeInfo.channelColorTitleArray = twoColorTitleArray
        case .THREECHANNEL_CONTROLLER:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "Three channel light"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 3
            controllerCodeInfo.channelColorArray = threeColorArray
            controllerCodeInfo.channelColorTitleArray = threeColorTitleArray
        case .FOURCHANNEL_CONTROLLER:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "Four channel light"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 4
            controllerCodeInfo.channelColorArray = fourColorArray
            controllerCodeInfo.channelColorTitleArray = fourColorTitleArray
        case .FIVECHANNEL_CONTROLLER:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "Five channel light"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 5
            controllerCodeInfo.channelColorArray = fiveColorArray
            controllerCodeInfo.channelColorTitleArray = fiveColorTitleArray
            // 控制器下面定义一组可以控制的灯具
            controllerCodeInfo.supportLightsArray = [
                DeviceCodeInfo(controllerTypeCode: controllerCodeInfo.deviceTypeCode!, deviceTypeCode: .THREECHANNEL_LIGHT, deviceName: "light1", pictureName: "led", channelNum: 5, firmwaredId: 0, channelColorArray: fiveColorArray, channelColorTitleArray: fiveColorTitleArray),
                DeviceCodeInfo(controllerTypeCode: controllerCodeInfo.deviceTypeCode!, deviceTypeCode: .FOURCHANNEL_LIGHT, deviceName: "light2", pictureName: "led", channelNum: 5, firmwaredId: 0, channelColorArray: fiveColorArray, channelColorTitleArray: fiveColorTitleArray),
                DeviceCodeInfo(controllerTypeCode: controllerCodeInfo.deviceTypeCode!, deviceTypeCode: .FIVECHANNEL_LIGHT, deviceName: "light3", pictureName: "led", channelNum: 5, firmwaredId: 0, channelColorArray: fiveColorArray, channelColorTitleArray: fiveColorTitleArray)
            ]
        case .SIXCHANNEL_CONTROLLER:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "Six channel light"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 6
            controllerCodeInfo.channelColorArray = sixColorArray
            controllerCodeInfo.channelColorTitleArray = sixColorTitleArray
        default:
            controllerCodeInfo.deviceTypeCode = deviceTypeCode
            controllerCodeInfo.deviceName = "NEW DEVICE"
            controllerCodeInfo.pictureName = "led"
            controllerCodeInfo.channelNum = 4
            controllerCodeInfo.channelColorArray = fourColorArray
            controllerCodeInfo.channelColorTitleArray = fourColorTitleArray
            break
        }
        
        return controllerCodeInfo
    }
    
    static func getLightInfoWithTypeCode(deviceTypeCode: DeviceTypeCode, lightTypeCode: LightTypeCode) -> DeviceCodeInfo! {
        let controllerCodeInfo = getDeviceInfoWithTypeCode(deviceTypeCode: deviceTypeCode)
        
        for lightCodeInfo in controllerCodeInfo.supportLightsArray! {
            if lightCodeInfo.deviceTypeCode == lightTypeCode {
                return lightCodeInfo
            }
        }
        
        return nil
    }
}
