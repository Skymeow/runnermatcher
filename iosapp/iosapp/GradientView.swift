//
//  GradientView.swift
//  iosapp
//
//  Created by Sky Xu on 9/12/17.
//  Copyright © 2017 Sky Xu. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor(red:1.00, green:0.45, blue:0.46, alpha:1.0) {
        didSet {
            layoutSubviews()
        }
    }
//    UIColor(red:1.00, green:0.53, blue:0.37, alpha:1.0)
    @IBInspectable var bottomColor: UIColor = UIColor(red:1.00, green:0.52, blue:0.38, alpha:1.0) {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable var angle: CGFloat = 0 {
        didSet {
            layoutSubviews()
        }
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return  CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        let colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.colors = colors
        
        let radians = angle * CGFloat(Double.pi) / 180
        let x1 = cos(radians) * 0.5 + 0.5
        let x2 = 1-x1
        let y1 = sin(radians) * 0.5 + 0.5
        let y2 = 1-y1
        
        gradientLayer.endPoint = CGPoint(x: x2, y: y2)
        self.setNeedsDisplay()
    }
    
}
