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

    // Animator Properties
    var innerPanState: State = .closed
    var detailsPanBottomOffset: CGFloat = 0.0

    var panViewType: PanViewType = .outer
    var outerPanState: State = .closed

    var tranistionAnimators: [UIViewPropertyAnimator] = []
    var animationProgress: [CGFloat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        configCollectionViews()
        constructPanViewLayout()
        constructInnerLayout()
        configPanGesture()

        self.plantsInfoStack.alpha = 0.0
        self.wateringStack.alpha = 0.0
    }

    func configViews() {
        self.panOutView.setCorner(radius: 15)
        let panOutheight = self.view.frame.height * 0.9
        self.panOutHtCons.constant = panOutheight
        self.panOutBottomCons.constant = -panOutheight / 2
        self.panOutView.layoutIfNeeded()
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
        self.detailsPanBottomOffset = panOutHtCons.constant / 2
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

// MARK: Handle Pan Animation
extension ViewController {

    func configInnerPanAnimations(state: State) {

        guard tranistionAnimators.isEmpty else { return }
        let transitionAnimator = UIViewPropertyAnimator(duration: 2, dampingRatio: 1)

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
            self.addDayTransitions()
            self.view.layoutIfNeeded()
        }, delayFactor: state.isOpening  ? 0.3 : 0)


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
                    self.plantsInfoStack.alpha = 1.0
                    self.wateringStack.alpha = 1.0

                case .closed:
                    self.detailsPanBottomCons.constant = self.detailsPanBottomOffset
                    self.plantsInfoStack.alpha = 0.0
                    self.wateringStack.alpha = 0.0
            }
            print("Animation Removing...")
            self.tranistionAnimators.removeAll()
        }

        transitionAnimator.startAnimation()
        self.tranistionAnimators.append(transitionAnimator)
    }

    func configOuterPanAnimations(state: State) {

        guard tranistionAnimators.isEmpty else { return }
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
                case .closed:
                    self.panOutBottomCons.constant = -self.detailsPanBottomOffset
            }

            print("Animation Removing...")
            self.tranistionAnimators.removeAll()
        }

        transitionAnimator.startAnimation()
        self.tranistionAnimators.append(transitionAnimator)
    }

    func animatePlantsInfo(state: State) {
        switch state {
            case .open:
                self.plantsInfoStack.transform = CGAffineTransform(translationX: 0, y: -40)
                self.wateringStack.transform = CGAffineTransform(translationX: 0, y: -40)
                self.plantsInfoStack.alpha = 1.0
                self.wateringStack.alpha = 1.0
            case .closed:
                self.plantsInfoStack.transform = .identity
                self.wateringStack.transform = .identity
                self.plantsInfoStack.alpha = 0.0
                self.wateringStack.alpha = 0.0
        }
    }


    @objc
    func handleOuterPan(recognizer: InstantPanGestureRecognizer) {
        self.handlePan(recognizer: recognizer, panType: .outer)
    }

    @objc
    func handleInnerPan(recognizer: InstantPanGestureRecognizer) {
        self.handlePan(recognizer: recognizer, panType: .inner)
    }

    func handlePan(recognizer: InstantPanGestureRecognizer, panType: PanViewType) {

        switch recognizer.state {
            case .began:
                panType == .inner ? configInnerPanAnimations(state: innerPanState.invert) :
                                    configOuterPanAnimations(state: outerPanState.invert)
                tranistionAnimators.forEach { $0.pauseAnimation() }
                animationProgress = tranistionAnimators.map { $0.fractionComplete }

            case .changed:
                var yPoint = -(recognizer.translation(in: innerPanView).y / detailsPanBottomOffset)
                let state = panType.isOuter ? outerPanState : innerPanState
                if state == .open { yPoint *= -1}
                if tranistionAnimators[0].isReversed { yPoint *= -1 }

                for (index, animator) in tranistionAnimators.enumerated() {
                    animator.fractionComplete = yPoint + animationProgress[index]
                }

            case .ended:

                let yVelocity = recognizer.velocity(in: innerPanView).y
                let shouldClose = yVelocity > 0

                print("********* ENDED STATE STARTED *********")

                if yVelocity == 0 {
                tranistionAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
                }

                let state = panType.isOuter ? outerPanState : innerPanState
                switch state {
                    case .open:
                        if !shouldClose && !tranistionAnimators[0].isReversed { tranistionAnimators.forEach { $0.isReversed = !$0.isReversed } }
                        if shouldClose && tranistionAnimators[0].isReversed { tranistionAnimators.forEach { $0.isReversed = !$0.isReversed } }
                    case .closed:
                        if shouldClose && !tranistionAnimators[0].isReversed { tranistionAnimators.forEach { $0.isReversed = !$0.isReversed } }
                        if !shouldClose && tranistionAnimators[0].isReversed { tranistionAnimators.forEach { $0.isReversed = !$0.isReversed } }
                }
                tranistionAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }

            default: break
        }
    }
}

// MARK: CollectionView Delegates
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    fileprivate func configCollectionViews() {
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
