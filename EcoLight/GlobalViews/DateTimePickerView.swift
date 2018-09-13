//
//  DateTimePickerView.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/6.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//

import UIKit

class DateTimePickerView: BaseView {
    private var datePicker: UIDatePicker?
    var confirmBlock: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: 0, y: 0, width: SystemInfoTools.screenWidth, height: SystemInfoTools.screenHeight)
        
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 220))
        
        centerView.center = self.center
        centerView.backgroundColor = UIColor.white
        centerView.layer.borderColor = UIColor.lightGray.cgColor
        centerView.layer.borderWidth = 1
        centerView.layer.cornerRadius = 5.0
        
        self.addSubview(centerView)
        
        // 标题
        let titleLable = UILabel.init(frame: CGRect(x: 0, y: 0, width: centerView.frame.size.width, height: 30))
        
        titleLable.text = self.languageManager.getTextForKey(key: "choseTimePoint")
        titleLable.textAlignment = .center
        
        centerView.addSubview(titleLable)
        
        // 时间选择
        datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 30, width: centerView.frame.size.width, height: 160))
        
        datePicker?.locale = Locale.init(identifier: "NL")
        datePicker?.datePickerMode = .countDownTimer
        
        centerView.addSubview(datePicker!)
        
        // 取消按钮
        let cancelBtn = UIButton.init(frame: CGRect(x: 0, y: centerView.frame.size.height - 30, width: centerView.frame.size.width / 2.0, height: 30))
        
        cancelBtn.setTitle(self.languageManager.getTextForKey(key: "cancel"), for: .normal)
        cancelBtn.tag = 100001
        cancelBtn.setTitleColor(UIColor.blue, for: .normal)
        cancelBtn.layer.cornerRadius = 5.0
        cancelBtn.addTarget(self, action: #selector(datePickerBtnAction(sender:)), for: .touchUpInside)
        
        centerView.addSubview(cancelBtn)
        
        // 确认按钮
        let confirmBtn = UIButton.init(frame: CGRect(x: cancelBtn.frame.size.width, y: centerView.frame.size.height - 30, width: centerView.frame.size.width / 2.0, height: 30))
        
        confirmBtn.setTitle(self.languageManager.getTextForKey(key: "confirm"), for: .normal)
        confirmBtn.tag = 100002
        confirmBtn.setTitleColor(UIColor.blue, for: .normal)
        confirmBtn.layer.cornerRadius = 5.0
        confirmBtn.addTarget(self, action: #selector(datePickerBtnAction(sender:)), for: .touchUpInside)
        
        centerView.addSubview(confirmBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func datePickerBtnAction(sender: UIButton) -> Void {
        let btnIndex = sender.tag - 100000
        if btnIndex == 1 {
            sender.superview?.superview?.removeFromSuperview()
        } else if btnIndex == 2 {
            if self.confirmBlock != nil {
                self.confirmBlock!(String.convertDateToFormatStr(date: (self.datePicker?.date)!, formatStr: "HH:mm"))
            }
            sender.superview?.superview?.removeFromSuperview()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
