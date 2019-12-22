//
//  BezierView.swift
//  InteractiveAnimation
//
//  Created by Sathish on 22/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import Foundation
import UIKit

protocol BezierViewDataSource: class {
    func bezierViewDataPoints(bezierView: BezierView) -> [CGPoint]
}

class BezierView: UIView {

    //MARK: Public members
    weak var dataSource: BezierViewDataSource?
    var lineColor = UIColor(red: 233.0/255.0, green: 98.0/255.0, blue: 101.0/255.0, alpha: 1.0)

    var pointLayers = [CAShapeLayer]()
    var lineLayer = CAShapeLayer()
    var prev: (dx: CGFloat, dy: CGFloat, x: CGFloat, y: CGFloat) = (0,0,0,0)

    let div: CGFloat = 7.0

    //MARK: Private members

    private var dataPoints: [CGPoint]? {
        return self.dataSource?.bezierViewDataPoints(bezierView: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.sublayers?.forEach({ (layer: CALayer) -> () in
            layer.removeFromSuperlayer()
        })
        pointLayers.removeAll()

        drawSmoothLines()
    }

    private func drawSmoothLines() {

        guard let points = dataPoints else { return }
        let linePath = self.constructPoints(points: points)

        lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 4.0

        lineLayer.shadowColor = UIColor.black.cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 8)
        lineLayer.shadowOpacity = 0.5
        lineLayer.shadowRadius = 6.0


        let animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            self.layer.addSublayer(self.lineLayer)
            self.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

extension BezierView {

    func constructPoints(points: [CGPoint]) -> UIBezierPath {

        let bezier = UIBezierPath()

        for (index, point) in points.enumerated() {

            let x = point.x
            let y = point.y

            var dx = CGFloat(0)
            var dy = CGFloat(0)

            switch index {
                case _ where index == 0:

                    bezier.move(to: points[0])
                    let nextX = points[index + 1].x
                    let nextY = points[index + 1].y

                    prev.dx = (nextX - x) / div
                    prev.dy = (nextY - y) / div
                    prev.x = x
                    prev.y = y

                case _ where (index == points.count - 1):
                    dx = (x - prev.x) / div
                    dy = (y - prev.y) / div

                default:
                    let nextX = points[index + 1].x
                    let nextY = points[index + 1].y
                    dx = (nextX - prev.x) / div
                    dy = (nextY - prev.y) / div
            }

            bezier.addCurve(to: CGPoint(x: x, y: y), controlPoint1: CGPoint(x: prev.x + prev.dx, y: prev.y + prev.dy), controlPoint2: CGPoint(x: x - dx, y: y - dy))

            prev = (dx, dy, x, y)
        }
        return bezier
    }
}
