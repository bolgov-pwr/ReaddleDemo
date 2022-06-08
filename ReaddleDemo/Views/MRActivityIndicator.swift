//
//  MRActivityIndicator.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 07.06.2022.
//

import UIKit

final class ActivityIndicator: UIView {
    static let shared = ActivityIndicator()
    
    private convenience init() {
        self.init(frame: UIScreen.main.bounds)
        isUserInteractionEnabled = false
    }
    
    private var spinnerBehavior: UIDynamicItemBehavior?
    private var animator: UIDynamicAnimator?
    private var imageView: UIImageView?
    private var bgImageView: UIImageView?
    private var loaderImageName = ""
    private var bgImage = ""
        
    func show(with image: String = "spinner", bgImage: String = "spinner_bg") {
        loaderImageName = image
        self.bgImage = bgImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            if self?.imageView == nil {
                self?.setupView()
                DispatchQueue.main.async {[weak self] in
                    self?.showLoadingActivity()
                }
            }
        }
    }
    
    func hide() {
        DispatchQueue.main.async {[weak self] in
            self?.stopAnimation()
        }
    }
    
    private func setupView() {
        center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        
        let theBgImage = UIImage(named: bgImage)
        bgImageView = UIImageView(image: theBgImage)
        bgImageView?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        bgImageView?.center = CGPoint(x: center.x, y: center.y / 1.5)
        
        let theImage = UIImage(named: loaderImageName)
        imageView = UIImageView(image: theImage)
        imageView?.frame = bgImageView?.frame ?? .zero
        
        if let imageView = imageView {
            self.spinnerBehavior = UIDynamicItemBehavior(items: [imageView])
        }
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    private func showLoadingActivity() {
        if let imageView = imageView, let bgView = bgImageView {
            addSubview(bgView)
            addSubview(imageView)
            startAnimation()
            (UIApplication.shared.delegate as? AppDelegate)?.window?.addSubview(self)
        }
    }
    
    private func startAnimation() {
        guard let imageView = imageView,
              let spinnerBehavior = spinnerBehavior,
              let animator = animator else { return }
        if !animator.behaviors.contains(spinnerBehavior) {
            spinnerBehavior.addAngularVelocity(5.0, for: imageView)
            spinnerBehavior.angularResistance = 0
            animator.addBehavior(spinnerBehavior)
        }
    }
    
    private func stopAnimation() {
        animator?.removeAllBehaviors()
        imageView?.removeFromSuperview()
        bgImageView?.removeFromSuperview()
        imageView = nil
        bgImageView = nil
        self.removeFromSuperview()
    }
}
