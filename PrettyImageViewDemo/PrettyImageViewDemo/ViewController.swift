//
//  ViewController.swift
//  PrettyImageViewDemo
//
//  Created by Kyle Blazier on 3/4/16.
//  Copyright © 2016 PrettyImageView. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AnimationStoppedDelegate {
    
    // Note that implementing the AnimationStoppedDelegate is optional
    
    var animationView = PrettyImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Begin animation
        beginAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func beginAnimation() {
        animationView = PrettyImageView(image: UIImage(named: "gitHubImage"), frame: CGRectMake(0, 0, 32, 32))
        animationView.lineWidth = 4.0
        animationView.outlineColor = UIColor.blackColor()
        animationView.animationDidStopDelegate = self
        animationView.center = self.view.center
        self.view.addSubview(animationView)
        animationView.animate()
    }
    
    func handleAnimationHasStopped() {
        UIView.animateWithDuration(3.0) { () -> Void in
            self.animationView.backgroundColor = UIColor.whiteColor()
            self.animationView.layer.cornerRadius = self.animationView.frame.width / 2
            self.view.backgroundColor = UIColor.blackColor()
        }
    }
}

