//
//  ManualSliderView.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/27.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class ManualSliderView: UIView {

    var colorSliderArray: [UISlider]! = [UISlider]()
    var colorColorPercentLabelArray: [UILabel]! = [UILabel]()
    typealias PassSliderValueType = (Int, Float) -> Void
    var passSliderValueCallback: PassSliderValueType?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    init(frame: CGRect, colorArray: [UIColor]!, colorTitleArray: [String]!, colorPercentArray: [Double]!) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        for i in 0 ..< colorArray.count {
            let colorHeight = frame.size.height / CGFloat(colorArray.count)
            let colorTitleLabelWidth = CGFloat(5)
            let colorPercentTitleWidth = CGFloat(50)
            let colorTitleLabel = UILabel(frame: CGRect(x: 5.0, y: CGFloat(i) * colorHeight, width: colorTitleLabelWidth, height: colorHeight))
            
            colorTitleLabel.isHidden = true
            colorTitleLabel.tag = 1000 + i
            colorTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
            colorTitleLabel.text = colorTitleArray[i]
            
            let colorPercentLabel = UILabel(frame: CGRect(x: self.frame.size.width - CGFloat(colorPercentTitleWidth) + 5.0, y: CGFloat(i) * colorHeight, width: colorPercentTitleWidth, height: colorHeight))
            
            colorPercentLabel.tag = 3000 + i
            colorColorPercentLabelArray.append(colorPercentLabel)
            
            let colorSlider = UISlider(frame: CGRect(x: colorTitleLabel.frame.origin.x + colorTitleLabel.frame.size.width, y: CGFloat(i) * colorHeight, width: self.frame.size.width - colorTitleLabel.frame.size.width - colorPercentLabel.frame.size.width, height: colorHeight))

            colorSlider.tag = 2000 + i
            colorSlider.tintColor = colorArray[i]
            colorSlider.thumbTintColor = colorArray[i]
            colorSlider.minimumValue = 0.0
            colorSlider.maximumValue = GlobalInfo.maxColorValue
            colorSlider.addTarget(self, action: #selector(colorSliderValueChanged(sender:)), for: .valueChanged)
            colorSliderArray.append(colorSlider)
            
            self.addSubview(colorTitleLabel)
            self.addSubview(colorSlider)
            self.addSubview(colorPercentLabel)
        }
        
        updateManualSliderView(colorPercentArray: colorPercentArray)
    }
    
    @objc func colorSliderValueChanged(sender: UISlider) -> Void {
        colorColorPercentLabelArray![sender.tag - 2000].text = String.init(format: "%.0f%%", Float(sender.value) / GlobalInfo.maxColorValue * 100.0)
        
        if passSliderValueCallback != nil {
            passSliderValueCallback!(sender.tag - 2000, sender.value)
        }
    }
    
    func updateManualSliderView(colorPercentArray: [Double]) -> Void {
        for i in 0 ..< colorPercentArray.count {
            colorSliderArray![i].value = Float(Float(colorPercentArray[i]) / 100.0 * GlobalInfo.maxColorValue)
            colorColorPercentLabelArray![i].text = String.init(format: "%.0f%%", Float(colorPercentArray[i]))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

















