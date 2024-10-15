//
//  BaseNavigationController.swift
//  Meme
//
//  Created by DAO on 2024/10/15.
//

import UIKit

class BaseNavigationController: UINavigationController {
    private var snapshotView: UIView?
    private let velocityThreshold: CGFloat = 1000 // Adjust this value to change the sensitivity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let topViewController = viewControllers.last else { return }
        
        let translation = gesture.translation(in: view)
        let progress = translation.x / view.bounds.width
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            // Create an overlay view to display the content of the previous view controller
            if viewControllers.count > 1 {
                let previousVC = viewControllers[viewControllers.count - 2]
                createAndAddSnapshotView(for: previousVC)
            }
            
        case .changed:
            // Update the position of the overlay view
            if let snapshotView = self.snapshotView {
                snapshotView.frame.origin.x = -view.bounds.width + translation.x
            }
            topViewController.view.frame.origin.x = max(0, translation.x)
            
        case .ended, .cancelled:
            let shouldComplete = (progress > 0.5 || velocity.x > velocityThreshold)
            
            if shouldComplete {
                // If swiped more than halfway or with high velocity, complete the return operation
                UIView.animate(withDuration: 0.3, animations: {
                    topViewController.view.frame.origin.x = self.view.bounds.width
                    if let snapshotView = self.snapshotView {
                        snapshotView.frame.origin.x = 0
                    }
                }) { _ in
                    self.popViewController(animated: false)
                    self.snapshotView?.removeFromSuperview()
                    self.snapshotView = nil
                }
            } else {
                // Otherwise, restore to the original position
                UIView.animate(withDuration: 0.3) {
                    topViewController.view.frame.origin.x = 0
                    if let snapshotView = self.snapshotView {
                        snapshotView.frame.origin.x = -self.view.bounds.width
                    }
                } completion: { _ in
                    self.snapshotView?.removeFromSuperview()
                    self.snapshotView = nil
                }
            }
            
        default:
            break
        }
    }
    
    private func createAndAddSnapshotView(for viewController: UIViewController) {
        // Remove existing snapshot if any
        snapshotView?.removeFromSuperview()
        
        // Create a container view that will host the actual view
        let containerView = UIView(frame: view.bounds)
        
        // Add the actual view as a subview of the container
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        
        // Add the container view to the main view
        view.addSubview(containerView)
        view.sendSubviewToBack(containerView)
        
        // Store the reference to the container view
        snapshotView = containerView
        
        // Force layout update to ensure proper rendering
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Check if the user interface style (light/dark mode) has changed
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Recreate the snapshot view if it exists
            if let snapshotView = snapshotView,
               viewControllers.count > 1 {
                let previousVC = viewControllers[viewControllers.count - 2]
                createAndAddSnapshotView(for: previousVC)
                
                // Restore the position of the new snapshot view
                snapshotView.frame.origin.x = self.snapshotView?.frame.origin.x ?? -view.bounds.width
            }
        }
    }
}
