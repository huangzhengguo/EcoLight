//
//  CommonData.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/11/1.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

// 通知类型
enum InledcoNotification: String {
    case CANCELPREVIEW_NOTIFICATION = "Cancel Preview"
}

// 所有类型编码
enum DeviceTypeCode: String {
    // 旧协议设备类型编码
    case ONECHANNEL_CONTROLLER = "0001"
    case TWOCHANNEL_CONTROLLER = "0002"
    case THREECHANNEL_CONTROLLER = "0003"
    case FOURCHANNEL_CONTROLLER = "0004"
    case FIVECHANNEL_CONTROLLER = "0005"
    case SIXCHANNEL_CONTROLLER = "0006"
    
    // 新类型编码
    case NEW_DEVICE_CONTROLLER = "9999"
}

// 灯具类型
enum LightTypeCode: String {
    case ONECHANNEL_LIGHT = "0001"
    case TWOCHANNEL_LIGHT = "0002"
    case THREECHANNEL_LIGHT = "0003"
    case FOURCHANNEL_LIGHT = "0004"
    case FIVECHANNEL_LIGHT = "0005"
    case SIXCHANNEL_LIGHT = "0006"
    
    case NEW_DEVICE_LIGHT = "9999"
}
