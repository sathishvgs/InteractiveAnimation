//
//  Extension.swift
//  InteractiveAnimation
//
//  Created by Sathish on 21/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import UIKit

// MARK: UIView
extension UIView {

    func setCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    func setBorder(width: CGFloat, color: UIColor? = nil) {
        self.layer.borderWidth = width
        self.layer.borderColor = color?.cgColor
    }

    @discardableResult
    public func setGradient(colors: [UIColor], startPoint: GradientPoints, endPoint: GradientPoints) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint.point
        gradientLayer.endPoint = endPoint.point
        layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
}

// MARK: CALayer
extension CALayer {

    func animate(fromValue: Any, toValue: Any, keyPath: String) {
        let anim = CABasicAnimation(keyPath: keyPath)
        anim.fromValue = fromValue
        anim.toValue = toValue
        anim.duration = 2
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        self.add(anim, forKey: keyPath)
    }
}


// Gradient Points
public enum GradientPoints {
    case topLeft
    case centerLeft
    case bottomLeft
    case topCenter
    case center
    case bottomCenter
    case topRight
    case centerRight
    case bottomRight
    var point: CGPoint {
        switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
        }
    }
}
