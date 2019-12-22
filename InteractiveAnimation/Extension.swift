//
//  Extension.swift
//  InteractiveAnimation
//
//  Created by Sathish on 21/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import UIKit

extension UIView {

    func setCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    func setBorder(width: CGFloat, color: UIColor? = nil) {
        self.layer.borderWidth = width
        self.layer.borderColor = color?.cgColor
    }
}
