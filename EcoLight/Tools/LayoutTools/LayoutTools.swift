//
//  LayoutTools.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/27.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class LayoutToolsView: UIView {
    typealias LongPressTagType = (Int) -> Void
    typealias PassButtonType = (UIButton, Int) -> Void
    var buttonActionCallback: PassButtonType?
    var buttonLongPressCallback: LongPressTagType?
    
    init(viewNum: Int!, viewWidth: CGFloat!, viewHeight: CGFloat!, viewInterval: CGFloat!, viewTitleArray: [String]!, frame: CGRect) {
        super.init(frame: frame)
        
        for i in 1 ... viewNum {
            let buttonFrame = CGRect(x: calculateXPosition(viewNum: viewNum, index: i, viewInterval: viewInterval, viewWidth: viewWidth)!, y: 0, width: viewWidth, height: viewHeight)
            let button = UIButton(frame: buttonFrame)
            
            button.tag = 1000 + i
            button.backgroundColor = UIColor.blue
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            button.setTitle(viewTitleArray[i - 1], for: .normal)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: UIControlEvents.touchUpInside)
            
            // 添加长按手势
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(userDefineLongPressAction(recognizer:)))
            longPressGestureRecognizer.minimumPressDuration = 1.0
            longPressGestureRecognizer.numberOfTouchesRequired = 1
            button.addGestureRecognizer(longPressGestureRecognizer)

            self.addSubview(button)
        }
    }
    
    // 按钮点击方法
    @objc func buttonAction(sender: UIButton) -> Void {
        if buttonActionCallback != nil {
            buttonActionCallback!(sender, sender.tag - 1001)
        }
    }
    
    // 按钮长按手势
    @objc func userDefineLongPressAction(recognizer: UILongPressGestureRecognizer) -> Void {
        if buttonLongPressCallback != nil {
            let userButton = recognizer.view as! UIButton
            buttonLongPressCallback!(userButton.tag - 1001)
        }
    }
    
    func calculateXPosition(viewNum: Int!, index: Int!, viewInterval: CGFloat!, viewWidth: CGFloat!) -> CGFloat? {
        var xPostion = self.frame.size.width / CGFloat(2.0)
        let harfButtonNum = Int(viewNum / 2)
        if viewNum % 2 == 0 {
            if index < harfButtonNum {
                xPostion = xPostion + CGFloat(index - harfButtonNum - 1) * viewWidth + CGFloat(2 * (index - harfButtonNum - 1) + 1) * viewInterval / 2.0
            } else {
                xPostion = xPostion + CGFloat(2 * (index - harfButtonNum) - 1) * viewInterval / 2.0 + CGFloat((index - harfButtonNum - 1)) * viewWidth
            }
        } else {
            xPostion = xPostion + (CGFloat)(index - harfButtonNum - 1) * 2.0 * viewInterval + (CGFloat)(-1.0 / 2.0 + (CGFloat)(index - harfButtonNum - 1)) * viewWidth
        }
        
        return xPostion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
