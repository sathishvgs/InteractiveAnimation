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
    private var animatePoints: [CGPoint]?
    private var currentStatus = false

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setup(originalPoints: [CGPoint], animatePoints: [CGPoint]) {
        self.layer.sublayers?.forEach({ (layer: CALayer) -> () in
            layer.removeFromSuperlayer()
        })
        self.dataPoints = originalPoints
        self.animatePoints = animatePoints
        configLayer()
    }

    func configLayer() {
        lineLayer.fillColor = UIColor(red: 204/255, green: 1, blue: 1, alpha: 0.2).cgColor
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 2.0

        lineLayer.shadowColor = UIColor.black.cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 8)
        lineLayer.shadowOpacity = 0.5
        lineLayer.shadowRadius = 6.0
        self.layer.addSublayer(self.lineLayer)
    }

    func toggleCurveLines(show: Bool) {

        guard let points = dataPoints, let animatePoints = animatePoints else { return }
        let linePath = self.constructPoints(points: points)
        let initPath = constructPoints(points: animatePoints)

        guard !currentStatus == show else { return }

        // For Animation purpose
        switch show {
            case true:
                lineLayer.path = linePath.cgPath
                lineLayer.animate(fromValue: initPath.cgPath, toValue: linePath.cgPath, keyPath: "path")
                currentStatus = true
            case false:
                lineLayer.path = initPath.cgPath
                lineLayer.animate(fromValue: linePath.cgPath, toValue: initPath.cgPath, keyPath: "path")
                currentStatus = false
        }
    }
}

extension BezierView {

    func constructInitial(points: [CGPoint]) -> UIBezierPath {
//        var newPoints: [CGPoint] = []
//        for point in points {
//            newPoints.append(CGPoint(x: point.x, y: self.frame.height))
//        }
        return constructPoints(points: points)
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
