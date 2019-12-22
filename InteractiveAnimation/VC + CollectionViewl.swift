//
//  CollectionViewCell.swift
//  InteractiveAnimation
//
//  Created by Sathish on 22/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import UIKit


// MARK: CollectionView Delegates
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    func configCollectionViews() {
        configureCollectionCell()
        setUpFlowLayout()
    }

    fileprivate func configureCollectionCell() {
        self.imageCollectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
    }

    fileprivate func setUpFlowLayout() {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal
        flowlayout.itemSize = CGSize(width: 75, height: 75)
        self.imageCollectionView.collectionViewLayout = flowlayout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return congifureCell(indexPath)
    }

    fileprivate func congifureCell(_ indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionCell else { return UICollectionViewCell()}
        let imgColor = imageColors[indexPath.row]
        cell.imageView.backgroundColor = imgColor
        return cell
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: CollectionView Cell
class ImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.setCorner(radius: 8.0)
        }
    }

    override func awakeFromNib() {}
}
