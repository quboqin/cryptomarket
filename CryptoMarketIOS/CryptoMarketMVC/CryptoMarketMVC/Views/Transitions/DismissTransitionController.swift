//
//  DismissTransitionController.swift
//  CryptoMarketMVC
//
//  Created by Qubo on 8/25/18.
//  Copyright © 2018 Qubo. All rights reserved.
//

import UIKit

class DismissTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let screenBounds = UIScreen.main.bounds
        var finalFrame = fromViewController.view.frame
        finalFrame.origin.y = screenBounds.size.height
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .curveEaseIn,
                       animations: { 
                        fromViewController.view.frame = finalFrame
                        toViewController.view.alpha = 1.0
        }) { (finished) in
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
