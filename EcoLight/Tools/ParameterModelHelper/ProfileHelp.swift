//
//  ProfileHelp.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/8.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//  保存文件帮助类
//

import Foundation

class ProfileHelper {
    /// 保存类型为T的模型到文件中
    /// - parameter model: 模型
    /// - parameter fileName: 文件名称
    /// - parameter keyName: 键值
    ///
    /// - returns:
    static func saveProfile<T>(model: T, fileName: String, modelKey: String) -> Bool {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appendingFormat("/%@", fileName)
        
        let fileManager = FileManager.init()
        if fileManager.fileExists(atPath: documentPath!) == false {
            if fileManager.createFile(atPath: documentPath!, contents: nil, attributes: nil) == false {
                return false
            }
        }
        
        let existData = NSMutableData.init(contentsOfFile: documentPath!)
        let unarchiver = NSKeyedUnarchiver.init(forReadingWith: existData! as Data)
        var modelArray: Array<T> = Array<T>()
        if unarchiver.decodeObject(forKey: modelKey) != nil {
            modelArray = unarchiver.decodeObject(forKey: modelKey) as! Array<T>
        }
        
        modelArray.append(model)
        
        let archiverData = NSMutableData.init()
        let archiver = NSKeyedArchiver.init(forWritingWith: archiverData)
        
        archiver.encode(modelArray, forKey: modelKey)
        archiver.finishEncoding()
        
        return archiverData.write(toFile: documentPath!, atomically: true)
    }
}
