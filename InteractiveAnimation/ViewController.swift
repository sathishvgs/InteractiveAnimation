//
//  ViewController.swift
//  InteractiveAnimation
//
//  Created by Sathish on 21/12/19.
//  Copyright © 2019 Sathish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var panOutView: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var weekDetailsView: UIView!
    @IBOutlet weak var bezerContainerView: UIView!

    @IBOutlet weak var bezeirView: BezierView!

    @IBOutlet weak var panOutHtCons: NSLayoutConstraint!
    @IBOutlet weak var panOutBottomCons: NSLayoutConstraint!


    let imageColors: [UIColor] = [.red, .blue, .green, .yellow, .brown, .cyan]

    var innerPanView: UIView = {
        let view = UIView()
        view.setCorner(radius: 15.0)
        view.backgroundColor = .yellow
        return view
    }()

    // Stack 1
    var detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()

    var nextWatchingLbl: UILabel = {
        let label = UILabel()
        label.text = "Next Watering in"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    var dayCountLbl: UILabel = {
        let label = UILabel()
        label.text = "1 day"
        label.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        return label
    }()

    var nextDescLbl : UILabel = {
        let label = UILabel()
        label.text = "Watering every 7 days"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        return label
    }()

    var doneButton: UIButton = {
        let button = UIButton()
        return button
    }()

    /// Stack 2
    var wateringStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        return stackView
    }()

    var wateringInfoLbl: UILabel = {
        let label = UILabel()
        label.text = "Watering Info"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    var wateringDescLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.text = "Watering the kind of plants directly will depends on the temperature of the place."
        return label
    }()

    /// Stack 3
    var plantsInfoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        return stackView
    }()

    var plantsInfoLbl: UILabel = {
        let label = UILabel()
        label.text = "Plants Info"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    var segmentController: UISegmentedControl = {
        let items = ["18-28 c", "70 - 75 %", "5k to 10k lux"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.setCorner(radius: 5.0)
        return segment
    }()

    var detailsPanBottomCons = NSLayoutConstraint()
    var offsetDiff: CGFloat = 154
    var largerDeviceOffset: CGFloat = {
        return CGFloat(Device.shared.isLargerDevices ? 50 : 0)
    }()

    // Animator Properties
    var innerPanState: State = .closed
    var detailsPanBottomOffset: CGFloat = 0.0

    var panViewType: PanViewType = .outer
    var outerPanState: State = .closed

    var outerTranistionAnimators: [UIViewPropertyAnimator] = []
    var outerAnimationProgress: [CGFloat] = []

    var innerTranistionAnimators: [UIViewPropertyAnimator] = []
    var innerAnimationProgress: [CGFloat] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        configCollectionViews()
        constructPanViewLayout()
        constructInnerLayout()
        configPanGesture()
        configCurve()

        self.plantsInfoStack.alpha = 0.0
        self.wateringStack.alpha = 0.0
        self.weekDetailsView.alpha = 0.0
        self.bezerContainerView.alpha = 0.0
    }

    func configViews() {
        self.panOutView.setCorner(radius: 15)
        let panOutheight = (self.view.frame.height * 0.9)
        self.panOutHtCons.constant = panOutheight
        self.panOutBottomCons.constant = -(panOutheight / 2)
        self.panOutView.layoutIfNeeded()
    }

    func configCurve() {

        var points: [CGPoint] = []
        var animatePoints: [CGPoint] = []
        let equal = self.bezeirView.frame.width / 6

        let point1 = CGPoint(x: 0, y: 175)
        let point2 = CGPoint(x: equal , y: 50)
        let point3 = CGPoint(x: equal * 2, y: 100)
        let point4 = CGPoint(x: equal * 3, y: 50)
        let point5 = CGPoint(x: equal * 4, y: 100)
        let point6 = CGPoint(x: equal * 5, y: 125)
        let point7 = CGPoint(x: equal * 6, y: 180)
        points.append(contentsOf: [point1, point2, point3, point4, point5, point6, point7])

        for point in points {
            animatePoints.append(CGPoint(x: point.x, y: self.bezeirView.frame.height))
        }
        bezeirView.setup(originalPoints: points, animatePoints: animatePoints)
    }
}

// MARK: PAN Animation Configuration
extension ViewController {

    func constructPanViewLayout() {
        self.view.addSubview(innerPanView)
        innerPanView.translatesAutoresizingMaskIntoConstraints = false
        innerPanView.heightAnchor.constraint(equalToConstant: panOutView.frame.height - offsetDiff).isActive = true
        innerPanView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        innerPanView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        innerPanView.layoutIfNeeded()
        self.detailsPanBottomOffset = (panOutHtCons.constant / 2)
        detailsPanBottomCons = innerPanView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailsPanBottomOffset)
        detailsPanBottomCons.isActive = true
    }

    func configPanGesture() {
        doneButton.addTarget(self, action: #selector(didDoneBttnTapped(_:)), for: .touchDown)

        let innerGesture = InstantPanGestureRecognizer(target: self, action: #selector(handleInnerPan(recognizer:)))
        let outerGesture = InstantPanGestureRecognizer(target: self, action: #selector(handleOuterPan(recognizer:)))
        innerGesture.delegate = self
        outerGesture.delegate = self
        innerPanView.addGestureRecognizer(innerGesture)
        panOutView.addGestureRecognizer(outerGesture)
    }

    @objc
    func didDoneBttnTapped(_ sender: InstantPanGestureRecognizer) {
        handleInnerPan(recognizer: sender)
    }

    func addDayTransitions() {
        for index in 1...5 {
            let indexStr = (index == 1) ? "\(index) day" : "\(index) days"
            dayCountLbl.text = "\(indexStr)"
        }
    }
}

// MARK: InnerView Pan Animation
extension ViewController {

    func configInnerPanAnimations(state: State) {

        guard innerTranistionAnimators.isEmpty else { return }
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1)

        // Animation 1
        transitionAnimator.addAnimations ({ [weak self] in
            guard let `self` = self else { return }

            switch state {
                case .open:
                    self.detailsPanBottomCons.constant = 0
                case .closed:
                    self.detailsPanBottomCons.constant = self.detailsPanBottomOffset
            }
            self.view.layoutIfNeeded()
            }, delayFactor: state.isOpening ? 0 : 0.3)

        // Animation 2
        transitionAnimator.addAnimations ({
            self.animatePlantsInfo(state: state)
            self.animateWateringInfo(state: state)
            self.addDayTransitions()
            self.view.layoutIfNeeded()
        }, delayFactor: state.isOpening  ? 0.3 : 0.0)

        transitionAnimator.addCompletion { [weak self] position in

            guard let `self` = self else { return }
            switch position {
                case .start:
                    self.innerPanState = state.invert
                case .end:
                    self.innerPanState = state
                case .current: break
                @unknown default: ()
            }

            switch self.innerPanState {
                case .open:
                    self.detailsPanBottomCons.constant = 0

                case .closed:
                    self.detailsPanBottomCons.constant = self.detailsPanBottomOffset
            }
            print("Animation Removing...")
            self.innerTranistionAnimators.removeAll()
        }

        transitionAnimator.startAnimation()
        self.innerTranistionAnimators.append(transitionAnimator)
    }

    func animatePlantsInfo(state: State) {
        switch state {
            case .open:
                self.plantsInfoStack.transform = CGAffineTransform(translationX: 0, y: -40)
                self.plantsInfoStack.alpha = 1.0
            case .closed:
                self.plantsInfoStack.transform = .identity
                self.plantsInfoStack.alpha = 0.0
        }
    }

    func animateWateringInfo(state: State) {
        switch state {
            case .open:
                self.wateringStack.transform = CGAffineTransform(translationX: 0, y: -40)
                self.wateringStack.alpha = 1.0
            case .closed:
                self.wateringStack.transform = .identity
                self.wateringStack.alpha = 0.0
        }
    }
}

// MARK: OuterView Pan Transitions
extension ViewController {

    func configOuterPanAnimations(state: State) {

        guard outerTranistionAnimators.isEmpty else { return }
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1)

        transitionAnimator.addAnimations { [weak self] in
            guard let `self` = self else { return }

            switch state {
                case .open:
                    self.panOutBottomCons.constant = 0
                case .closed:
                    self.panOutBottomCons.constant = -self.detailsPanBottomOffset
            }
            self.view.layoutIfNeeded()
        }

        transitionAnimator.addAnimations ({ [weak self] in
            guard let `self` = self else { return }
            switch state {
                case .open:
                    self.weekDetailsView.alpha = 1.0
                    self.weekDetailsView.transform = CGAffineTransform(translationX: 0, y: -40)
                case .closed:
                    self.weekDetailsView.alpha = 0
                    self.weekDetailsView.transform = .identity
            }
            }, delayFactor: state.isOpening ? 0.2 : 0.05)


        transitionAnimator.addAnimations ({ [weak self] in
            guard let `self` = self else { return }
            switch state {
                case .open:
                    self.bezerContainerView.alpha = 1.0
                    self.bezerContainerView.transform = CGAffineTransform(translationX: 0, y: -40)
                case .closed:
                    self.bezerContainerView.alpha = 0
                    self.bezerContainerView.transform = .identity
            }
            }, delayFactor: state.isOpening ? 0.5 : 0.0)


        transitionAnimator.addAnimations ({
            switch state {
                case .open:
                    self.bezeirView.toggleCurveLines(show: true)
                case .closed:
                    self.bezeirView.toggleCurveLines(show: false)
            }
        }, delayFactor: state.isOpening ? 0.5 : 0.3)


        transitionAnimator.addCompletion { [weak self] position in

            guard let `self` = self else { return }

            switch position {
                case .start:
                    self.outerPanState = state.invert
                case .end:
                    self.outerPanState = state
                case .current: break
                @unknown default: ()
            }

            switch self.outerPanState {
                case .open:
                    self.panOutBottomCons.constant = 0
                    self.bezeirView.toggleCurveLines(show: true)
                    self.weekDetailsView.alpha = 1.0
                    self.weekDetailsView.transform = CGAffineTransform(translationX: 0, y: -40)
                    self.bezerContainerView.alpha = 1.0
                    self.bezerContainerView.transform = CGAffineTransform(translationX: 0, y: -40)


                case .closed:
                    self.panOutBottomCons.constant = -self.detailsPanBottomOffset
                    self.bezeirView.toggleCurveLines(show: false)
                    self.weekDetailsView.alpha = 0
                    self.weekDetailsView.transform = .identity
                    self.bezerContainerView.alpha = 0
                    self.bezerContainerView.transform = .identity
            }

            print("Animation Removing...")
            self.outerTranistionAnimators.removeAll()
        }

        transitionAnimator.startAnimation()
        self.outerTranistionAnimators.append(transitionAnimator)
    }
}

// MARK: Handle PanGesture
extension ViewController {

    @objc
    func handleOuterPan(recognizer: InstantPanGestureRecognizer) {
        self.handlePan(recognizer: recognizer, panType: .outer)
    }

    @objc
    func handleInnerPan(recognizer: InstantPanGestureRecognizer) {
        if outerPanState == .open {
            configOuterPanAnimations(state: outerPanState.invert)
        }
        self.handlePan(recognizer: recognizer, panType: .inner)
    }

    func handlePan(recognizer: InstantPanGestureRecognizer, panType: PanViewType) {

        switch recognizer.state {
            case .began:

                if panType == .inner {
                    configInnerPanAnimations(state: innerPanState.invert)
                    innerTranistionAnimators.forEach { $0.pauseAnimation() }
                    innerAnimationProgress = innerTranistionAnimators.map { $0.fractionComplete }
                } else {
                    configOuterPanAnimations(state: outerPanState.invert)
                    outerTranistionAnimators.forEach { $0.pauseAnimation() }
                    outerAnimationProgress = outerTranistionAnimators.map { $0.fractionComplete }
            }

            case .changed:
                var yPoint = -(recognizer.translation(in: innerPanView).y / detailsPanBottomOffset)
                let state = panType.isOuter ? outerPanState : innerPanState
                if state == .open { yPoint *= -1}
                checkForTransitionReverse(panType: panType, yPoint: &yPoint)

            case .ended:

                let yVelocity = recognizer.velocity(in: innerPanView).y
                let shouldClose = yVelocity > 0
                let transitionAnimator = panType == .inner ? innerTranistionAnimators : outerTranistionAnimators

                if yVelocity == 0 {
                    transitionAnimator.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                    break
                }

                let state = panType.isOuter ? outerPanState : innerPanState
                switch state {
                    case .open:
                        if !shouldClose && !transitionAnimator[0].isReversed { transitionAnimator.forEach { $0.isReversed = !$0.isReversed } }
                        if shouldClose && transitionAnimator[0].isReversed { transitionAnimator.forEach { $0.isReversed = !$0.isReversed } }
                    case .closed:
                        if shouldClose && !transitionAnimator[0].isReversed { transitionAnimator.forEach { $0.isReversed = !$0.isReversed } }
                        if !shouldClose && transitionAnimator[0].isReversed { transitionAnimator.forEach { $0.isReversed = !$0.isReversed } }
                }
                transitionAnimator.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                print("Ended")

            default: break
        }
    }


    func checkForTransitionReverse(panType: PanViewType, yPoint: inout CGFloat) {

        switch panType {
            case .inner:
                if innerTranistionAnimators[0].isReversed { yPoint *= -1 }
                for (index, animator) in innerTranistionAnimators.enumerated() {
                    animator.fractionComplete = yPoint + innerAnimationProgress[index]
            }

            case .outer:
                if outerTranistionAnimators[0].isReversed { yPoint *= -1 }
                for (index, animator) in outerTranistionAnimators.enumerated() {
                    animator.fractionComplete = yPoint + outerAnimationProgress[index]
            }
        }
    }
}

