//
//  PrettyImage.swift
//  PrettyImageRevealAnimationDemo
//
//  Created by Arthur Myronenko on 19.05.15.
//  Copyright (c) 2015 Arthur Myronenko. All rights reserved.
//

import UIKit

protocol AnimationStoppedDelegate {
    func handleAnimationHasStopped()
}

class PrettyImageView: UIView {
    
    var animationDidStopDelegate: AnimationStoppedDelegate?
    
    var lineWidth: CGFloat = 2.0
    var outlineColor: UIColor?
    var animationDuration = CFTimeInterval(3.0)
    var image: UIImage? {
        didSet { revealImageView.image = image }
    }
    
    private let revealImageView: UIImageView
    
    init(image: UIImage?, frame: CGRect) {
        revealImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.image = image
        super.init(frame: frame)
        setup()
    }
    
    convenience init(image: UIImage) {
        self.init(image: image, frame: CGRectZero)
    }
    
    convenience init() {
        self.init(image: nil, frame: CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        revealImageView.image = image
        revealImageView.contentMode = .ScaleAspectFill
        revealImageView.clipsToBounds = true
        revealImageView.hidden = true
        self.addSubview(revealImageView)
    }
    
    func animate() {
        let outlineLayer = outlineCircleLayer
        self.layer.addSublayer(outlineLayer)
        
        outlineLayer.addAnimation(outlineAnimation, forKey: "outlineAnimation")
        
        // Constructing mask for reveal
        
        let initialRadius = CGFloat(1.0)
        let insetValue = revealImageView.bounds.width * 0.05
        
        let startPath = UIBezierPath(ovalInRect: CGRectMake(CGRectGetMidX(revealImageView.bounds) - initialRadius,
            CGRectGetMidY(revealImageView.bounds) - initialRadius,
            initialRadius * 2,
            initialRadius * 2))
        let finalPath = UIBezierPath(ovalInRect: CGRectInset(revealImageView.bounds, insetValue, insetValue))
        
        let imageRevealLayer = revealLayer
        imageRevealLayer.path = startPath.CGPath
        imageRevealLayer.position = CGPoint(x: CGRectGetMidX(revealImageView.bounds),
            y: CGRectGetMidY(revealImageView.bounds))
        
        revealImageView.layer.mask = imageRevealLayer
        
        // Constructing reveal animation
        
        let revealAnimation = getRevealAnimation(startPath.CGPath, finalPath: finalPath.CGPath)
        
        let timeToShow = dispatch_time(DISPATCH_TIME_NOW, Int64(animationDuration / 2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(timeToShow, dispatch_get_main_queue()) {
            self.revealImageView.hidden = false
        }
        
        imageRevealLayer.path = finalPath.CGPath
        
        imageRevealLayer.addAnimation(revealAnimation, forKey: "revealAnimation")
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        animationDidStopDelegate?.handleAnimationHasStopped()
    }
    
    private var outlineCircleLayer: CAShapeLayer {
        let circle = CAShapeLayer()
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, frame.width, frame.height))
        circle.position = CGPointZero
        circle.path = path.CGPath
        circle.fillColor = UIColor.clearColor().CGColor
        if let color = outlineColor {
            circle.strokeColor = color.CGColor
        } else {
            circle.strokeColor = UIColor(red: 1.0, green: 216.0 / 255.0, blue: 0.0, alpha: 1.0).CGColor
        }
        circle.lineWidth = lineWidth
        return circle
    }
    
    private var outlineAnimation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = animationDuration
        animation.repeatCount = 1.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return animation
    }
    
    private var revealLayer: CAShapeLayer {
        let revealShape = CAShapeLayer()
        revealShape.bounds = revealImageView.bounds
        revealShape.fillColor = UIColor.blackColor().CGColor
        return revealShape
    }
    
    private func getRevealAnimation(startPath: CGPath, finalPath: CGPath) -> CABasicAnimation {
        let revealAnimation = CABasicAnimation(keyPath: "path")
        revealAnimation.fromValue = startPath
        revealAnimation.toValue = finalPath
        revealAnimation.duration = animationDuration / 2.0
        revealAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        revealAnimation.repeatCount = 1.0
        revealAnimation.beginTime = CACurrentMediaTime() + animationDuration / 2.0
        revealAnimation.delegate = self
        
        return revealAnimation
    }
    
}
