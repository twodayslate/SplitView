import Foundation
import UIKit

open class SplitViewHandle: UIView {
    
    public var handle: UIView
    public var size: CGFloat
    private var usingDefaultHandle: Bool = false
    public var initialOrigin: CGPoint? = nil
    
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            self.layoutConstraints()
        }
    }
    
    public var handleConstraints = [NSLayoutConstraint]()
    
    init(with image: UIImageView? = nil, axis: NSLayoutConstraint.Axis = .vertical, size: CGFloat = 18.0) {
        self.axis = axis
        self.size = size
        if let image = image {
            handle = image
        } else {
            handle = UIView()
            handle.translatesAutoresizingMaskIntoConstraints = false
            handle.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            handle.layer.cornerRadius = 4.0
            usingDefaultHandle = true
        }

        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        
        self.addSubview(handle)
        
        handle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        handle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.layoutConstraints()
    }
    
    open func layoutConstraints() {
        self.removeConstraints(self.handleConstraints)
        handleConstraints.removeAll()
        
        if usingDefaultHandle {
            if self.axis == .vertical {
                handleConstraints = [
                    NSLayoutConstraint(item: self.handle, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
                    NSLayoutConstraint(item: self.handle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: 50.0)
                ]
            } else {
                handleConstraints = [
                    NSLayoutConstraint(item: self.handle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: 50.0),
                    NSLayoutConstraint(item: self.handle, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0.0)
                ]
            }
        }
        
        if self.axis == .vertical {
            handleConstraints.append(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: self.size))
        } else {
            handleConstraints.append(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: self.size))
        }
        
        self.addConstraints(self.handleConstraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
