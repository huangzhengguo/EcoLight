//
//  DeviceModel.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/9/29.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceModel: NSObject {
    // 设备品牌
    var brand: String! = "defaultBrand"
    // 分组名称
    var group: String! = "defaultGroup"
    // 用户定义名称
    var name: String?
    // 设备名称
    var deviceName: String?
    // 设备类型编码
    var typeCode: String?
    // 灯具编码
    var lightCode: String?
    // 设备
    var device: CBPeripheral?
    // MAC地址
    var macAddress: String?
    // UUID
    var uuidString: String?
    // RSSI
    var rssi: Int?
    // 是否被选择，扫描时用来标记设备是否被选择
    var isSelected: Bool?
    
    /// 按照设备名称排序
    /// - parameter preModel: 前一个设备
    /// - parameter nextModel: 后一个设备
    ///
    /// - returns: 如果前一个设备比后一个设备大，按字母顺序，则返回True，否则返回False
    class func sortByName(preModel: DeviceModel, nextModel: DeviceModel) -> Bool {
        return preModel.name! > nextModel.name!
    }
    
    /// 按照设备uuid排序
    /// - parameter preModel: 前一个设备
    /// - parameter nextModel: 后一个设备
    ///
    /// - returns: 如果前一个设备比后一个设备大，按字母顺序，则返回True，否则返回False
    class func sortByUuid(preModel: DeviceModel, nextModel: DeviceModel) -> Bool {
        return preModel.uuidString! > nextModel.uuidString!
    }
}
