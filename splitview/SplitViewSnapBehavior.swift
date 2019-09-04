//
//  SplitViewSnapBehavior.swift
//  SplitView
//
//  Created by Zachary Gorak on 9/3/19.
//  Copyright © 2019 Zac Gorak. All rights reserved.
//

import Foundation

public struct SplitViewSnapPoint: Equatable {
    let percentage: CGFloat
    let tolerance: CGFloat
    
    static var defaultTolerance:CGFloat = 0.03
}

public enum SplitViewSnapBehavior: Equatable {
    /// Snap every 25% (0%, 25%, 50%, 75%, 80%) with the default tolerance
    case quarter
    /// Snap every 33% (0%, 33%, 66%, 100%) with a the default tolerance
    case third
    case custom(percentage: CGFloat, tolerance: CGFloat)
    case withPoint(SplitViewSnapPoint)
    case withPoints([SplitViewSnapPoint])
    
    var snapPoints: [SplitViewSnapPoint] {
        switch self {
        case .quarter:
            return [SplitViewSnapPoint(percentage: 0.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 0.25, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 0.50, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 0.75, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 1.0, tolerance: SplitViewSnapPoint.defaultTolerance)]
        case .third:
            return [SplitViewSnapPoint(percentage: 0.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 1.0/3.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 2.0/3.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 1.0, tolerance: SplitViewSnapPoint.defaultTolerance)
            ]
        case .withPoint(let point):
            return [point]
        case .withPoints(let points):
            return points
        case .custom(let percentage, let tolerance):
            return [SplitViewSnapPoint(percentage: percentage, tolerance: tolerance)]
        }
    }
}
