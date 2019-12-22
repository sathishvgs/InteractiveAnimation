//
//  CollectionViewCell.swift
//  InteractiveAnimation
//
//  Created by Sathish on 22/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.setCorner(radius: 8.0)
        }
    }

    override func awakeFromNib() {}
}
