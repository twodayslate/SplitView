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

/// Resizable Split View, inspired by [Apple’s Split View](https://support.apple.com/en-us/HT207582#split) for iPadOS and [SplitKit](https://github.com/macteo/SplitKit)
open class SplitView: UIView {
    // MARK: - Properties
    // MARK: Private
    private let stack = UIStackView()
    /// Used for snapping
    private var smallestRatio: CGFloat = 0.02
    
    // MARK: Public
    
    /// The list of supporting views split by the split view
    public var splitSupportingViews = [SplitSupportingView]()
    /// The list of views split by the split view.
    public var splitSubviews: [UIView] {
        return self.splitSupportingViews.compactMap({ $0.view })
    }
    /// The views being split
    @available(swift, deprecated: 1.3.0, obsoleted: 2.0.0, renamed: "splitSupportingViews")
    public var views: [SplitSupportingView] {
        return splitSupportingViews
    }
    /// The handles between views
    public var handles = [SplitViewHandle]()
    
    /// The minimum width/height ratio for each view
    public var minimumRatio: CGFloat
    /// The animation duration when resizing views
    public var animationDuration: TimeInterval = 0.2
    
    /// Snap Behavior
    public var snap = [SplitViewSnapBehavior]() {
        didSet {
            self.update()
        }
    }
    
    /// This property determines the orientation of the arranged views.
    /// Assigning the `NSLayoutConstraint.Axis.vertical` value creates a column of views.
    /// Assigning the `NSLayoutConstraint.Axis.horizontal` value creates a row.
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            self.update()
        }
    }
    
    // MARK: - Initializers
    
    public init(with views: [UIView]? = nil, axis: NSLayoutConstraint.Axis = .vertical, minimumRatio: CGFloat = 0.0) {
        precondition(minimumRatio >= 0.0, "minimumRatio must be 0.0 or greater")
        precondition(minimumRatio < 1.0, "minimumRatio must be less than 1.0")
        
        self.minimumRatio = minimumRatio
        self.axis = axis
        
        super.init(frame: .zero)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = self.axis
        
        self.addSubview(stack)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
        
        if let newViews = views {
            for view in newViews {
                self.addSplitSubview(view)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Handling
    
    private func addHandle(_ handle: SplitViewHandle, at: Int) {
        handle.axis = self.axis
        handle.translatesAutoresizingMaskIntoConstraints = false
        handles.append(handle)
        stack.insertArrangedSubview(handle, at: at)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        handle.addGestureRecognizer(gesture)
    }
    
    /// Adds a view to the end of the splitSupportingViews array
    @available(swift, introduced: 1.3.0)
    open func addSplitSubview(_ view: UIView, desiredRatio: CGFloat = 0.5, minimumRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        self.insertSplitSubview(view, at: self.splitSupportingViews.count, desiredRatio: desiredRatio, minimumRatio: minimumRatio, withHandle: withHandle)
    }
    
    /// Adds the provided view to the array of split subviews at the specified index.
    open func insertSplitSubview(_ view: UIView, at: Int, desiredRatio: CGFloat = 0.5, minimumRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        precondition(desiredRatio >= 0.0, "Ratio must be greater than zero")
        precondition(desiredRatio <= 1.0, "Ratio must be less than one")
        
        var insertAtIndex = at
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let beforeSize = splitSupportingViews.count
        
        let organizer = SplitSupportingView(view: view, ratio: desiredRatio, minRatio: minimumRatio, constraint: nil)
        splitSupportingViews.insert(organizer, at: at)
        
        if beforeSize != 0 && at >= beforeSize {
            let handle = withHandle ?? SplitViewHandle()
            insertAtIndex += Int(at / 2)
            self.addHandle(handle, at: insertAtIndex)
            insertAtIndex += 1
        }
        
        stack.insertArrangedSubview(organizer.view, at: insertAtIndex)
        
        if beforeSize != 0 && at < beforeSize {
            let handle = withHandle ?? SplitViewHandle()
            self.addHandle(handle, at: insertAtIndex + 1)
        }
        
        self.assignRatios(newRatio: self.ratio(given: desiredRatio, for: organizer), for: at)
        self.setRatios()
    }
    
    /// Removes the provided view from the stack’s array of split subviews.
    open func removeSplitSubview(_ view: UIView) {
        guard let index = self.splitSubviews.firstIndex(of: view) else {
            return
        }
        
        let organizer = splitSupportingViews.remove(at: index)
        
        stack.removeArrangedSubview(organizer.view)
        
        if handles.count > 0 {
            let handle = self.handles.remove(at: max(index-1,0))
            stack.removeArrangedSubview(handle)
        }
        
        self.setRatios()
    }
    
    /// Add a view to your `SplitView`
    /// - warning:
    /// Currently the maximum supported views is 2
    @available(swift, deprecated: 1.3.0, obsoleted: 2.0.0, renamed: "addSplitSubview")
    open func addView(_ view: UIView, ratio: CGFloat = 0.5, minRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        self.addSplitSubview(view, desiredRatio: ratio, minimumRatio: minRatio, withHandle: withHandle)
    }
    
    private func update() {
        self.stack.axis = self.axis
        
        for handle in self.handles {
            handle.axis = self.axis
        }
        
        self.setRatios()
        
        UIView.animate(withDuration: self.animationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    private func setRatios() {
        let totalHandleSize: CGFloat = handles.reduce(0.0) { $0 + $1.size }
        let count = splitSupportingViews.filter({ $0.ratio > 0 }).count
        
        let handleConstant = totalHandleSize/CGFloat(count)
        
        let original_constraints = splitSupportingViews.compactMap({$0.constraint})
        
        for (i, view) in splitSupportingViews.enumerated() {
            
            print("Setting", i, view.ratio, handleConstant)
            // using greaterThanOrEqual and lesser ratio to ignore rounding errors
            // also subtracting 0.01 to fix rounding errors
            
            let constant = view.ratio > 0.0 ? -handleConstant: 0.0
            let ratio = max(view.ratio - 0.01, 0.0)
            
            if self.axis == .vertical {
                splitSupportingViews[i].constraint = NSLayoutConstraint(item: splitSupportingViews[i].view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .height, multiplier: ratio, constant: constant)
            } else {
                 splitSupportingViews[i].constraint = NSLayoutConstraint(item: splitSupportingViews[i].view, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .width, multiplier: ratio, constant: constant)
            }
        }
        
        let new_constraints = splitSupportingViews.compactMap({$0.constraint})
        
        NSLayoutConstraint.deactivate(original_constraints)
        NSLayoutConstraint.activate(new_constraints)
    }
    
    private func ratio(given ratio: CGFloat, for organizer: SplitSupportingView)->CGFloat {
        if splitSupportingViews.count == 1 {
            return 1.0
        }
        
        var minRatio: CGFloat = 0.0
        for view in splitSupportingViews {
            if view == organizer {
                continue
            }
            minRatio += max(minimumRatio, view.minRatio)
        }
        if ratio >= 1.0 {
            return 1.0 - minRatio
        }
        
        let curMinRatio = max(minimumRatio, organizer.minRatio)
        
        if ratio <= self.smallestRatio {
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
        var ratio = newRatio
        
        for snapBehavior in self.snap {
            for point in snapBehavior.snapPoints {
                if ratio > (point.percentage - point.tolerance) && ratio < (point.percentage + point.tolerance) {
                    ratio = point.percentage
                }
            }
        }
        
        if splitSupportingViews.count == 1 {
            splitSupportingViews[0].ratio = 1.0
            return
        }
        if splitSupportingViews.count == 2 {
            let closestIndex = index == 0 ? 1 : 0
            
            var secondRatio = 1.0 - ratio
            
            let secondSmallestRatio = max(self.smallestRatio, splitSupportingViews[closestIndex].minRatio)
            if secondRatio < self.smallestRatio {
                secondRatio = secondSmallestRatio
                ratio = 1.0 - secondRatio
            }
            
            splitSupportingViews[index].ratio = ratio
            splitSupportingViews[closestIndex].ratio = secondRatio
    
            return
        }
        if splitSupportingViews.count == 3 {
            // ignore one of the ratios
            let closestIndex =  index == 0 ? 1 : (index == 1 ? 2 : (index == 2 ? 1 : 0))
            let farthestIndex = index == 0 ? 2 : (index == 1 ? 0 : (index == 2 ? 0 : 1))
            
            let totalRatio = 1.0 - splitSupportingViews[farthestIndex].ratio
            
            ratio = ratio * totalRatio
            var secondRatio = totalRatio - ratio
            
            let secondSmallestRatio = max(self.smallestRatio, splitSupportingViews[closestIndex].minRatio)
            if secondRatio < self.smallestRatio {
                secondRatio = secondSmallestRatio
                ratio = totalRatio - secondRatio
            }
            
            print("$$$$$$", index, ratio, closestIndex, secondRatio, farthestIndex)
            splitSupportingViews[index].ratio = ratio
            splitSupportingViews[closestIndex].ratio = secondRatio
        }
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view as? SplitViewHandle else {
            return
        }
        
        guard let handleIndex = handles.firstIndex(of: handle) else {
            return
        }
        
        let organizer = splitSupportingViews[handleIndex]
        
        switch sender.state {
        case .began:
            handle.initialOrigin = handle.frame.origin
            handle.isBeingUsed = true
            break
        case .changed:
            var newPoint = handle.initialOrigin!.y + sender.translation(in: handle).y
            var curPoint = handle.frame.origin.y
            if self.axis == .horizontal {
                newPoint = handle.initialOrigin!.x + sender.translation(in: handle).x
                curPoint = handle.frame.origin.x
            }
            
            print("$$$ start", organizer.ratio, newPoint, curPoint, handleIndex)
            
            var ratio: CGFloat = 0.0
            if curPoint != 0 {
                ratio = organizer.ratio * (newPoint/curPoint)
            } else {
                ratio = newPoint/stack.frame.height
                if self.axis == .horizontal {
                    ratio = newPoint/stack.frame.width
                }
                
                ratio = max(ratio, self.minimumRatio)
            }
            
            print("$$$$ calculated", ratio)
            splitSupportingViews[handleIndex].ratio = self.ratio(given: max(ratio, splitSupportingViews[handleIndex].minRatio), for: splitSupportingViews[handleIndex])
            print("$$$$$ end", splitSupportingViews[handleIndex].ratio)
            self.assignRatios(newRatio: splitSupportingViews[handleIndex].ratio, for: handleIndex)
            
            self.setRatios()
            UIView.animate(withDuration: self.animationDuration) {
                self.layoutIfNeeded()
            }
            
            break
        case .ended:
            handle.isBeingUsed = false
        default:
            break
        }
    }
}
