//
//  BezierView.swift
//  InteractiveAnimation
//
//  Created by Sathish on 22/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import Foundation
import UIKit

class BezierView: UIView {

    //MARK: Public members
    var lineColor = UIColor.cyan

    var lineLayer = CAShapeLayer()
    var prev: (dx: CGFloat, dy: CGFloat, x: CGFloat, y: CGFloat) = (0,0,0,0)

    let div: CGFloat = 7.0

    //MARK: Private members
    private var dataPoints: [CGPoint]?

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func drawLineCurve(points: [CGPoint]) {
        self.layer.sublayers?.forEach({ (layer: CALayer) -> () in
            layer.removeFromSuperlayer()
        })
        self.dataPoints = points
        drawSmoothLines()
    }

    private func drawSmoothLines() {

        guard let points = dataPoints else { return }
        let linePath = self.constructPoints(points: points)

        lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor(red: 204/255, green: 1, blue: 1, alpha: 0.2).cgColor
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 2.0

        lineLayer.shadowColor = UIColor.black.cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 8)
        lineLayer.shadowOpacity = 0.5
        lineLayer.shadowRadius = 6.0

        self.layer.addSublayer(self.lineLayer)

        // For Animation purpose
        let initPaths = constructInitial(points: points)
        lineLayer.animate(fromValue: initPaths.cgPath, toValue: linePath, keyPath: "path")
    }
}

extension BezierView {

    func constructInitial(points: [CGPoint]) -> UIBezierPath {
        var newPoints: [CGPoint] = []
        for point in points {
            newPoints.append(CGPoint(x: point.x, y: self.frame.height))
        }
        return constructPoints(points: newPoints)
    }

    func constructPoints(points: [CGPoint]) -> UIBezierPath {

        let bezier = UIBezierPath()

        for (index, point) in points.enumerated() {
            let x = point.x
            let y = point.y
            var dx: CGFloat = 0.0
            var dy: CGFloat = 0.0

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
