//
//  SplitStackView.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/20/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//
// swiftlint:disable all
import Foundation
import UIKit

open class SplitView: UIView {
    // MARK: - Properties
    // MARK: Private
    private let stack = UIStackView()
    
    // MARK: Public
    public var views = [SplitSupportingView]()
    public var handles = [SplitViewHandle]()
    
    /// The handle's width/size
    public var handleSize: CGFloat
    /// The minimum width/height ratio for each view
    public var minimumRatio: CGFloat
    /// The animation duration when resizing views
    public var animationDuration: TimeInterval = 0.01
    
    /// This property determines the orientation of the arranged views.
    /// Assigning the NSLayoutConstraint.Axis.vertical value creates a column of views.
    /// Assigning the NSLayoutConstraint.Axis.horizontal value creates a row.
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            DispatchQueue.main.async {
                self.stack.axis = self.axis
                
                for handle in self.handles {
                    handle.axis = self.axis
                }
                
                self.setRatios()
                
                UIView.animate(withDuration: self.animationDuration * 6) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    public init(with views: [UIView]? = nil, axis: NSLayoutConstraint.Axis = .vertical, handleHeight: CGFloat = 18.0, minimumRatio: CGFloat = 0.0) {
        precondition(handleHeight > 0.0, "Handle height must be positive")
        precondition(minimumRatio >= 0.0, "minimumRatio must be 0.0 or greater")
        precondition(minimumRatio < 1.0, "minimumRatio must be less than 1.0")
        
        self.minimumRatio = minimumRatio
        self.handleSize = handleHeight
        self.axis = axis
        super.init(frame: .zero)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = self.axis
        
        self.addSubview(stack)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        
        if let newViews = views {
            for view in newViews {
                self.addView(view)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Handling
    
    /// Add a view to your `SplitView`
    /// - warning:
    /// Currently the maximum supported views is 2
    open func addView(_ view: UIView, ratio: CGFloat = 0.5, minRatio: CGFloat = 0.0) {
        precondition(ratio >= 0.0, "Ratio must be greater than zero")
        precondition(ratio <= 1.0, "Ratio must be less than one")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let organizer = SplitSupportingView(view: view, ratio: ratio, minRatio: minRatio, constraint: nil)
        views.append(organizer)
        
        if views.count % 2 == 0 {
            let handle = SplitViewHandle(axis: .vertical, size: self.handleSize)
            handle.translatesAutoresizingMaskIntoConstraints = false
            handles.append(handle)
            stack.addArrangedSubview(handle)
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
            handle.addGestureRecognizer(gesture)
        }
        
        stack.addArrangedSubview(organizer.view)
        
        self.assignRatios(newRatio: self.ratio(given: ratio, for: organizer), for: views.count - 1)
        self.setRatios()
    }
    
    private func setRatios() {
        var handleConstant = self.handleSize
        
        for (i, view) in views.enumerated() {
            views[i].constraint?.isActive = false
            views[i].constraint = nil
            
            if i >= self.handles.count {
                handleConstant = 0.0
            }
            
            // using greaterThanOrEqual to ignore rounding errors
            if self.axis == .vertical {
                views[i].constraint = NSLayoutConstraint(item: views[i].view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .height, multiplier: view.ratio, constant: view.ratio > 0.0 ? -handleConstant: 0.0)
            } else {
                 views[i].constraint = NSLayoutConstraint(item: views[i].view, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .width, multiplier: view.ratio, constant: view.ratio > 0.0 ? -handleConstant: 0.0)
            }
            views[i].constraint?.isActive = true
        }
    }
    
    private func ratio(given ratio: CGFloat, for organizer: SplitSupportingView)->CGFloat {
        if views.count == 1 {
            return 1.0
        }
        
        var minRatio: CGFloat = 0.0
        for view in views {
            if view == organizer {
                continue
            }
            minRatio += max(minimumRatio, view.minRatio)
        }
        if ratio >= 1.0 {
            return 1.0 - minRatio
        }
        
        let curMinRatio = max(minimumRatio, organizer.minRatio)
        
        if ratio <= 0.0 {
            return curMinRatio
        }
        
        if ratio < curMinRatio {
            return curMinRatio
        }
        
        if ratio + minRatio >= 1.0 {
            return ratio - (ratio + minRatio - 1.0)
        }
        
        return ratio
    }
    
    private func assignRatios(newRatio: CGFloat, for index: Int) {
        let secondRatio = 1.0 - newRatio
        for (i, _) in views.enumerated() {
            if i == index {
                views[i].ratio = newRatio
                continue
            }
            views[i].ratio = secondRatio
        }
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view as? SplitViewHandle else {
            return
        }
        
        guard let handleIndex = handles.firstIndex(of: handle) else {
            return
        }
        
        let organizer = views[handleIndex]
        
        switch sender.state {
        case .began:
            handle.initialOrigin = handle.frame.origin
            break
        case .changed:
            var newPoint = handle.initialOrigin!.y + sender.translation(in: handle).y
            var curPoint = handle.frame.origin.y
            if self.axis == .horizontal {
                newPoint = handle.initialOrigin!.x + sender.translation(in: handle).x
                curPoint = handle.frame.origin.x
            }
            
            var ratio: CGFloat = 0.0
            if curPoint != 0 {
                ratio = organizer.ratio * (newPoint/curPoint)
            } else {
                ratio = newPoint/stack.frame.width
                if self.axis == .horizontal {
                    ratio = newPoint/stack.frame.height
                }
            }
            views[handleIndex].ratio = self.ratio(given: max(ratio, views[handleIndex].minRatio), for: views[handleIndex])
            self.assignRatios(newRatio: views[handleIndex].ratio, for: handleIndex)
            
            
            UIView.animate(withDuration: self.animationDuration) {
                self.setRatios()
                self.layoutIfNeeded()
            }
            
            break
        default:
            break
        }
    }
}
