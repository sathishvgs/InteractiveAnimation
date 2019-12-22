//
//  VC + ViewConfigutation.swift
//  InteractiveAnimation
//
//  Created by Sathish on 22/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import UIKit

// MARK: Setting up Views
extension ViewController {

    func constructInnerLayout() {
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        innerPanView.addSubview(detailsStackView)
        detailsStackView.addArrangedSubview(nextWatchingLbl)
        detailsStackView.addArrangedSubview(dayCountLbl)
        detailsStackView.addArrangedSubview(nextDescLbl)

        detailsStackView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        detailsStackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        detailsStackView.leadingAnchor.constraint(equalTo: innerPanView.leadingAnchor, constant: 20).isActive = true
        detailsStackView.topAnchor.constraint(equalTo: innerPanView.topAnchor, constant: 30).isActive = true

        innerPanView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: innerPanView.trailingAnchor, constant: -20).isActive = true
        doneButton.topAnchor.constraint(equalTo: innerPanView.topAnchor, constant: 30).isActive = true

        doneButton.setCorner(radius: 14)
        doneButton.setBorder(width: 3, color: .cyan)

        /// Stack 2
        wateringStack.translatesAutoresizingMaskIntoConstraints = false
        innerPanView.addSubview(wateringStack)

        wateringStack.addArrangedSubview(wateringInfoLbl)
        wateringStack.addArrangedSubview(wateringDescLbl)
        wateringStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        wateringStack.leadingAnchor.constraint(equalTo: innerPanView.leadingAnchor, constant: 20).isActive = true
        wateringStack.trailingAnchor.constraint(equalTo: innerPanView.trailingAnchor, constant: -20).isActive = true
        wateringStack.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 60).isActive = true

        /// Stack 3
        plantsInfoStack.translatesAutoresizingMaskIntoConstraints = false
        innerPanView.addSubview(plantsInfoStack)

        plantsInfoStack.addArrangedSubview(plantsInfoLbl)
        plantsInfoStack.addArrangedSubview(segmentController)
        plantsInfoStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        plantsInfoStack.leadingAnchor.constraint(equalTo: innerPanView.leadingAnchor, constant: 20).isActive = true
        plantsInfoStack.trailingAnchor.constraint(equalTo: innerPanView.trailingAnchor, constant: -20).isActive = true
        plantsInfoStack.topAnchor.constraint(equalTo: wateringStack.bottomAnchor, constant: 20).isActive = true
    }
}


// MARK: States
public enum State {
    case open
    case closed

    var invert: State {
        switch self {
            case .open: return .closed
            case .closed: return .open
        }
    }

    var isOpening: Bool {
        return self == .open
    }
}

// MARK: PanView Type
public enum PanViewType {
    case outer
    case inner

    var invert: PanViewType {
        switch self {
            case .outer: return .inner
            case .inner: return .outer
        }
    }

    var isOuter: Bool {
        return self == .outer
    }
}

// MARK: Custom PanGesture Recognizer
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizer.State.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizer.State.began
    }
}
