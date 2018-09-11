//
//  ProfileHelp.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/8.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//  保存文件帮助类
//

import Foundation

class ArchiveHelper {
    // 数据持久化错误码
    enum SaveProfileErrorCode {
        case CREATEFILE_ERROR
        case SAMENAME_ERROR
        case WRITEDATA_ERROR
        case SUCCESS_ERROR
    }
    
    // 文件名称
    public static let profileName = "profile.plist"
    
    static func getUserDocumentPath(profile: String) -> String {
        return (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appendingFormat("/%@", profile))!
    }
    
    /// 保存类型为T的模型到文件中
    /// - parameter model: 模型
    /// - parameter profile: 文件名称
    /// - parameter keyName: 键值
    ///
    /// - returns: 错误码
    static func archiveProfile<T>(model: T, profile: String, modelKey: String) -> SaveProfileErrorCode {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appendingFormat("/%@", profile)

        var modelArray: [T] = unarchiveProfile(documentPath: documentPath!, modelKey: modelKey)
        
        modelArray.append(model)
        
        return writeData(documentPath: documentPath!, modelArray: modelArray, modelKey: modelKey)
    }
    
    static func writeData<T>(documentPath: String, modelArray: [T], modelKey: String) -> SaveProfileErrorCode {
        let archiverData = NSMutableData.init()
        let archiver = NSKeyedArchiver.init(forWritingWith: archiverData)
        
        archiver.encode(modelArray, forKey: modelKey)
        archiver.finishEncoding()
        
        if archiverData.write(toFile: documentPath, atomically: true) == true {
            return SaveProfileErrorCode.SUCCESS_ERROR
        } else {
            return SaveProfileErrorCode.WRITEDATA_ERROR
        }
    }
    
    /// 解归档
    /// - parameter documentPath: 文件路径
    /// - parameter modelKey: 键值
    ///
    /// - returns: 模型数组
    static func unarchiveProfile<T>(documentPath: String, modelKey: String) -> [T] {
        let fileManager = FileManager.init()
        var modelArray: Array<T> = Array<T>()
        if fileManager.fileExists(atPath: documentPath) == false {
            if fileManager.createFile(atPath: documentPath, contents: nil, attributes: nil) == false {
                return modelArray
            }
        }
        
        let existData = NSData.init(contentsOfFile: documentPath)
        let unarchiver = NSKeyedUnarchiver.init(forReadingWith: existData! as Data)
        
        if unarchiver.decodeObject(forKey: modelKey) != nil {
            modelArray = unarchiver.decodeObject(forKey: modelKey) as! Array<T>
        }
        
        return modelArray
    }
}
