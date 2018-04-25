//
//  OBFullScreenDisplayBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 24/04/2018.
//  Copyright © 2018 Apokrupto. All rights reserved.
//

import UIKit

/// Make a UIStackView always expand to full screen, if the content is
/// too small, or scrollable when it's too large.
///
/// This is sometimes preferable to a typical table view when you
/// would prefer the simple layout of a stack view, plus no scrolling
/// if the content isn't too large.
///
/// With this approach a smaller font size may show as laid out in a
/// normal stack view, while another instance running with a larger font
/// size for accessibility purposes will result in a view that is still
/// laid out the same, but now scrolls to show all the content
///
/// To use in a storyboard:
///
/// - Add a scroll view to a view controller, anchored to the
///   top and bottom layout guides. The width can be whatever you like.
/// - Add a vertical stack view as a subview of the scroll view, with layout
///   constraints equal to the top, bottom, leading and trailing space, plus
///   equal widths
/// - The stack view's alignment should be fill, the distribution equal spacing
/// - Start adding elements.
///
/// To make the stack view full screen, for example to push buttons to the
/// bottom of the screen:
///
/// - Add a small UIView with a fixed height to the stack view between the
///   elements you want at the top of the screen and those at the bottom.
/// - Hook up the view's height constraint to the constraint outlet collection
/// - Hooking up multiple such padding views will separate the elements further into
///   evenly spaced groups that fill the screen if the content isn't too large.
/// - If the content is too large, there is no change
///
class OBFullScreenDisplayBehavior: OBBehavior {
    @IBOutlet var paddingCellHeights: [NSLayoutConstraint]!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView! {
        didSet {
            boundsChangeObserver = stackView.observe(\.bounds, options: .new) { stackView, _ in
                let heightDifference = self.scrollView.bounds.height - stackView.bounds.height
                
                if heightDifference > 0 {
                    self.paddingCellHeights.forEach {
                        $0.constant += heightDifference / CGFloat(self.paddingCellHeights.count)
                    }
                }
                else {
                    self.boundsChangeObserver = nil
                }
            }
        }
    }
    
    private var boundsChangeObserver: NSKeyValueObservation?
}
