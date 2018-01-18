//
//  LSQTonedButton.swift
//
//  Created by Charles Mastin on 3/17/16.
//  https://gist.github.com/kristopherjohnson/99783393889e6b3b9830

import Foundation
import UIKit

/// UIButton subclass that draws a rounded rectangle in its background.

open class LSQTonedButton: UIButton {
    
    // MARK: Public interface
    
    /// Corner radius of the background rectangle
    open var roundRectCornerRadius: CGFloat = 4 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Color of the background rectangle
    open var roundRectColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: Overrides
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    // MARK: Private
    
    fileprivate var roundRectLayer: CAShapeLayer?
    
    fileprivate func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.10).cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }
}
