//
//  AutoColorChareView.swift
//  EcoLight
//
//  Created by huang zhengguo on 2017/10/27.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import Charts

class AutoColorChartView: UIView, ChartViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var lineChart: LineChartView?
    var lineChartEntry = [ChartDataEntry]()
    
    init(frame: CGRect, channelNum: Int, colorArray: [UIColor]?, colorTitleArray: [String]?, timePointArray: [String]?, timePointValueDic: [Int: String]?) {
        super.init(frame: frame)
        lineChart = LineChartView(frame: frame)
        lineChart?.backgroundColor = UIColor.clear
        lineChart?.delegate = self
        
        // 横坐标
        lineChart?.xAxis.labelPosition = .bottom
        lineChart?.xAxis.axisMaximum = 24 * 60
        lineChart?.xAxis.axisMinimum = 0
        lineChart?.rightYAxisRenderer.axis = nil
        lineChart?.scaleYEnabled = false
        lineChart?.scaleXEnabled = false
        lineChart?.xAxis.setLabelCount(13, force: true)
        let myLabelFormat = MyXAxisValueFormatter()
        lineChart?.xAxis.valueFormatter? = myLabelFormat
        
        // 纵坐标
        lineChart?.leftYAxisRenderer.axis?.axisMaximum = 1.0
        lineChart?.leftYAxisRenderer.axis?.axisMinimum = 0.0
        lineChart?.leftYAxisRenderer.axis?.setLabelCount(5, force: true)
        let numberFormat = MyYAxisValueFormatter()

        lineChart?.leftYAxisRenderer.axis?.valueFormatter = numberFormat

        lineChart?.chartDescription = nil
        
        updateGraph(channelNum: channelNum, colorArray: colorArray, colorTitleArray: colorTitleArray, timePointArray: timePointArray, timePointValueDic: timePointValueDic)
        
        self.addSubview(lineChart!)
    }
    
    func hightValue(x: Double, index: Int) -> Void {
        self.lineChart?.highlightValue(x: x, y: 0, dataSetIndex: index)
    }
    
    /// 更新自动模式曲线图，其中
    /// - parameter channelNum: 通道数量
    /// - parameter colorArray: 所有通道颜色值
    /// - parameter colorTitleArray: 所有通道的标题
    /// - parameter timePointArray: 所有时间点
    /// - parameter timePointValueDic: 所有时间对应的颜色值
    /// - returns: Void
    func updateGraph(channelNum: Int, colorArray: [UIColor]?, colorTitleArray: [String]?, timePointArray: [String]?, timePointValueDic: [Int: String]?) -> Void {
        let data = LineChartData()
        var value: ChartDataEntry?
        var line: LineChartDataSet?
        // x坐标
        var xAxis: Double = 0.0
        // y坐标
        var yAxis: Double?
        var yFisrtAxis: Double?
        var yLastAxis: Double?
        var colorStr: String?
        var firstColorStr: String?
        var lastColorStr: String?
        for i in 0 ..< channelNum {
            lineChartEntry.removeAll()
            
            // 添加0点的点
            xAxis = (self.lineChart?.chartXMin)!
            firstColorStr = timePointValueDic?[0]
            lastColorStr = timePointValueDic?[timePointValueDic!.keys.count - 1]
            yFisrtAxis = Double((firstColorStr! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexToInt16()) / 100.0
            yLastAxis = Double((lastColorStr! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexToInt16()) / 100.0
            
            let firstTimePoint = timePointArray![0]
            let lastTimePoint = timePointArray![(timePointArray?.count)! - 1]
            let dis = Double(firstTimePoint.converTimeStrToMinute(timeStr: firstTimePoint)!) / (Double(firstTimePoint.converTimeStrToMinute(timeStr: firstTimePoint)!) + (self.lineChart?.chartXMax)! - Double(lastTimePoint.converTimeStrToMinute(timeStr: lastTimePoint)!)) * (yFisrtAxis! - yLastAxis!)
            
            yFisrtAxis = yFisrtAxis! - dis
            
            value = ChartDataEntry(x: Double(xAxis), y: yFisrtAxis!)
            
            lineChartEntry.append(value!)
            
            for index in 0 ..< timePointArray!.count {
                let timeStr = timePointArray![index]
                xAxis = Double(timeStr.converTimeStrToMinute(timeStr: timeStr)!)
                
                colorStr = timePointValueDic?[index]
                
                yAxis = Double((colorStr! as NSString).substring(with: NSRange.init(location: i * 2, length: 2)).hexToInt16()) / 100.0
                
                value = ChartDataEntry(x: Double(xAxis), y: yAxis!)
                
                lineChartEntry.append(value!)
            }
            
            // 添加24点的点
            xAxis = (self.lineChart?.chartXMax)!
            
            value = ChartDataEntry(x: Double(xAxis), y: yFisrtAxis!)
            
            lineChartEntry.append(value!)
            
            line = LineChartDataSet(values: lineChartEntry, label: colorTitleArray?[i])
            
            line?.circleRadius = CGFloat(4.0)
            line?.circleColors[0] = colorArray![i]
            line?.colors[0] = colorArray![i]
            
            data.addDataSet(line!)
        }
        
        // 增加一条线，用来实现预览功能
        lineChartEntry.removeAll()
        for i in 0 ..< Int((lineChart?.chartXMax)!) {
            value = ChartDataEntry(x: Double(i), y: 0)
            lineChartEntry.append(value!)
        }
        
        line = LineChartDataSet(values: lineChartEntry, label: nil)
        line?.circleRadius = 0.0
        line?.colors[0] = UIColor.clear
        
        data.addDataSet(line!)
        
        lineChart?.data = data
        
        lineChart?.moveViewToX(100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 实现自定义显示坐标轴显示格式
class MyXAxisValueFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if Int(value) % 60 == 0 {
            return String.init(format: "%d", Int(value) / 60)
        } else {
            return ""
        }
    }
}

class MyYAxisValueFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String.init(format: "%.0f%%", value * 100)
    }
}
