//
//  DrawImage.swift
//  EcoLight
//
//  Created by huang zhengguo on 2018/9/6.
//  Copyright © 2018年 huang zhengguo. All rights reserved.
//

import Foundation

class DrawImage {
    static func drawImageWithSize(size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(size);
        
        let context = UIGraphicsGetCurrentContext();
        
        context?.setFillColor(color.cgColor)
        
        let radius: CGFloat = 0.0
        context?.move(to: CGPoint(x: size.width, y: size.height - radius))
        context?.addArc(tangent1End: CGPoint(x: size.width, y: size.height), tangent2End: CGPoint(x: size.width-radius, y: size.height), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: 0, y: size.height), tangent2End: CGPoint(x: 0, y: size.height - radius), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: 0, y: radius), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: size.width, y: 0), tangent2End: CGPoint(x: size.width, y: radius), radius: radius)

        context?.closePath()
        context?.drawPath(using: .fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}

